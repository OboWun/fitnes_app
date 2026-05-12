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
{ name: string; slug: string; }
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
  trainingGoal?: string;
  expectedLoad?: number;
  recoveryWindowDays?: number;
  sessionDurationMin?: number;
  blockType?: 'heavy' | 'moderate' | 'light' | 'recovery' | 'technique';
  phase?: 'accumulation' | 'intensification' | 'realization' | 'deload' | 'transition';
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
  metadata?: { targetLoad?: number; setWeight?: number; intensityWeight?: number; };
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
  metadata?: { restBeforeDays?: number; restAfterDays?: number; };
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
}
```

## WorkoutSessionExercise

```typescript
{
  sessionId?: string;
  exerciseSlug: string;
  sets: number;
  order: number;
  metadata?: { targetLoad?: number; setWeight?: number; };
}
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
EquipmentPreset ---* equipmentSlugs ---> Equipment (via slug)
WorkoutTemplate ---* exercises ---> WorkoutExercise (via exerciseSlug)
WorkoutTemplate ---* scheduledWorkouts ---> ScheduledWorkout
WorkoutTemplate ---* trainingBlocks ---> TrainingBlock
TrainingBlock ---* sessions ---> WorkoutSession
WorkoutSession ---* exercises ---> WorkoutSessionExercise
ScheduledWorkout ---> templateId ---> WorkoutTemplate
WorkoutSession ---> blockId ---> TrainingBlock
```
