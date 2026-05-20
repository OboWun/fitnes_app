# Iteration Data

Этот документ описывает, какие данные нужно вставлять в каждую итерацию MILP-внедрения. Формулировки даны как практический фитнес-контекст и частично опираются на `backend/refs/hybrid_model.ipynb`.

## Итерация 1: Обогатить данные для одной тренировки — ✅ ЗАВЕРШЕНА

**Статус:** Реализовано в `workout-milp.service.ts`.

**Что сделано:**
- Все `Exercise.metadata` поля заполнены (complexityScore, fatigueCost, timeCostSec, riskLevel, jointStress, primaryMuscleWeights, secondaryMuscleWeights, phaseAffinity, variationGroup)
- `User.metadata.goal`, `experienceLevel`, `availableEquipment` используются при генерации
- LP solver (`javascript-lp-solver`) + 4-фазный greedy fallback
- Goal → rep ranges: 9 целей (strength 1-5, hypertrophy 6-12, endurance 15-25, weight_loss 10-15, glute_growth 6-20, recomposition 8-15, general_health 8-15, rehab 12-20, mobility 10-20)
- Experience → exercise count, sets, rest
- Variable sets: compound (3-5) vs isolation (2-3)
- Gender-aware weights (female: glutes/hamstrings ×1.3, glute_growth ×1.7; male: chest/shoulders ×1.2)
- Age-aware: AGE_VOLUME_SCALE, AGE_REST_MODIFIER
- BMI-aware scoring: BMI>30 bodyweight ×0.7, BMI<18.5 high-impact ×0.8
- glute_growth: auto-add mandatory muscles (glutes/hamstrings/adductors/abductors), force legs focus
- Weekly volume tracking: overtrained muscles deprioritized
- Session-type detection: upper/lower/push/pull/full_body
- Focus group minimums (chest/back/legs ≥ 2 exercises)
- 43/43 tests passing

## Итерация 2: Обогатить данные для недельного процесса — ✅ ЗАВЕРШЕНА

**Статус:** Реализовано в `weekly-process-milp.service.ts`.

**Что сделано:**
- `TrainingPlan` + `TrainingPlanSession` + `WorkoutSession` entities (заменили TrainingBlock)
- Split selection matrix (`SPLIT_STRATEGIES`): trainingCount × experienceLevel → Full Body / Upper-Lower / PPL
- `SplitType` enum: auto / full_body / upper_lower / ppl
- Goal modifiers: weight_loss/endurance/rehab/mobility → Full Body bias; glute_growth → mandatory muscles
- `SESSION_MUSCLE_FOCUS`: primary/secondary muscles per session type (push/pull/legs/upper/lower/full_body)
- Per-session volume distribution from `MUSCLE_WEEKLY_VOLUME_TARGETS`
- Cross-session volume tracking (accumulatedVolume)
- Fatigue decay between days (λ=0.345)
- Exercise diversification across sessions within the week
- Gender-aware mandatory muscles (female: extra glutes/hamstrings in lower sessions)
- Age + activity-aware volume budget: AGE_VOLUME_SCALE × ACTIVITY_VOLUME_SCALE
- Auto-derived compoundSets/isolationSets from experience + goal
- Nullable fields: availableDays, trainingCountPerWeek, sessionDurationMin (null = auto)
- `POST /workout-milp/weekly-plan` endpoint with auto split selection, returns `planId`

## Итерация 3: Замена существующей тренировки — ⏳ НЕ НАЧАТА

**Что нужно:** `WorkoutSession.metadata` (previousSessionId, nextSessionId, sessionLoadByMuscle, mandatoryMuscles, forbiddenExercises, allowedTimeDeviationMin, allowedLoadDeviation). Логика recency, similarity, fatigue-aware replacement.

## Итерация 4: Зафиксировать числовые коэффициенты — ✅ ЗАВЕРШЕНА

**Статус:** Все коэффициенты из hybrid_model.ipynb реализованы как константы в `workout-milp.service.ts`.

**Что сделано:**
- α₁=1.5, α₂=0.5, α₃=2.0, δ=0.2, ε=0.2, θ=1.5, λ=0.345, diversity_window=4
- Severity маппинг: forbidden=0.0, not_recommended=0.5, low_weight=0.8
- GOAL_CONFIG с restSec, setsMultiplier, exerciseTypeBonus/Penalty (9 целей)
- MUSCLE_WEEKLY_VOLUME_TARGETS для ~20 мышц (min/max weekly sets)
- EXPERIENCE_PRESETS с weeklyVolumeScale (beginner=0.6, intermediate=1.0, advanced=1.4)
- SETS_BY_ROLE + SETS_GOAL_MODIFIER для variable sets (9 целей)
- AGE_VOLUME_SCALE (<25:1.1, 25-40:1.0, 40-55:0.85, >55:0.7)
- AGE_REST_MODIFIER (<40:1.0, 40-55:1.1, >55:1.2)
- ACTIVITY_VOLUME_SCALE (sedentary:0.7, light:0.85, moderate:1.0, active:1.1)

## Итерация 5: Per-Set Tracking + Set Planner — ✅ ЗАВЕРШЕНА

**Статус:** Реализовано в `workout-sessions/set-planner.service.ts`, `workout-sessions-sql.repository.ts`, `workout-sessions.controller.ts`.

**Что сделано:**
- `workout_session_sets` таблица — per-set planned + actual (weight_kg, reps, duration_sec, distance_m, rpe)
- `SetPlannerService` — генерация planned-сетов при создании сессии:
  - Compound (squat/press/pull/hinge/row/lunge): 3 warmup + N working sets
  - Isolation: working sets only
  - Cardio (locomotion): 1 set с duration + distance
  - Bodyweight: planned_weight = user.weight
- Weight prediction: e1RM из последних 5 completed сессий
- Progression: RPE ≤ 7 → +2.5/+5 kg, RPE ≥ 9 → -1.25/-2.5 kg
- BMI-based default weight: BMI > 30 → ×1.2, BMI < 18.5 → ×0.85
- `POST /workout-sessions/:id/complete` — actual-данные разом, триггер SetPlanner для следующей
- `POST /workout-sessions/:id/skip` — с опциональным reschedule на другой день
- Auto-skip cron: устаревшие planned → skipped (ежедневно в полночь)
- Response DTO обогащён `setDetails[]` для каждого упражнения
- MILP интеграция: SetPlanner вызывается для первой сессии при weekly plan

**Связь с Direction B (Performance Log):**
- `workout_session_sets` с actual-данными — основа для future ML-модели предсказания весов
- `findExerciseHistory()` уже собирает последние 5 completed сетов
- `applyFatigueAdjustment()` — stub для будущей интеграции ML-модели

## Итерация 6: Chat + AI Trainer — ✅ ЗАВЕРШЕНА (MVP)

**Статус:** Реализовано в `src/chat/`.

**Что сделано:**
- `chat_sessions` + `chat_messages` таблицы — полная история сообщений
- Два режима в одном чате: `chat` (свободный разговор) и `workout` (генерация тренировки)
- Mode switching: `PATCH /chat/sessions/:id/mode` — chat ↔ workout
- `ILLMProvider` interface + `LLM_PROVIDER` Symbol для DI
- `MockLLMProvider` — keyword matching против ~22 фитнес-статей
- Темы: похудение, набор массы, белок, частота тренировок, крепатура, сплиты, разминка, метаболизм, плато, кардио, начинающим, питание, техника, перетренированность, домашние тренировки, сила, ягодицы, рельеф, сон, возраст, травмы, мотивация, мобильность
- Chat mode: MockLLM получает контекст пользователя (цель, уровень) из профиля
- Workout mode: делегирует к `WorkoutDialogService` — каждый шаг сохраняется как сообщение
- При завершении диалога: возвращает `workoutResult` с параметрами для generate/weekly-plan
- 6 endpoints: create session, list sessions, get session + messages, delete, send message, switch mode
- `WorkoutDialogModule` экспортирует `WorkoutDialogService` для ChatModule

**Что не сделано (future):**
- Замена MockLLM на настоящую LLM (Azure OpenAI / OpenAI / локальная модель)

## Итерация 6.5: Архитектурные исправления — ✅ ЗАВЕРШЕНА

**Статус:** Исправлены критические баги в MILP flow, TrainingPlan, Chat.

**Что сделано:**
- **DB миграция**: `block_id` DROP NOT NULL, stale FK удалён, `plan_session_id` добавлен
- **MILP weekly-plan рефакторинг**: вместо прямого создания WorkoutSession/PlanSession — создаёт WorkoutTemplate[] + TrainingPlan с schedule (`isActive: false`). Клиент вызывает activate для создания сессий из шаблонов
- **createWorkoutSessionFromSchedule**: читает упражнения из WorkoutTemplate по `scheduleItem.workoutTemplateId`
- **TrainingPlansModule**: добавлен `WORKOUT_TEMPLATES_REPOSITORY`
- **Активное редактирование плана**: `update()` работает для активных планов; изменение расписания удаляет `planned` сессии и пересоздаёт из нового schedule
- **Chat fix 500**: `workout_dialogs.plan_type` расширен с `varchar(10)` до `varchar(30)` — русский текст вызывал SQL error
- **Dialog validation**: `single_choice` шаги повторяют вопрос при невалидном ответе
- **Chat try/catch**: ошибки диалога логируются (Logger), пользователь видит дружелюбное сообщение
- **sendMessage оптимизация**: `mode` возвращается напрямую из session, без лишнего `getSession()` вызова
- **Cleanup**: `training-block.entity.ts` удалён (entity + export из index.ts), `blockId` убран из repository interface
- **NestJS Logger** добавлен в: WeeklyProcessMilpService, WorkoutMilpService, HomeDataService, ChatService
- 44/44 тестов, сборка чистая

## Итерация 7: Адаптивный контур обновления модели — ⏳ НЕ НАЧАТА

**Что нужно:** история завершённых тренировок, RPE, soreness, readiness, pain, technique, фактический объём и длительность. Пересчёт priors после каждой недели.
