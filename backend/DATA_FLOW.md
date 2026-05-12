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

### 2. Упражнения (Read-Only, фильтрация)

- Пагинированный поиск с динамическими фильтрами (equipments, contraindications, targetMuscles, search)
- `findForMILP()` — единый SQL-запрос для загрузки всех упражнений с metadata для MILP
- Поиск похожих (same target muscles) и антагонистов (antagonist muscles)

### 3. Пользователи (Read-Write)

- Авторизация по deviceId → JWT
- Профиль: name, gender, weight, height, age, contraindications
- `metadata`: goal, experienceLevel, availableEquipment, recoveryCapacity и т.д.

```sql
SELECT id, device_id, name, gender, weight, height, age, contraindications, metadata, created_at
FROM users WHERE id = $1;
```

### 4. Workout MILP — генерация одной тренировки

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

### 5. Weekly Plan — генерация плана на неделю

```
Client ──POST /workout-milp/weekly-plan──▶ WorkoutMilpController
                                                │
                                      1. Load user (gender)
                                                │
                                      WeeklyProcessMilpService.generateWeeklyPlan()
                                                │
                                      2. selectSplit(count, level, goal) → SplitStrategy
                                         - SPLIT_STRATEGIES matrix
                                         - Goal modifiers (rehab→Full Body)
                                                │
                                      3. assignDays(availableDays, sessionCount)
                                         - Best-spaced subset or evenly spaced
                                                │
                                      4. computeWeeklyVolumeBudget(level)
                                         - MUSCLE_WEEKLY_VOLUME_TARGETS × weeklyVolumeScale
                                                │
                                      For each session:
                                        5. deriveSessionParams() — focus muscles, exercise count
                                           from SESSION_MUSCLE_FOCUS + volume budget
                                        6. Call workoutMilpService.generateWorkout()
                                           with per-session focus + accumulated volume
                                        7. Update accumulatedVolume, fatigueByMuscle, usedExercises
                                                │
                                      8. Save TrainingBlock + WorkoutSessions to DB
                                                │
                                       ◀── WeeklyProcessOutput
```

### 6. Workout Dialog — диалоговый сбор параметров

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

Поле `gifUrl` в ответе API содержит относительный путь `/media/{exerciseId}.gif`.
