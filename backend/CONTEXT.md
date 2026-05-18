# CONTEXT: MILP Workout Planning

## Purpose
Document the current state of Workout MILP implementation, the solved problems, and remaining tasks.

## Current State — Implemented

### Single Workout Generation (`POST /workout-milp/generate`)
- MILP solver with goal-driven rep ranges, variable sets (compound/isolation), experience-based volume
- Gender-aware exercise selection (female: glutes/hamstrings boost; male: chest/shoulders/lats boost)
- Weekly volume tracking — muscles at/above weekly max get deprioritized
- Session-type detection (upper/lower/push/pull/full_body) from focus muscles
- Focus group minimum constraints (chest/back/legs: 2 exercises minimum)
- 4-phase greedy fallback when LP solver fails
- Fatigue decay between sessions (exponential, λ=0.345)
- Diversity through `usedExercises` window
- Contraindication filtering (forbidden=exclude, not_recommended=penalty, low_weight=soft penalty)

### Weekly Plan Generation (`POST /workout-milp/weekly-plan`)
- Auto split selection matrix (trainingCount × experienceLevel → Full Body / Upper-Lower / PPL / etc.)
- Goal modifiers: `weight_loss`, `endurance`, `rehab`, `mobility` shift toward Full Body sessions
- Per-session muscle focus derived from `SESSION_MUSCLE_FOCUS` (primary + secondary muscles per slot)
- Cross-session volume tracking prevents overtraining
- Gender-aware mandatory muscles (female: extra glutes/hamstrings in lower-body sessions)
- Fatigue accumulation with decay between days
- Exercise diversification across sessions within the week

### Dialog System (`POST /workout-dialog/*`)
- 8-step conversational API for collecting workout generation parameters
- Stateful dialog stored in `workout_dialogs` DB table
- Auto-skip steps where user profile already has answers (goal, experienceLevel, availableEquipment)
- Different flows for `generate` vs `weekly` plan type
- Returns collected params at completion — client calls generate/weekly-plan separately

### Home Data (`GET /home/data`)
- Composite endpoint for mobile app home screen
- Aggregates active TrainingBlock + week sessions + today session
- `currentWeek` computed from block ID (base36 decode of Date.now timestamp)
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
- New table `workout_session_sets` — per-set planned + actual data (weight, reps, duration, distance, RPE)
- `SetPlannerService` generates planned sets when session is created:
  - Compound exercises (squat/press/pull/hinge/row/lunge): 3 warmup sets (bar × 15, 50% × 10, 75% × 8) + working sets
  - Isolation: working sets only, no warmup
  - Cardio (locomotion pattern): 1 set with duration + distance
  - Bodyweight exercises: planned_weight = user's bodyweight from profile
- Weight prediction: e1RM from last 5 completed sessions, progression +2.5/+5 kg if RPE ≤ 7, no change if RPE ≥ 9
- Flow: MILP creates week sessions → SetPlanner plans sets for first planned → user completes (POST /:id/complete) → SetPlanner plans next planned
- Auto-skip cron (midnight daily): stale planned sessions → status = skipped
- Skip with reschedule: duplicate session on next available day
- Statuses: planned → completed / skipped / replaced

## Key Constants (in `workout-milp.service.ts`)

| Constant | Purpose |
|----------|---------|
| `EXPERIENCE_PRESETS` | exerciseCount, setsPerExercise, restSec, weeklyVolumeScale per level |
| `SETS_BY_ROLE` | compound=3/4/4, isolation=2/3/3 per level |
| `SETS_GOAL_MODIFIER` | ±1 sets per goal type |
| `GOAL_REP_RANGES` | rep ranges: strength 1-5, hypertrophy 6-12, endurance 15-25 |
| `GOAL_CONFIG` | restSec, setsMultiplier, exerciseTypeBonus/Penalty per goal |
| `MUSCLE_WEEKLY_VOLUME_TARGETS` | min/max weekly sets for ~19 muscles |
| `MUSCLE_HIERARCHY` | group → children with priorities (e.g. arms→biceps:0.9, triceps:0.9) |
| `SESSION_TARGETS` / `SESSION_DEPRIORITIZE` | session-type-aware muscle targeting |
| `MUSCLE_NORMALIZATION` | ~50 DB aliases → canonical slugs |

## Solved Problems

1. **Accessory dominance** — stretching/mobility exercises get ×0.4 weight in strength sessions
2. **Chest/back underrepresentation** — session-aware scoring, focus group minimums enforce ≥2 exercises
3. **Gender blindness** — female: glutes/hamstrings/adductors ×1.3 bonus; male: chest/shoulders/lats ×1.2
4. **No rep ranges** — `GOAL_REP_RANGES` maps goal → default reps per set
5. **Uniform sets** — variable sets: compounds get 3-5, isolation gets 2-3 per exercise type
6. **No weekly volume awareness** — `computeWeeklyVolume()` tracks sets per muscle, overtrained muscles get ×0.3
7. **No split selection** — `SPLIT_STRATEGIES` matrix auto-selects based on count × experience × goal
8. **Parameter collection UX** — Dialog API guides user through 8 questions, skips known profile data

## Remaining Tasks

1. Broader testing with real DB data — validate workout quality across more scenarios
2. Replace single exercise N+1 in `computeFatigueAndHistory` — currently queries exercise metadata per exercise
3. Populate `equipments.description` / `equipments.image_url` with real data (columns exist, values are `null`)
4. Integrate ML model for weight prediction (see SET_PLANNER_ROADMAP.md)
5. Fatigue-aware weight adjustment in SetPlanner (applyFatigueAdjustment is a stub)

## Validation Criteria (all passing)
1. Given a chest/back focus → chest and back appear in result
2. Lower-body sessions do not get pulled toward chest/back bonuses
3. Stretching/mobility do not dominate strength outputs
4. LP solver and fallback paths are distinguishable (`usedFallback` flag)
5. Total plan uses most of available time when feasible
6. 6/6 e2e tests pass

## Notes
- Do not use a universal chest/back bonus — session-aware scoring only
- `workout_sessions` table has no `created_at` column — `findRecentCompletedByUserId` does not filter by date
- `body weight` (with space) is the exact alias in the DB `equipments` table
- Server runs on port 3001 (from `.env`), not 3000
- Database name: `fitness_app`
- `users.gender` column is used in code but missing from `schema.sql` — likely added via a separate migration
- `GENDER_FOCUS_RATIO` constant does not exist — was removed or never added
- `POST /workout-milp/metrics` is fully implemented — calls `milpService.computeMetrics()`
- `workout_session_sets` table stores per-set planned + actual data, separate from `workout_session_exercises` (session structure)
- SetPlanner uses `movement_pattern` to determine compound vs isolation (squat/press/pull/hinge/row/lunge = compound)
- Bodyweight exercises: `planned_weight_kg` = `user.weight`, `actual_weight_kg` = bodyweight + added weight
- `@nestjs/schedule` added as dependency for auto-skip cron
