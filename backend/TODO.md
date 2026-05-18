# TODO: Backend endpoints for mobile app

## Completed

- [x] GET /home/data — составной endpoint для главной страницы
- [x] GET /weight-history — история изменений веса
- [x] GET /workout-sessions improvements — query params (limit, status, sort)
- [x] BUG: POST /auth/device не возвращает gender
- [x] Enrich GET /equipments — description, imageUrl

## In Progress

- [ ] Workout Session Logging + Set Planner
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
  - [ ] ML model for weight prediction (see SET_PLANNER_ROADMAP.md)
  - [ ] Fatigue-aware weight adjustment (applyFatigueAdjustment stub)
