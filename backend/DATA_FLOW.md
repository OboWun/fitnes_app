# DATA FLOW: Backend ↔ PostgreSQL

## Общая архитектура

```
┌──────────────────────────────────────────────────────────────┐
│                        NestJS Backend                        │
│                                                              │
│  ┌──────────┐   ┌───────────────┐   ┌─────────────────────┐ │
│  │Controller│──▶│    Service     │──▶│  SQL Repository     │ │
│  │  (HTTP)  │   │ (business logic)│   │ (*-sql.repository)  │ │
│  └──────────┘   └───────────────┘   └──────────┬──────────┘ │
│                                                  │            │
│                                        ┌─────────▼─────────┐ │
│                                        │  DatabaseService   │ │
│                                        │   (pg.Pool query)  │ │
│                                        └─────────┬─────────┘ │
└──────────────────────────────────────────────────┼───────────┘
                                                    │ TCP/SQL
                                          ┌─────────▼─────────┐
                                          │    PostgreSQL      │
                                          │   (tables, funcs)  │
                                          └───────────────────┘
```

---

## Слой подключения: DatabaseModule / DatabaseService

### DatabaseModule
- Глобальный NestJS-модуль (`@Global()`)
- Провайдит `DatabaseService` как singleton
- Читает конфиг из переменных окружения (`DATABASE_URL`)

### DatabaseService
- Держит `pg.Pool` (connection pool)
- Экспортирует методы:
  - `query<T>(sql: string, params?: unknown[]): Promise<T[]>` — выполнение SQL
  - `transaction<T>(fn: (client: pg.PoolClient) => Promise<T>): Promise<T>` — выполнение в транзакции

---

## Потоки данных по модулям

### 1. Справочники (Read-Only из БД)

#### Bodyparts / Equipments / Contraindications / Muscles

```
Client ──GET /muscles──▶ MusclesController
                               │
                          MusclesService
                               │
                     MusclesSqlRepository
                               │
                     ──SELECT * FROM muscles──▶ PostgreSQL
                               │
                     ◀── Muscle[] ──────────────
```

### 2. Упражнения (JWT required, фильтрация + персонализация)

- Все endpoints требуют JWT — `ExercisesModule` импортирует `AuthModule`
- Пагинированный поиск с динамическими фильтрами (equipments, contraindications, targetMuscles, search)
- `isPersonal=true` — сортировка по доступности: безопасные → `low_weight` → `not_recommended` → `forbidden`
  - Противопоказания берутся из `user.contraindications` (не из query)
  - Запрещённые упражнения **не исключаются**, а перемещаются в конец
  - `contraindication` поле в ответе: `null` | `low_weight` | `not_recommended` | `forbidden`
- `GET /exercises/:slug` — детализация: полная информация + пересечение противопоказаний с профилем + 5 похожих упражнений
- Список возвращает короткий DTO: slug, name, imageUrl, description, equipments, contraindication
- `findForMILP()` — единый SQL-запрос для загрузки всех упражнений с metadata для MILP (inline `json_agg`, без N+1)
- Поиск похожих (same target muscles) и антагонистов (antagonist muscles) — тоже в коротком DTO
- N+1 в `toExercise()`: 5 подзапросов на каждую строку (targetMuscles, secondaryMuscles, bodyParts, equipments, contraindications)

### 3. Пользователи (Read-Write)

- Авторизация по deviceId → JWT
- Профиль: name, gender, weight, height, age, contraindications
- `gender` хранится в отдельной колонке `users.gender` (не в metadata), но отсутствует в `schema.sql` — добавлено отдельной миграцией
- `metadata` (JSONB): goal, experienceLevel, availableEquipment, recoveryCapacity, defaultEquipmentPresetId и т.д.

```sql
SELECT id, device_id, name, gender, weight, height, age, contraindications, metadata, created_at
FROM users WHERE id = $1;
```

### 4. Equipment Presets (Read-Write)

```
Client ──GET /equipment-presets/system──▶ EquipmentPresetsController
                                              │
                                    EquipmentPresetsService
                                              │
                                   EquipmentPresetsSqlRepository
                                              │
                              ──SELECT ... FROM equipment_presets
                               WHERE is_system = true──▶ PostgreSQL
```

- Системные пресеты (`is_system = true`, `user_id = NULL`) — только чтение, без авторизации
- Пользовательские пресеты — полный CRUD + clone (системного или чужого)
- `EquipmentPresetsModule` самопробрасывает `EquipmentsSqlRepository` вместо импорта `EquipmentsModule`
- `includeDetails=true` — дополнительный запрос к `equipments` для обогащения ответа slug + name

```sql
SELECT ... FROM equipment_presets WHERE user_id = $1 ORDER BY name;
SELECT ... FROM equipment_presets WHERE id = $1;
INSERT INTO equipment_presets (id, user_id, name, slug, is_system, equipment_slugs) VALUES (...);
UPDATE equipment_presets SET name=..., slug=..., equipment_slugs=..., updated_at=NOW() WHERE id=$1;
DELETE FROM equipment_presets WHERE id = $1;
```

### 5. Workout Templates (Read-Write)

```
Client ──POST /workout-templates──▶ WorkoutTemplatesController
                                        │
                              WorkoutTemplatesService
                                        │
                    ┌── WorkoutTemplatesSqlRepository
                    └── ScheduledWorkoutsSqlRepository
                                        │
                              ──INSERT/UPDATE workout_templates──▶ PostgreSQL
                              ──INSERT/DELETE workout_exercises──▶ PostgreSQL
                              ──INSERT/UPDATE scheduled_workouts──▶ PostgreSQL
```

- CRUD шаблонов: каждый шаблон содержит массив `WorkoutExercise[]`
- Упражнения шаблона хранятся в `workout_exercises` — при обновлении удаляются и вставляются заново
- Расписание: `scheduled_workouts` связывает шаблон с днём недели и временем

```sql
SELECT ... FROM workout_templates WHERE user_id = $1 ORDER BY created_at DESC;
-- + подзапрос для exercises:
SELECT exercise_slug, sets, reps, rest_between_sets, rest_after_exercise, sort_order
FROM workout_exercises WHERE template_id = $1 ORDER BY sort_order;
```

### 6. Training Plans (Read-Write)

```
Client ──POST /training-plans──▶ TrainingPlansController
                                       │
                             TrainingPlansService
                                       │
                          TrainingPlansSqlRepository
                                       │
                         ──INSERT INTO training_plans──▶ PostgreSQL
                         ──INSERT INTO training_plan_schedule──▶ PostgreSQL
                         ──INSERT INTO training_plan_sessions──▶ PostgreSQL
```

- CRUD планов: каждый план содержит расписание `TrainingPlanScheduleItem[]`
- Расписание хранится в `training_plan_schedule` — при обновлении удаляются и вставляются заново
- Activate: deactivate others → create TrainingPlanSession → create first WorkoutSession → SetPlanner
- Archive: deactivate plan → archive active session
- `source`: `'manual'` или `'milp'`
- MILP weekly-plan создаёт TrainingPlan напрямую (source='milp')

```sql
SELECT ... FROM training_plans WHERE user_id = $1 ORDER BY created_at DESC;
SELECT plan_id, day_of_week, workout_template_id, time, name, sort_order
  FROM training_plan_schedule WHERE plan_id = $1 ORDER BY sort_order;
SELECT ... FROM training_plan_sessions WHERE plan_id = $1 AND status = 'active';
```

### 7. Workout Sessions (Read-Write)

```
Client ──GET /workout-sessions──▶ WorkoutSessionsController
                                      │
                          WorkoutSessionsService
                                      │
                      WorkoutSessionsSqlRepository
                                      │
                    ──SELECT ... FROM workout_sessions──▶ PostgreSQL
                    ──SELECT ... FROM workout_session_exercises──▶ PostgreSQL
```

- CRUD сессий внутри планов: привязаны к `training_plan_session` через `plan_session_id`
- Упражнения сессии хранятся в `workout_session_exercises` — при обновлении удаляются и вставляются заново
- `findRecentCompletedByUserId()` — последние завершённые сессии (без фильтра по дате, `created_at` отсутствует)
- `findByPlanSessionId()` — сессии конкретной plan session

```sql
SELECT ... FROM workout_sessions WHERE user_id = $1 ORDER BY day_of_week;
-- + подзапрос для exercises:
SELECT exercise_slug, sets, ordering, metadata
FROM workout_session_exercises WHERE session_id = $1 ORDER BY ordering;
-- + per-set данные:
SELECT session_id, exercise_slug, set_number, set_type,
       planned_weight_kg, planned_reps, planned_duration_sec, planned_distance_m,
       actual_weight_kg, actual_reps, actual_duration_sec, actual_distance_m, actual_rpe, completed_at
FROM workout_session_sets WHERE session_id = $1 ORDER BY exercise_slug, set_number;
```

С 2026-05: workout_session_sets хранит per-set planned + actual данные. SetPlanner генерирует planned-сеты для первой planned-сессии при создании weekly plan, и для следующей — после complete.

### 8. Workout MILP — генерация одной тренировки

```
Client ──POST /workout-milp/generate──▶ WorkoutMilpController
                                              │
                                    1. Load user profile (gender, metadata, contraindications)
                                    2. computeFatigueAndHistory() — 14-day window
                                    3. computeWeeklyVolume() — 7-day window
                                              │
                                    WorkoutMilpService.generateWorkout()
                                              │
                                    4. normalizeInput() — derive exerciseCount, sets, reps, rest
                                       from goal + experience + gender + focus
                                              │
                                    5. filterCandidates() — equipment, contraindications
                                              │
                                    6. calculateWeights() — session-aware, gender-aware,
                                       weekly volume, fatigue, diversity, goal bonuses
                                              │
                                    7. solveLP() or greedyFallback()
                                              │
                                    8. buildOutput() — variable sets per exercise type
                                              │
                                     ◀── WorkoutMILPOutput
```

**Ключевые SQL-запросы:**
- `findForMILP()` — один запрос для загрузки всех упражнений с metadata
- `findRecentCompletedByUserId()` — последние завершённые сессии за N дней

### 9. Weekly Plan — генерация плана на неделю

```
Client ──POST /workout-milp/weekly-plan──▶ WorkoutMilpController
                                                │
                                       1. Load user (gender, age, height, weight)
                                                 │
                                       WeeklyProcessMilpService.generateWeeklyPlan()
                                                 │
                                       2. selectSplit(count, level, goal) → SplitStrategy
                                          - SPLIT_STRATEGIES matrix
                                          - Goal modifiers (rehab→Full Body)
                                          - SplitType override if specified
                                                 │
                                       3. assignDays(availableDays, sessionCount)
                                          - Best-spaced subset or evenly spaced
                                                 │
                                       4. computeWeeklyVolumeBudget(level, age, activity)
                                          - MUSCLE_WEEKLY_VOLUME_TARGETS × weeklyVolumeScale × age × activity
                                                 │
                                        For each session:
                                          5. deriveSessionParams() — focus muscles, exercise count
                                             from SESSION_MUSCLE_FOCUS + volume budget
                                             (glute_growth: force legs focus)
                                          6. Call workoutMilpService.generateWorkout()
                                             with per-session focus + accumulated volume
                                          7. Update accumulatedVolume, fatigueByMuscle, usedExercises
                                                  │
                                        8. Create WorkoutTemplate per day (with exercises)
                                        9. Create TrainingPlan (isActive: false, source: milp)
                                           + training_plan_schedule (day → templateId)
                                                  │
                                         ◀── WeeklyProcessOutput (planId)

Client ──POST /training-plans/:id/activate──▶ TrainingPlansController
                                                    │
                                          TrainingPlansService.activate()
                                                    │
                                          1. Deactivate other plans
                                          2. Activate plan (isActive: true)
                                          3. Create TrainingPlanSession (4 weeks)
                                          4. Read exercises from WorkoutTemplate (first day)
                                          5. Create WorkoutSession with exercises
                                          6. SetPlanner for first session
                                                    │
                                             ◀── TrainingPlanResponseDto
```

### 10. Workout Dialog — диалоговый сбор параметров

```
Client ──POST /workout-dialog/start──▶ WorkoutDialogController
                                             │
                                   1. Load user profile
                                   2. Pre-fill collectedParams from profile
                                      (goal, experienceLevel, availableEquipment)
                                   3. Compute first unanswered step (skip pre-filled)
                                   4. Create dialog row in DB
                                   5. Return question + options
                                             │
                                   ◀── DialogStepResponse

Client ──POST /workout-dialog/:id/answer──▶ WorkoutDialogController
                                                │
                                      1. Load dialog from DB
                                      2. Validate + apply answer to collectedParams
                                      3. Compute next step (skip non-applicable)
                                      4. If complete → return params
                                         Else → return next question
                                                │
                                       ◀── DialogStepResponse | DialogCompleteResponse

Client ──GET /workout-dialog/:id──▶ Resume dialog after app restart
```

**SQL для диалога:**
```sql
-- Create
INSERT INTO workout_dialogs (id, user_id, current_step, plan_type, collected_params)
VALUES ($1, $2, $3, $4, $5);

-- Update step
UPDATE workout_dialogs SET current_step = $2, plan_type = $3, collected_params = $4, updated_at = NOW()
WHERE id = $1;

-- Read
SELECT * FROM workout_dialogs WHERE id = $1;
```

### 11. Weight History (Read-Write через UsersModule)

```
Client ──GET /users/weight-history──▶ UsersController
                                           │
                                 UsersService.getWeightHistory()
                                           │
                              UsersSqlRepository.getWeightHistory()
                                           │
                          ──SELECT ... FROM weight_logs──▶ PostgreSQL
```

- Таблица `weight_logs` хранит историю изменений веса
- Запись создаётся автоматически при `PATCH /users/profile` с полем `weight`
- `getWeightHistory(userId, period)` — фильтрация по периоду (`week` = 7 дней, `month` = 30 дней, `all` = всё)
- Ответ содержит `date` (YYYY-MM-DD) и `weight` (kg)

```sql
-- Auto-log при PATCH profile:
INSERT INTO weight_logs (user_id, weight) VALUES ($1, $2) RETURNING ...;

-- Чтение с фильтром:
SELECT id, user_id, weight, created_at FROM weight_logs
WHERE user_id = $1 AND created_at >= NOW() - INTERVAL '7 days'
ORDER BY created_at DESC;
```

### 12. Home Data (агрегация)

```
Client ──GET /home/data──▶ HomeController
                                 │
                       HomeDataService.getHomeData()
                                 │
                     ┌── TrainingPlansRepository.findActiveByUserId()
                     ├── TrainingPlansRepository.findActivePlanSession()
                     └── WorkoutSessionsRepository.findByPlanSessionId()
                                 │
                       ◀── HomeDataResponseDto
```

- `HomeModule` самопробрасывает `TrainingPlansRepository` и `WorkoutSessionsRepository`
- Логика:
  1. Загрузить активный `TrainingPlan` → `findActiveByUserId`
  2. Загрузить активную `TrainingPlanSession` → `findActivePlanSession`
  3. Загрузить `WorkoutSession[]` по `planSessionId` → `findByPlanSessionId`
  4. Отфильтровать сессии по неделе (вычисление даты из `dayOfWeek` + `weekStart`)
  5. `todaySession` — сессия на сегодняшний день недели
  6. `currentWeek` — из `TrainingPlanSession.currentWeek`
  7. `description` — маппинг `sessionType` → русское описание

### 13. Session Complete + Set Planning

```
Client ──POST /workout-sessions/:id/complete──▶ WorkoutSessionsController
                                                    │
                                          WorkoutSessionsService.complete()
                                                    │
                                       1. Validate session status = planned
                                       2. Validate at least 1 actual set
                                                    │
                                       WorkoutSessionsSqlRepository.completeSession()
                                       ──UPDATE workout_sessions SET status='completed'──▶ PostgreSQL
                                       ──UPDATE workout_session_sets SET actual_* ──▶ PostgreSQL
                                                    │
                                       SetPlannerService.planSetsForSession()
                                       ──findExerciseHistory()──▶ workout_session_sets (last 5)
                                       ──predict working weight from e1RM + RPE + progression
                                       ──INSERT INTO workout_session_sets (planned)──▶ PostgreSQL
```

- Actual-данные отправляются разом при complete (не per-set)
- SetPlanner триггерится автоматически для следующей planned-сессии
- Для compound: warmup (20kg×15, 50%×10, 75%×8) + working sets
- Для cardio (locomotion): 1 set с duration + distance

```sql
-- Завершение сессии:
UPDATE workout_sessions SET status = 'completed' WHERE id = $1;
UPDATE workout_session_sets SET actual_weight_kg = $3, actual_reps = $4, actual_rpe = $7, completed_at = NOW()
  WHERE session_id = $1 AND exercise_slug = $2 AND set_number = $8;

-- Предсказание рабочего веса:
SELECT actual_weight_kg, actual_reps, actual_rpe FROM workout_session_sets s
  JOIN workout_sessions ws ON ws.id = s.session_id
  WHERE ws.user_id = $1 AND s.exercise_slug = $2 AND ws.status = 'completed'
    AND s.actual_weight_kg IS NOT NULL AND s.set_type = 'working'
  ORDER BY s.completed_at DESC LIMIT 5;
```

### 14. Auto-Skip Cron

```
┌──────────── Cron (EVERY_DAY_AT_MIDNIGHT) ─────────────┐
│                                                         │
│  AutoSkipCron.handleStalePlannedSessions()              │
│     │                                                   │
│     ├── findStalePlanned()                              │
│     │   WHERE status = 'planned' AND day_of_week < today│
│     │                                                   │
│     └── For each: skipSession(id, autoSkipped=true)     │
│         UPDATE workout_sessions SET status = 'skipped'  │
│         metadata.autoSkipped = true                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

- Запускается ежедневно в полночь через `@nestjs/schedule`
- Сессии с `status = 'planned'` и прошедшим `day_of_week` → auto-skipped
- `metadata.autoSkipped = true` отличает auto-skip от ручного

### 15. Chat (AI Trainer + Workout Creation)

```
Client ──POST /chat/sessions──▶ ChatController
                                      │
                            ChatService.createSession()
                                      │
                            ┌── mode=chat → create session only
                            └── mode=workout → create session
                                  + WorkoutDialogService.startDialog()
                                  + save first step as assistant message
                                      │
                               ◀── ChatSession
```

```
Client ──POST /chat/sessions/:id/messages──▶ ChatController
                                                   │
                                         ChatService.sendMessage()
                                                   │
                                   1. Save user message (role=user)
                                                   │
                                   ┌── mode=chat:
                                   │   MockLLMProvider.generateResponse()
                                   │   - keyword matching against FITNESS_KNOWLEDGE
                                   │   - userContext from profile (goal, level)
                                   │   Save assistant message
                                                   │
                                    └── mode=workout:
                                        WorkoutDialogService.answerStep(dialogId, content)
                                        - single_choice validation: invalid → repeat question
                                        - try/catch: errors logged, user gets friendly message
                                        Save assistant message with dialog metadata
                                        If dialog complete → return workoutResult params
                                                    │
                                         ◀── SendMessageResponse (includes mode directly)
```

```
Client ──PATCH /chat/sessions/:id/mode──▶ ChatController
                                                 │
                                       ChatService.switchMode()
                                                 │
                                       ┌── to workout → start new dialog
                                       │   + save system message (mode switched)
                                       │   + save first dialog step as assistant
                                       │
                                       └── to chat → clear dialog link
                                                 │
                                        ◀── ChatSession
```

**SQL для чата:**
```sql
-- Sessions:
SELECT id, user_id, mode, dialog_id, title, created_at, updated_at
  FROM chat_sessions WHERE user_id = $1 ORDER BY created_at DESC;
INSERT INTO chat_sessions (id, user_id, mode, title) VALUES ($1,$2,$3,$4) RETURNING ...;
UPDATE chat_sessions SET mode=$2, dialog_id=$3, title=$4, updated_at=NOW() WHERE id=$1 RETURNING ...;
DELETE FROM chat_sessions WHERE id = $1;

-- Messages:
SELECT id, session_id, role, content, metadata, created_at
  FROM chat_messages WHERE session_id = $1 ORDER BY created_at ASC;
INSERT INTO chat_messages (id, session_id, role, content, metadata) VALUES ($1,$2,$3,$4,$5) RETURNING ...;
```

- Chat module imports `WorkoutDialogModule` (which exports `WorkoutDialogService`)
- `MockLLMProvider` implements `ILLMProvider` interface — keyword matching against ~22 fitness topics
- `ILLMProvider` is a Symbol-injected provider (`LLM_PROVIDER`) — easy to swap for real LLM later
- Full message history stored in `chat_messages` — no truncation
- Dialog steps in workout mode stored as messages with `metadata: { type: 'dialog_step', step, options, ... }`

---

## Среда выполнения: переменные окружения

```env
DATABASE_URL=postgresql://user:password@localhost:5432/fitness_app
```

---

## Пул соединений

```
┌─────────────────────────────────┐
│         pg.Pool                 │
│  max: 20 connections            │
│  idleTimeoutMillis: 30000       │
│  connectionTimeoutMillis: 2000  │
│                                 │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐  │
│  │ c1 │ │ c2 │ │ c3 │ │... │  │
│  └────┘ └────┘ └────┘ └────┘  │
└─────────────────────────────────┘
        ▲           ▼
   DatabaseService.query(sql, params)
        ▲           ▼
   *SqlRepository methods
```

---

## Статические файлы: media

```
Client ──GET /media/trmte8s.gif──▶ NestJS (express.static middleware)
                                       │
                                  ┌────▼─────────────┐
                                  │ backend/media/    │
                                  │   trmte8s.gif     │
                                  │   ... (~1500)     │
                                  └──────────────────┘
```

Поле `gifUrl` в ответе API генерируется как `${APP_URL}/media/${exerciseId}.gif` (в `exercises.service.ts`).
