# Data Model

Все сущности определены в `src/entities/`. Хранятся в PostgreSQL (схема — `sql/schema.sql`).

## Общие правила

- Все slug-ссылки остаются строковыми ссылками на доменные сущности.
- Все числовые коэффициенты для MILP хранятся в `metadata` как `JSONB`.
- Для MILP важны два уровня: `Workout` (одна тренировка) и `Weekly Process` (план на неделю).
- Диалоговая система использует `WorkoutDialog` для хранения состояния пошагового сбора параметров.

## Exercise

```typescript
{
  exerciseId: string;
  name: string;
  slug: string;
  gifUrl: string;
  targetMuscles: string[];
  secondaryMuscles?: string[];
  bodyParts: string[];
  equipments: string[];
  instructions: string[];
  contraindications?: { slug: string; severity: 'forbidden' | 'not_recommended' | 'low_weight' }[];
  alias?: string[];
  exerciseType?: 'strength' | 'hypertrophy' | 'endurance' | 'mobility' | 'stability' | 'cardio' | 'plyometric' | 'rehab' | 'stretching';
  difficulty?: 'beginner' | 'intermediate' | 'advanced';
  movementPattern?: 'push' | 'pull' | 'squat' | 'hinge' | 'lunge' | 'carry' | 'rotate' | 'anti_rotate' | 'jump' | 'crawl' | 'press' | 'row' | 'curl' | 'extension' | 'flexion' | 'abduction' | 'adduction' | 'rotation' | 'stabilization' | 'locomotion' | 'stretch';
  description?: string;
  confidence?: number;
  variations?: string[];
  metadata?: ExerciseMetadata;
}
```

### ExerciseMetadata

```typescript
{
  complexityScore?: number;
  fatigueCost?: number;
  timeCostSec?: number;
  riskLevel?: number;
  jointStress?: number;
  primaryMuscleWeights?: { slug: string; weight: number }[];
  secondaryMuscleWeights?: { slug: string; weight: number }[];
  phaseAffinity?: string[];
  variationGroup?: string;
}
```

## User

```typescript
{
  id: string;
  deviceId: string;
  name?: string;
  gender?: 'male' | 'female';
  weight?: number;
  height?: number;
  age?: number;
  contraindications?: string[];
  createdAt: string;
  metadata?: UserMetadata;
}
```

### UserMetadata

```typescript
{
  goal?: string | null;
  trainingAgeMonths?: number | null;
  experienceLevel?: 'beginner' | 'intermediate' | 'advanced' | null;
  recoveryCapacity?: number | null;
  availableEquipment?: string[] | null;
  injuryHistory?: string[] | null;
  currentLimitations?: string[] | null;
  preferredExercises?: string[] | null;
  dislikedExercises?: string[] | null;
  preferredMovementPatterns?: string[] | null;
  defaultEquipmentPresetId?: string | null;
}
```

`sessionDurationMin` не является свойством User — это входной параметр для генерации тренировки.

## Muscle

```typescript
{ name: string; slug: string; antagonists?: string[]; }
```

## Bodypart

```typescript
{ name: string; slug: string; }
```

## Equipment

```typescript
{ name: string; slug: string; description?: string; imageUrl?: string; }
```

## Contraindication

```typescript
{ name: string; slug: string; }
```

## WorkoutTemplate

```typescript
{
  id: string;
  userId: string;
  name: string;
  description?: string;
  exercises: WorkoutExercise[];
  createdAt: string;
  updatedAt: string;
  metadata?: WorkoutTemplateMetadata;
}
```

### WorkoutTemplateMetadata

```typescript
{
  sessionDurationMin?: number;
  trainingGoal?: string;
  expectedLoad?: number;
  recoveryWindowDays?: number;
  blockType?: string;
  phase?: string;
}
```

## WorkoutExercise

```typescript
{
  exerciseSlug: string;
  sets: number;
  reps?: number;
  restBetweenSets?: number;
  restAfterExercise?: number;
  order: number;
}
```

## ScheduledWorkout

```typescript
{
  id: string;
  templateId: string;
  userId: string;
  dayOfWeek: DayOfWeek;
  time: string;
  createdAt: string;
}
```

## TrainingBlock

```typescript
{
  id: string;
  userId: string;
  name: string;
  type: 'base' | 'build' | 'taper' | 'recovery';
  index: number;
  durationWeeks: number;
  goal?: string;
  targetMuscles?: string[];
  metadata?: TrainingBlockMetadata;
}
```

### TrainingBlockMetadata

```typescript
{
  phase?: string;
  weekType?: string;
  splitName?: string;
  experienceLevel?: string;
  goal?: string;
  gender?: string;
  minRestDays?: number;
  maxRestDays?: number;
  weeklyLoadLimit?: number;
  consecutiveTrainingDaysLimit?: number;
}
```

## WorkoutSession

```typescript
{
  id: string;
  blockId: string;
  userId: string;
  dayOfWeek: DayOfWeek;
  time?: string;
  status?: 'planned' | 'completed' | 'skipped' | 'replaced';
  exercises?: WorkoutSessionExercise[];
  metadata?: WorkoutSessionMetadata;
}
```

### WorkoutSessionMetadata

```typescript
{
  previousSessionId?: string;
  nextSessionId?: string;
  sessionDurationMin?: number;
  sessionType?: string;
  repsPerSet?: number;
  sessionLoadByMuscle?: { slug: string; load: number }[];
  mandatoryMuscles?: string[];
  forbiddenExercises?: string[];
  allowedTimeDeviationMin?: number;
  allowedLoadDeviation?: number;
  autoSkipped?: boolean;
  rescheduledFrom?: string;
}
```

## WorkoutSessionExercise

```typescript
{
  sessionId?: string;
  exerciseSlug: string;
  sets: number;
  order: number;
  metadata?: WorkoutSessionExerciseMetadata;
}
```

### WorkoutSessionExerciseMetadata

```typescript
{
  targetLoad?: number;
  setWeight?: number;
}
```

## WorkoutSessionSet

Per-set planned + actual data for exercises in a session.

```typescript
{
  sessionId: string;
  exerciseSlug: string;
  setNumber: number;
  setType: 'warmup' | 'working' | 'dropset';

  plannedWeightKg?: number;
  plannedReps?: number;
  plannedDurationSec?: number;
  plannedDistanceM?: number;

  actualWeightKg?: number;
  actualReps?: number;
  actualDurationSec?: number;
  actualDistanceM?: number;
  actualRpe?: number;

  completedAt?: Date;
}
```

**Таблица БД:**
```sql
CREATE TABLE workout_session_sets (
  session_id          TEXT NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_slug       TEXT NOT NULL,
  set_number          INT NOT NULL,
  set_type            TEXT NOT NULL DEFAULT 'working',
  planned_weight_kg   NUMERIC(6,2),
  planned_reps        INT,
  planned_duration_sec INT,
  planned_distance_m  NUMERIC(8,1),
  actual_weight_kg    NUMERIC(6,2),
  actual_reps         INT,
  actual_duration_sec INT,
  actual_distance_m   NUMERIC(8,1),
  actual_rpe          NUMERIC(3,1),
  completed_at        TIMESTAMPTZ,
  PRIMARY KEY (session_id, exercise_slug, set_number)
);
```

- `workout_session_exercises` хранит структуру упражнения (slug, sets count, ordering)
- `workout_session_sets` хранит per-set детали: planned (бэкенд) + actual (фронтенд при complete)
- Compound exercises (movement_pattern: squat/press/pull/hinge/row/lunge): warmup + working sets
- Cardio (movement_pattern: locomotion): 1 set с duration + distance
- Bodyweight: planned_weight = user.weight, actual = weight + added

**Вспомогательные типы:**
```typescript
type MeasurementType = 'weight_reps' | 'duration_distance' | 'reps_only';
// weight_reps: strength/hypertrophy — planned_weight_kg + planned_reps
// duration_distance: cardio/locomotion — planned_duration_sec + planned_distance_m
// reps_only: bodyweight without weight — planned_reps only
```

## WorkoutDialog

Диалоговое состояние пошагового сбора параметров для генерации тренировки.

```typescript
{
  id: string;
  userId: string;
  currentStep: string;
  planType?: string;
  collectedParams: Record<string, unknown>;
  createdAt: string;
  updatedAt: string;
}
```

**Таблица БД:**
```sql
CREATE TABLE workout_dialogs (
  id VARCHAR(30) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  current_step VARCHAR(30) NOT NULL,
  plan_type VARCHAR(10),
  collected_params JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

`collectedParams` накапливает ответы пользователя в JSON:
```json
{
  "planType": "weekly",
  "goal": "hypertrophy",
  "experienceLevel": "intermediate",
  "availableEquipment": ["barbell", "dumbbell"],
  "trainingCountPerWeek": 3,
  "availableDays": ["monday", "wednesday", "friday"],
  "sessionDurationMin": 60
}
```

## EquipmentPreset

Именованный набор оборудования (системный или пользовательский).

```typescript
{
  id: string;
  userId?: string;
  name: string;
  slug: string;
  isSystem: boolean;
  equipmentSlugs: string[];
  createdAt: string;
  updatedAt: string;
}
```

**Таблица БД:**
```sql
CREATE TABLE equipment_presets (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  is_system BOOLEAN NOT NULL DEFAULT false,
  equipment_slugs TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, slug)
);
```

- `user_id = NULL` для системных пресетов (`is_system = true`)
- `equipmentSlugs` — массив слагов из таблицы `equipments`
- Системные пресеты: `gym-full`, `gym-basic`, `home`, `bodyweight-only`, `outdoor`

## WeightLog

Запись об изменении веса пользователя.

```typescript
{
  id: string;
  userId: string;
  weight: number;
  createdAt: string;
}
```

**Таблица БД:**
```sql
CREATE TABLE weight_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(50) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  weight NUMERIC(5,2) NOT NULL CHECK (weight > 0 AND weight < 500),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_weight_logs_user_created ON weight_logs(user_id, created_at DESC);
```

- Запись создаётся автоматически при `PATCH /users/profile` с полем `weight`
- `GET /users/weight-history` — чтение с фильтром по периоду (`week` / `month` / `all`)

## Relationships

```
Exercise ---* targetMuscles ---> Muscle
Exercise ---* secondaryMuscles ---> Muscle
Exercise ---* bodyParts ---> Bodypart
Exercise ---* equipments ---> Equipment
Exercise ---* contraindications.slug ---> Contraindication
User ---* contraindications ---> Contraindication
Muscle ---* antagonists ---> Muscle
User ---* workoutTemplates ---> WorkoutTemplate
User ---* workoutDialogs ---> WorkoutDialog
User ---* equipmentPresets ---> EquipmentPreset
User ---* weightLogs ---> WeightLog
EquipmentPreset ---* equipmentSlugs ---> Equipment (via slug)
WorkoutTemplate ---* exercises ---> WorkoutExercise (via exerciseSlug)
WorkoutTemplate ---* scheduledWorkouts ---> ScheduledWorkout
WorkoutTemplate ---* trainingBlocks ---> TrainingBlock
TrainingBlock ---* sessions ---> WorkoutSession
WorkoutSession ---* exercises ---> WorkoutSessionExercise
WorkoutSession ---* sets ---> WorkoutSessionSet (per exercise in session)
ScheduledWorkout ---> templateId ---> WorkoutTemplate
WorkoutSession ---> blockId ---> TrainingBlock
```
