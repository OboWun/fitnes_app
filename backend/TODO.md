# TODO: Backend endpoints for mobile app

## Completed

- [x] GET /home/data — составной endpoint для главной страницы
- [x] GET /weight-history — история изменений веса
- [x] GET /workout-sessions improvements — query params (limit, status, sort)
- [x] BUG: POST /auth/device не возвращает gender
- [x] Enrich GET /equipments — description, imageUrl

### Workout Session Logging + Set Planner
- [x] SQL: `workout_session_sets` table
- [x] Entity: `WorkoutSessionSet` with measurement types
- [x] Repository: planSets, completeSession, getSets, findNextPlanned, findStalePlanned, findExerciseHistory
- [x] DTOs: CompleteSessionDto, SkipSessionDto, SetResponseDto
- [x] SetPlanner service: warmup generation, weight prediction from history, progression
- [x] Service: complete(), skip(), reschedule()
- [x] Controller: POST /:id/complete, POST /:id/skip
- [x] Response DTO: setDetails[] in exercises
- [x] MILP integration: SetPlanner called after first session creation
- [x] Auto-skip cron: stale planned sessions at midnight
- [x] BMI-based default weight (BMI>30 ×1.2, BMI<18.5 ×0.85)

### Training Plan System
- [x] Tables: `training_plans`, `training_plan_schedule`, `training_plan_sessions`
- [x] Full CRUD: create, update (active + inactive), delete (inactive only), get all, get one
- [x] Active plan editing: schedule changes delete planned sessions and recreate
- [x] Activate: creates TrainingPlanSession (4 weeks) + first WorkoutSession from template + SetPlanner
- [x] Archive: deactivates plan, archives active session
- [x] Assign/unassign workout template to day of week
- [x] Replace workout for planned session
- [x] Removed TrainingBlock module entirely

### MILP Goals & Personalization
- [x] New goals: `glute_growth` ("Накачать ягодицы"), `recomposition` ("Рельеф / подтянутое тело")
- [x] 9 training goals: strength, hypertrophy, endurance, weight_loss, general_health, rehab, mobility, glute_growth, recomposition
- [x] GOAL_CONFIG for all 9 goals with restSec, setsMultiplier, exerciseTypeBonus/Penalty
- [x] GOAL_REP_RANGES for all 9 goals
- [x] SETS_GOAL_MODIFIER for all 9 goals
- [x] weight_loss fix: `exerciseTypePenalty: []` (силовые не штрафуются), `restSec: 45`
- [x] endurance fix: `exerciseTypePenalty: ['plyometric']` (removed strength)
- [x] Age-based modifiers: AGE_VOLUME_SCALE, AGE_REST_MODIFIER, age>50 → plyometric ×0.5, stability ×1.2
- [x] BMI-based scoring: BMI>30 → bodyweight ×0.7, BMI<18.5 → high-impact ×0.8
- [x] glute_growth logic: auto-add mandatory muscles, female ×1.7 / male ×1.5, force legs focus
- [x] Controller: passes age/height/weight from user profile, primaryLifts/cardioPreference/enduranceType

### Dialog System
- [x] 16-step dialog with conditional routing
- [x] Advanced settings gate: "Рекомендуемые" vs "Настроить вручную"
- [x] Goal-specific routing: cardio_preference, primary_lifts, endurance_type, target_weight
- [x] Auto options for frequency, duration (null → MILP auto-derives)
- [x] 9 goal options in dialog
- [x] DTOs: GenerateWorkoutDto + GenerateWeeklyPlanDto with nullable fields

### Chat System
- [x] Tables: `chat_sessions`, `chat_messages`
- [x] Entities: ChatSession, ChatMessage
- [x] Repositories: ChatSessionsSqlRepository, ChatMessagesSqlRepository
- [x] ILLMProvider interface + LLM_PROVIDER Symbol token
- [x] MockLLMProvider with ~22 fitness knowledge articles (keyword matching)
- [x] ChatService: mode routing (chat → MockLLM, workout → WorkoutDialogService)
- [x] ChatController: 6 endpoints (create, list, get, delete, send message, switch mode)
- [x] ChatModule with DI wiring, imports WorkoutDialogModule
- [x] Full message history in DB (chat_messages table)
- [x] single_choice validation in dialog: invalid answers repeat question
- [x] try/catch with Logger in ChatService.sendMessage
- [x] sendMessage returns mode directly (no redundant DB query)

### Weekly MILP
- [x] SplitType enum: auto/full_body/upper_lower/ppl
- [x] OPTIMAL_FREQUENCY + DEFAULT_SESSION_DURATION for glute_growth/recomposition
- [x] computeWeeklyVolumeBudget uses age + activity level
- [x] deriveSessionParams for glute_growth (force legs focus)
- [x] Creates WorkoutTemplates per day + TrainingPlan with schedule (isActive: false), returns planId
- [x] Client calls activate to create PlanSession + WorkoutSessions from templates

## In Progress

- [ ] Session blocks (cardio warmup wrap-model) for weight_loss
- [ ] Weekly cardio distribution (60% sessions with cardio)

## Remaining

- [ ] Replace MockLLM with real LLM provider (Azure OpenAI / OpenAI / local)
- [ ] ML model for weight prediction (see SET_PLANNER_ROADMAP.md)
- [ ] Fatigue-aware weight adjustment (applyFatigueAdjustment stub)
- [ ] Broader testing with real DB data
- [ ] Replace single exercise N+1 in computeFatigueAndHistory
- [ ] Populate equipments.description / equipments.image_url
- [ ] Remove stale ScheduledWorkout from workout-template.entity.ts
- [ ] Remove training_blocks and scheduled_workouts tables from DB
- [ ] Read UserMetadata fields: preferredExercises, dislikedExercises, trainingAgeMonths, etc.
