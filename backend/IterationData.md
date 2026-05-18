# Iteration Data

Этот документ описывает, какие данные нужно вставлять в каждую итерацию MILP-внедрения. Формулировки даны как практический фитнес-контекст и частично опираются на `backend/refs/hybrid_model.ipynb`.

## Итерация 1: Обогатить данные для одной тренировки — ✅ ЗАВЕРШЕНА

**Статус:** Реализовано в `workout-milp.service.ts`.

**Что сделано:**
- Все `Exercise.metadata` поля заполнены (complexityScore, fatigueCost, timeCostSec, riskLevel, jointStress, primaryMuscleWeights, secondaryMuscleWeights, phaseAffinity, variationGroup)
- `User.metadata.goal`, `experienceLevel`, `availableEquipment` используются при генерации
- LP solver (`javascript-lp-solver`) + 4-фазный greedy fallback
- Goal → rep ranges (strength 1-5, hypertrophy 6-12, endurance 15-25)
- Experience → exercise count, sets, rest
- Variable sets: compound (3-5) vs isolation (2-3)
- Gender-aware weights (female: glutes/hamstrings ×1.3, male: chest/shoulders ×1.2)
- Weekly volume tracking: overtrained muscles deprioritized
- Session-type detection: upper/lower/push/pull/full_body
- Focus group minimums (chest/back/legs ≥ 2 exercises)
- 6/6 e2e tests passing

## Итерация 2: Обогатить данные для недельного процесса — ✅ ЗАВЕРШЕНА

**Статус:** Реализовано в `weekly-process-milp.service.ts`.

**Что сделано:**
- `TrainingBlock` + `WorkoutSession` entities с metadata
- Split selection matrix (`SPLIT_STRATEGIES`): trainingCount × experienceLevel → Full Body / Upper-Lower / PPL
- Goal modifiers: weight_loss/endurance/rehab/mobility → Full Body bias
- `SESSION_MUSCLE_FOCUS`: primary/secondary muscles per session type (push/pull/legs/upper/lower/full_body)
- Per-session volume distribution from `MUSCLE_WEEKLY_VOLUME_TARGETS`
- Cross-session volume tracking (accumulatedVolume)
- Fatigue decay between days (λ=0.345)
- Exercise diversification across sessions within the week
- Gender-aware mandatory muscles (female: extra glutes/hamstrings in lower sessions)
- Auto-derived compoundSets/isolationSets from experience + goal
- `POST /workout-milp/weekly-plan` endpoint with auto split selection

## Итерация 3: Замена существующей тренировки — ⏳ НЕ НАЧАТА

**Что нужно:** `WorkoutSession.metadata` (previousSessionId, nextSessionId, sessionLoadByMuscle, mandatoryMuscles, forbiddenExercises, allowedTimeDeviationMin, allowedLoadDeviation). Логика recency, similarity, fatigue-aware replacement.

## Итерация 4: Зафиксировать числовые коэффициенты — ✅ ЗАВЕРШЕНА

**Статус:** Все коэффициенты из hybrid_model.ipynb реализованы как константы в `workout-milp.service.ts`.

**Что сделано:**
- α₁=1.5, α₂=0.5, α₃=2.0, δ=0.2, ε=0.2, θ=1.5, λ=0.345, diversity_window=4
- Severity маппинг: forbidden=0.0, not_recommended=0.5, low_weight=0.8
- GOAL_CONFIG с restSec, setsMultiplier, exerciseTypeBonus/Penalty
- MUSCLE_WEEKLY_VOLUME_TARGETS для ~19 мышц (min/max weekly sets)
- EXPERIENCE_PRESETS с weeklyVolumeScale (beginner=0.6, intermediate=1.0, advanced=1.4)
- SETS_BY_ROLE + SETS_GOAL_MODIFIER для variable sets

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
- Progression: RPE ≤ 7 → +2.5/+5 kg, RPE ≥ 9 → без прогрессии
- `POST /workout-sessions/:id/complete` — actual-данные разом, триггер SetPlanner для следующей
- `POST /workout-sessions/:id/skip` — с опциональным reschedule на другой день
- Auto-skip cron: устаревшие planned → skipped (ежедневно в полночь)
- Response DTO обогащён `setDetails[]` для каждого упражнения
- MILP интеграция: SetPlanner вызывается для первой сессии при weekly plan

**Связь с Direction B (Performance Log):**
- `workout_session_sets` с actual-данными — основа для future ML-модели предсказания весов
- `findExerciseHistory()` уже собирает последние 5 completed сетов
- `applyFatigueAdjustment()` — stub для будущей интеграции ML-модели

## Итерация 6: Адаптивный контур обновления модели — ⏳ НЕ НАЧАТА

**Что нужно:** история завершённых тренировок, RPE, soreness, readiness, pain, technique, фактический объём и длительность. Пересчёт priors после каждой недели.
