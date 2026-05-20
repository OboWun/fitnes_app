# WORKOUT-PLAN: Training Plan System

## Overview

Three-level model for workout management:

```
WorkoutTemplate → TrainingPlan → TrainingPlanSession → WorkoutSession
(шаблон)          (недельный       (реализация на      (конкретная
                   шаблон)          4 недели)           тренировка)
```

---

## Entities

### 1. WorkoutTemplate (существующий)
Описание тренировки: список упражнений + подходы + отдых. Многократно используется.

### 2. TrainingPlan
Недельный шаблон расписания. Привязывает день недели к шаблону тренировки.

```
TrainingPlan {
  id, userId, name, isActive, source, createdAt
  schedule: [
    { dayOfWeek: 'monday', workoutTemplateId, time: '18:00', name: 'Push Day' },
    { dayOfWeek: 'wednesday', workoutTemplateId, time: '18:00', name: 'Pull Day' },
    { dayOfWeek: 'friday', workoutTemplateId, time: '10:00', name: 'Leg Day' }
  ]
}
```

**Constraints:**
- `isActive` — только один план может быть активным у юзера
- `source`: `'manual'` или `'milp'`
- Plan can only be updated/deleted when inactive

### 3. TrainingPlanSession
Реализация плана на 4 недели. Трекает текущую неделю и статус.

```
TrainingPlanSession {
  id, planId, userId, startedAt, currentWeek (1-4), status, createdAt
}
```

**Statuses:** `active` → `completed` | `archived`

### 4. WorkoutSession
Конкретная тренировка с planned-весами (SetPlanner). Всегда привязана к TrainingPlanSession.

```
WorkoutSession {
  id, planSessionId, userId, dayOfWeek, time, weekNumber, status, metadata
  exercises: [{ exerciseSlug, sets, order, metadata }]
  → workout_session_sets (planned + actual per-set data)
}
```

---

## CRUD Operations

### Create Plan
```
POST /training-plans { name, schedule?: [...] }
→ isActive = false, source = 'manual'
```

### Update Plan (inactive only)
```
PATCH /training-plans/:id { name?, schedule?: [...] }
→ Error if isActive = true
```

### Delete Plan (inactive only)
```
DELETE /training-plans/:id
→ Cascades: schedule, planSessions, workoutSessions, sets
→ Error if isActive = true
```

### Get Plans
```
GET /training-plans          → all plans for user
GET /training-plans/:id     → plan with schedule
```

---

## Assign / Unassign Template

### Assign template to day
```
POST /training-plans/:id/assign { dayOfWeek, workoutTemplateId, time?, name? }
→ Upsert: если день уже привязан — заменяет template
```

### Unassign template from day
```
DELETE /training-plans/:id/assign/:dayOfWeek
→ Убирает привязку шаблона к дню
```

---

## Activate Plan

```
POST /training-plans/:id/activate
```

**Flow:**
1. Validate: plan exists, has schedule, not already active
2. Deactivate any other active plan (`isActive = false`)
3. Set `isActive = true`
4. Create `TrainingPlanSession { currentWeek: 1, status: 'active', startedAt: today }`
5. Read exercises from WorkoutTemplate (`schedule[0].workoutTemplateId`)
6. Create first `WorkoutSession` with exercises
7. Run `SetPlanner.planSetsForSession()` for planned sets

**Constraint:** Only 1 active plan per user.

---

## Archive Plan

```
POST /training-plans/:id/archive
```

**Flow:**
1. Set `isActive = false`
2. Archive active `TrainingPlanSession` (status → `'archived'`)
3. Planned `WorkoutSession`s remain in DB but won't be shown as current
4. Completed sessions stay in history

---

## Replace Workout

```
POST /training-plans/sessions/:sessionId/replace { workoutTemplateId, name? }
```

**Flow:**
1. Find the planned `WorkoutSession`
2. Validate: status = `planned`
3. Delete the session
4. Update schedule: assign new template to the same day
5. Create new `WorkoutSession` from new template
6. Run `SetPlanner` for planned sets

**Only works for planned sessions.** Completed sessions cannot be replaced.

---

## Complete Workout Session

```
POST /workout-sessions/:id/complete { sets: [...] }
```

**Flow:**
1. Save actual set data, set status = `completed`
2. Find next day in plan schedule
3. If week not finished → create next `WorkoutSession` + SetPlanner
4. If week finished → increment `currentWeek`
5. If `currentWeek > 4` → archive `TrainingPlanSession`

---

## Skip Workout Session

```
POST /workout-sessions/:id/skip { reschedule?: boolean }
```

**Flow:**
1. Set status = `skipped`
2. If `reschedule = true` → create duplicate on next available day + SetPlanner
3. If `reschedule = false` → just skip, advance to next day

---

## MILP Integration

`POST /workout-milp/weekly-plan` creates:
1. WorkoutTemplate per day — exercises from MILP generation
2. TrainingPlan with schedule (day → templateId), `source: 'milp'`, `isActive: false`
3. Returns `planId` — user calls `POST /training-plans/:id/activate`

`POST /training-plans/:id/activate`:
1. Deactivates other plans
2. Creates TrainingPlanSession (4 weeks)
3. Reads exercises from WorkoutTemplate (first day's schedule)
4. Creates WorkoutSession with exercises + SetPlanner

---

## Home Data

```
GET /home/data → { activeBlock (plan), weekSessions, todaySession }
```

Returns active TrainingPlanSession + sessions for current week + today's session.

---

## Auto-Skip Cron

Daily at midnight: planned sessions with past `day_of_week` → status = `skipped`, metadata.autoSkipped = true.
