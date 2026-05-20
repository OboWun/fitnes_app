# CONTEXT: MILP Workout Planning

## Purpose
Document the current state of Workout MILP implementation, the solved problems, and remaining tasks.

## Current State — Implemented

### Single Workout Generation (`POST /workout-milp/generate`)
- MILP solver with goal-driven rep ranges, variable sets (compound/isolation), experience-based volume
- 9 training goals: strength, hypertrophy, endurance, weight_loss, general_health, rehab, mobility, glute_growth, recomposition
- Gender-aware exercise selection (female: glutes/hamstrings boost; male: chest/shoulders/lats boost)
- Age-based volume scaling (AGE_VOLUME_SCALE) and rest modifier (AGE_REST_MODIFIER)
- BMI-based scoring: obese → bodyweight ×0.7; underweight → high-impact ×0.8
- glute_growth: auto-add glutes/hamstrings/adductors/abductors to mandatory, female ×1.7 / male ×1.5
- Weekly volume tracking — muscles at/above weekly max get deprioritized
- Session-type detection (upper/lower/push/pull/full_body) from focus muscles
- Focus group minimum constraints (chest/back/legs: 2 exercises minimum)
- 4-phase greedy fallback when LP solver fails
- Fatigue decay between sessions (exponential, λ=0.345)
- Diversity through `usedExercises` window
- Contraindication filtering (forbidden=exclude, not_recommended=penalty, low_weight=soft penalty)
- `activityLevel`, `cardioPreference`, `primaryLifts`, `enduranceType` passed from controller

### Weekly Plan Generation (`POST /workout-milp/weekly-plan`)
- Auto split selection matrix (trainingCount × experienceLevel → Full Body / Upper-Lower / PPL / etc.)
- `SplitType` enum: auto / full_body / upper_lower / ppl
- Goal modifiers: `weight_loss`, `endurance`, `rehab`, `mobility` shift toward Full Body sessions
- Per-session muscle focus derived from `SESSION_MUSCLE_FOCUS` (primary + secondary muscles per slot)
- Cross-session volume tracking prevents overtraining
- Gender-aware mandatory muscles (female: extra glutes/hamstrings in lower-body sessions)
- Fatigue accumulation with decay between days
- Exercise diversification across sessions within the week
- Nullable fields: `availableDays`, `trainingCountPerWeek`, `sessionDurationMin` — null = auto
- **Creates WorkoutTemplate per day** + TrainingPlan with schedule (`isActive: false`, `source='milp'`)
- Client calls `POST /training-plans/:id/activate` to create PlanSession + first WorkoutSession
- `targetWeightKg` for weight_loss goal tracking

### Training Plan System (`/training-plans`)
- Replaced TrainingBlock module entirely
- Tables: `training_plans`, `training_plan_schedule`, `training_plan_sessions`
- Full CRUD: create, update, delete, get all, get one
- **Active plan editing**: update name or schedule for active plans; schedule changes delete all `planned` sessions and recreate from first day
- Delete still blocked for active plans (archive first)
- Activate: deactivates others → creates TrainingPlanSession (4 weeks) + first WorkoutSession from template exercises + SetPlanner
- Archive: deactivates plan, archives active session
- Assign/unassign workout template to day of week
- Replace workout for planned session
- Only 1 active plan per user
- `source`: `'manual'` or `'milp'`
- `createWorkoutSessionFromSchedule()` reads exercises from WorkoutTemplate via `WORKOUT_TEMPLATES_REPOSITORY`

### Dialog System (`POST /workout-dialog/*`)
- 16-step conversational API with conditional routing
- Steps: plan_type → goal → experience → focus_muscles → equipment_preset → equipment → frequency → days → duration → advanced_settings → [split, activity_level, cardio_preference, primary_lifts, endurance_type, target_weight]
- Advanced settings gate: "Рекомендуемые" → skip advanced, "Настроить вручную" → goal-specific steps
- Goal-specific routing: cardio_preference (weight_loss/endurance), primary_lifts (strength/glute_growth), endurance_type (endurance), target_weight (weight_loss)
- Auto options for frequency, duration (null → MILP auto-derives)
- 9 goal options in dialog (including "Накачать ягодицы" and "Рельеф / подтянутое тело")
- Stateful dialog stored in `workout_dialogs` DB table
- Auto-skip steps where user profile already has answers (goal, experienceLevel, availableEquipment)
- Different flows for `generate` vs `weekly` plan type
- Returns collected params at completion — client calls generate/weekly-plan separately

### Chat System (`/chat`)
- Unified chat with two modes: `chat` (free conversation with AI trainer) and `workout` (workout creation via dialog)
- `chat_sessions` table: mode, dialogId (links to workout_dialogs), title (auto from first message)
- `chat_messages` table: full message history (role: user/assistant/system, content, metadata)
- Mode switching: `PATCH /chat/sessions/:id/mode` — chat ↔ workout
- **Chat mode**: MockLLMProvider with ~22 fitness knowledge articles (keyword matching)
  - Topics: weight loss, muscle gain, nutrition, technique, recovery, motivation, splits, metabolism, plateau, etc.
  - `ILLMProvider` interface for future LLM replacement (Azure OpenAI, OpenAI, local model)
- **Workout mode**: delegates to `WorkoutDialogService` — each dialog step saved as chat messages
  - On dialog completion: returns collected params in `workoutResult` metadata
  - `single_choice` validation: invalid answers repeat the current question instead of crashing
  - `try/catch` with Logger: dialog errors logged with stack trace, user gets friendly message
- 6 endpoints: create session, list sessions, get session + messages, delete, send message, switch mode
- `sendMessage` returns `mode` from session directly (no redundant DB query)

### Home Data (`GET /home/data`)
- Composite endpoint for mobile app home screen
- Aggregates active TrainingPlan + week sessions + today session
- Uses `TrainingPlansRepository` (findActiveByUserId, findActivePlanSession)
- Session type → Russian description mapping (push/pull/legs/upper/lower/full_body)

### Weight History (`GET /users/weight-history`)
- `weight_logs` table tracks weight changes over time
- Auto-logged on every `PATCH /users/profile` with `weight` field
- Filterable by period: `week` (7d), `month` (30d), `all`

### Workout Sessions Filtering (`GET /workout-sessions`)
- Query params: `limit`, `status` (CSV), `sort` (`id_desc`/`id_asc`)
- Sorting by `id` (lexicographic ≈ chronological since IDs contain Date.now)
- No `created_at` column in `workout_sessions` table

### Session Logging + Set Planner
- `workout_session_sets` table — per-set planned + actual data (weight, reps, duration, distance, RPE)
- `SetPlannerService` generates planned sets when session is created:
  - Compound exercises (squat/press/pull/hinge/row/lunge): 3 warmup sets (bar × 15, 50% × 10, 75% × 8) + working sets
  - Isolation: working sets only, no warmup
  - Cardio (locomotion pattern): 1 set with duration + distance
  - Bodyweight exercises: planned_weight = user's bodyweight from profile
- Weight prediction: e1RM from last 5 completed sessions, progression +2.5/+5 kg if RPE ≤ 7, no change if RPE ≥ 9
- BMI-based default weight: BMI > 30 → ×1.2, BMI < 18.5 → ×0.85
- Flow: MILP creates week sessions → SetPlanner plans sets for first planned → user completes (POST /:id/complete) → SetPlanner plans next planned
- Auto-skip cron (midnight daily): stale planned sessions → status = skipped
- Skip with reschedule: duplicate session on next available day
- Statuses: planned → completed / skipped / replaced

## Key Constants (in `workout-milp.service.ts`)

| Constant | Purpose |
|----------|---------|
| `EXPERIENCE_PRESETS` | exerciseCount, setsPerExercise, restSec, weeklyVolumeScale per level |
| `SETS_BY_ROLE` | compound=3/4/4, isolation=2/3/3 per level |
| `SETS_GOAL_MODIFIER` | ±1 sets per goal type (9 goals) |
| `GOAL_REP_RANGES` | rep ranges for 9 goals (e.g. glute_growth 6-20, recomposition 8-15) |
| `GOAL_CONFIG` | restSec, setsMultiplier, exerciseTypeBonus/Penalty per goal (9 goals) |
| `AGE_VOLUME_SCALE` | <25:1.1, 25-40:1.0, 40-55:0.85, >55:0.7 |
| `AGE_REST_MODIFIER` | <40:1.0, 40-55:1.1, >55:1.2 |
| `ACTIVITY_VOLUME_SCALE` | sedentary:0.7, light:0.85, moderate:1.0, active:1.1 |
| `MUSCLE_WEEKLY_VOLUME_TARGETS` | min/max weekly sets for ~20 muscles |
| `MUSCLE_HIERARCHY` | group → children with priorities (e.g. arms→biceps:0.9, triceps:0.9) |
| `SESSION_TARGETS` / `SESSION_DEPRIORITIZE` | session-type-aware muscle targeting |
| `MUSCLE_NORMALIZATION` | ~50 DB aliases → canonical slugs |
| `DEFAULT_SESSION_DURATION` | goal+experience → duration mapping |
| `FITNESS_KNOWLEDGE` | ~22 keyword-matched articles for MockLLM (fitness-knowledge.ts) |

## Solved Problems

1. **Accessory dominance** — stretching/mobility exercises get ×0.4 weight in strength sessions
2. **Chest/back underrepresentation** — session-aware scoring, focus group minimums enforce ≥2 exercises
3. **Gender blindness** — female: glutes/hamstrings/adductors ×1.3 bonus; male: chest/shoulders/lats ×1.2
4. **No rep ranges** — `GOAL_REP_RANGES` maps goal → default reps per set (9 goals)
5. **Uniform sets** — variable sets: compounds get 3-5, isolation gets 2-3 per exercise type
6. **No weekly volume awareness** — `computeWeeklyVolume()` tracks sets per muscle, overtrained muscles get ×0.3
7. **No split selection** — `SPLIT_STRATEGIES` matrix auto-selects based on count × experience × goal
8. **Parameter collection UX** — Dialog API: 16 steps with conditional routing, skips known profile data
9. **weight_loss penalty error** — `exerciseTypePenalty: []` (was `['strength','plyometric']`), `restSec: 45` (was 60)
10. **endurance penalty error** — `exerciseTypePenalty: ['plyometric']` (removed strength)
11. **Missing goals** — added `glute_growth` and `recomposition` with full config
12. **Age/BMI blindness** — age-based volume scaling + rest modifier, BMI-based scoring + default weight
13. **TrainingBlock → TrainingPlan** — replaced blocks with plan system (schedule, sessions, activate/archive)
14. **Chat + Workout in one UI** — unified chat module with two modes (chat/workout), full message history, MockLLM with knowledge base
15. **MILP bypassing activate flow** — weekly MILP now creates WorkoutTemplates + schedule, not WorkoutSessions; activate creates sessions from templates
16. **Active plan editing blocked** — update() now works for active plans; schedule changes recreate planned sessions
17. **Chat 500 on Russian text** — `workout_dialogs.plan_type` was `varchar(10)`, expanded to `varchar(30)`; added `single_choice` validation in `answerStep`
18. **block_id NOT NULL crash** — migration: `block_id` DROP NOT NULL, stale FK dropped, `training-block.entity.ts` removed

## Remaining Tasks

1. Session blocks (cardio warmup wrap-model) for weight_loss — NOT implemented yet
2. Weekly cardio distribution (60% sessions with cardio) — NOT implemented
3. Broader testing with real DB data — validate workout quality across more scenarios
4. Replace single exercise N+1 in `computeFatigueAndHistory` — currently queries exercise metadata per exercise
5. Populate `equipments.description` / `equipments.image_url` with real data (columns exist, values are `null`)
6. Integrate ML model for weight prediction (see SET_PLANNER_ROADMAP.md)
7. Fatigue-aware weight adjustment in SetPlanner (applyFatigueAdjustment is a stub)
8. ~~Remove stale `training-block.entity.ts`~~ — DONE, entity and export removed
9. Remove `training_blocks` and `scheduled_workouts` tables from DB
10. ~~Populate `createWorkoutSessionFromSchedule` exercises from WorkoutTemplate~~ — DONE
11. Read UserMetadata fields: preferredExercises, dislikedExercises, trainingAgeMonths, recoveryCapacity, injuryHistory, currentLimitations, preferredMovementPatterns
12. Replace MockLLM with real LLM provider (Azure OpenAI / OpenAI / local model)

## Validation Criteria (all passing)
1. Given a chest/back focus → chest and back appear in result
2. Lower-body sessions do not get pulled toward chest/back bonuses
3. Stretching/mobility do not dominate strength outputs
4. LP solver and fallback paths are distinguishable (`usedFallback` flag)
5. Total plan uses most of available time when feasible
6. 44/44 tests pass

## Notes
- Do not use a universal chest/back bonus — session-aware scoring only
- `workout_sessions` table has no `created_at` column — `findRecentCompletedByUserId` does not filter by date
- `body weight` (with space) is the exact alias in the DB `equipments` table
- Server runs on port 3001 (from `.env`), not 3000
- Database name: `fitness_app`
- `users.gender` column is used in code but missing from `schema.sql` — likely added via a separate migration
- `POST /workout-milp/metrics` is fully implemented — calls `milpService.computeMetrics()`
- `workout_session_sets` table stores per-set planned + actual data, separate from `workout_session_exercises` (session structure)
- SetPlanner uses `movement_pattern` to determine compound vs isolation (squat/press/pull/hinge/row/lunge = compound)
- Bodyweight exercises: `planned_weight_kg` = `user.weight`, `actual_weight_kg` = bodyweight + added weight
- `@nestjs/schedule` added as dependency for auto-skip cron
- `workout_sessions.plan_session_id` references `training_plan_sessions(id)` (added via migration)
- MILP weekly-plan creates WorkoutTemplates + TrainingPlan schedule (not WorkoutSessions); activate creates sessions from templates
- `src/entities/training-block.entity.ts` removed — entity and export from index.ts deleted
- `workout_sessions.block_id` is now nullable, stale FK to `training_blocks` dropped
- Age and BMI are read from user profile (`fullUser.age/height/weight`), not asked in dialog
- "null → MILP считает" philosophy: dialog sends null for auto fields, MILP substitutes optimal values
- NestJS Logger added to: WeeklyProcessMilpService, WorkoutMilpService, HomeDataService, ChatService, TrainingPlansService
- `workout_dialogs.plan_type` expanded from `varchar(10)` to `varchar(30)` to handle Russian text
- `single_choice` validation in `answerStep`: invalid answers repeat the question instead of 500
- `sendMessage` in ChatService returns `mode` directly, no redundant `getSession()` call
