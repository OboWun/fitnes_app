# Data Model

Все сущности определены в `src/entities/`. Хранятся в PostgreSQL (схема - `sql/schema.sql`).

## Общие правила

- Все slug-ссылки остаются строковыми ссылками на доменные сущности.
- Все числовые коэффициенты для MILP хранятся в `metadata` как `JSONB`.
- Если значение вычисляется на лету, оно должно быть доступно как производное поле в сервисе.
- Для MILP важны два уровня: `Workout` и `Weekly Process`.

## Exercise

```typescript
{
  exerciseId: string;
  name: string;
  slug: string;
  gifUrl: string;
  targetMuscles: string[];        // slug-ссылки на Muscle
  secondaryMuscles?: string[];    // slug-ссылки на Muscle
  bodyParts: string[];            // slug-ссылки на Bodypart
  equipments: string[];           // slug-ссылки на Equipment
  instructions: string[];
  contraindications?: { slug: string; severity: 'forbidden' | 'not_recommended' | 'low_weight' }[];
  alias?: string[];
  exerciseType?: 'strength' | 'hypertrophy' | 'endurance' | 'mobility' | 'stability' | 'cardio' | 'plyometric' | 'rehab' | 'stretching';
  difficulty?: 'beginner' | 'intermediate' | 'advanced';
  movementPattern?: 'push' | 'pull' | 'squat' | 'hinge' | 'lunge' | 'carry' | 'rotate' | 'anti_rotate' | 'jump' | 'crawl' | 'press' | 'row' | 'curl' | 'extension' | 'flexion' | 'abduction' | 'adduction' | 'rotation' | 'stabilization' | 'locomotion' | 'stretch';
  description?: string;
  confidence?: number;
  variations?: string[];
  metadata?: {
    complexityScore?: number; // 0..1 or 1..5
    fatigueCost?: number; // 0..10
    timeCostSec?: number; // 20..600
    riskLevel?: number; // 0..1 or 1..5
    jointStress?: number; // 0..10
    primaryMuscleWeights?: { slug: string; weight: number }[]; // weight 0.5..1.0
    secondaryMuscleWeights?: { slug: string; weight: number }[]; // weight 0.1..0.6
    phaseAffinity?: ('accumulation' | 'intensification' | 'realization' | 'deload' | 'rehab' | 'general_preparation')[];
    variationGroup?: string;
  };
}
```

## User

```typescript
{
  id: string;
  deviceId: string;
  name?: string;
  weight?: number; // 20-300
  height?: number; // 50-300
  age?: number; // 10-120
  contraindications?: string[]; // slug-ссылки на Contraindication
  createdAt: string;
  metadata?: {
    goal?: 'strength' | 'hypertrophy' | 'endurance' | 'fat_loss' | 'general_fitness' | 'mobility' | 'rehab' | null;
    availableEquipment?: string[] | null;
    trainingAgeMonths?: number | null; // 0..240+
    experienceLevel?: 'beginner' | 'intermediate' | 'advanced' | null;
    recoveryCapacity?: number | null; // 0..1 or 1..5
    injuryHistory?: string[] | null;
    currentLimitations?: string[] | null;
    preferredExercises?: string[] | null;
    dislikedExercises?: string[] | null;
    preferredMovementPatterns?: string[] | null;
  };
}
```

Примечание: `sessionDurationMin` не является свойством `User`. Это входной параметр для `Workout MILP` и должен передаваться в запросе генерации тренировки или храниться в `WorkoutTemplate.metadata.sessionDurationMin` как результат планирования.

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

Шаблон тренировки. В MILP используется как результат `Workout MILP`.

```typescript
{
  id: string;
  userId: string;
  name: string;
  description?: string;
  exercises: WorkoutExercise[];
  createdAt: string;
  updatedAt: string;
  metadata?: {
    trainingGoal?: string;
    expectedLoad?: number;
    recoveryWindowDays?: number;
    sessionDurationMin?: number;
    blockType?: 'heavy' | 'moderate' | 'light' | 'recovery' | 'technique';
    phase?: 'accumulation' | 'intensification' | 'realization' | 'deload' | 'transition';
  };
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
  metadata?: {
    targetLoad?: number;
    setWeight?: number;
    intensityWeight?: number;
  };
}
```

## ScheduledWorkout

Назначение шаблона на день недели.

```typescript
{
  id: string;
  templateId: string;
  userId: string;
  dayOfWeek: 'monday' | 'tuesday' | 'wednesday' | 'thursday' | 'friday' | 'saturday' | 'sunday';
  time: string;
  createdAt: string;
  metadata?: {
    restBeforeDays?: number;
    restAfterDays?: number;
  };
}
```

## TrainingBlock

Сущность недельной периодизации для `Weekly Process MILP`.

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
  metadata?: {
    phase?: 'accumulation' | 'intensification' | 'realization' | 'deload' | 'transition';
    minRestDays?: number;
    maxRestDays?: number;
    weeklyLoadLimit?: number;
    consecutiveTrainingDaysLimit?: number;
  };
}
```

## WorkoutSession

Одна тренировка внутри недельного процесса.

```typescript
{
  id: string;
  blockId: string;
  userId: string;
  dayOfWeek: 'monday' | 'tuesday' | 'wednesday' | 'thursday' | 'friday' | 'saturday' | 'sunday';
  time?: string;
  status?: 'planned' | 'completed' | 'skipped' | 'replaced';
  metadata?: {
    previousSessionId?: string;
    nextSessionId?: string;
    sessionDurationMin?: number;
    sessionLoadByMuscle?: { slug: string; load: number }[];
    mandatoryMuscles?: string[];
    forbiddenExercises?: string[];
    allowedTimeDeviationMin?: number;
    allowedLoadDeviation?: number;
  };
}
```

## WorkoutSessionExercise

Состав конкретной сессии.

```typescript
{
  sessionId: string;
  exerciseSlug: string;
  sets: number;
  order: number;
  metadata?: {
    targetLoad?: number;
    setWeight?: number;
  };
}
```

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
WorkoutTemplate ---* exercises ---> WorkoutExercise (via exerciseSlug)
WorkoutTemplate ---* scheduledWorkouts ---> ScheduledWorkout
WorkoutTemplate ---* trainingBlocks ---> TrainingBlock
TrainingBlock ---* sessions ---> WorkoutSession
WorkoutSession ---* exercises ---> WorkoutSessionExercise
ScheduledWorkout ---> templateId ---> WorkoutTemplate
WorkoutSession ---> blockId ---> TrainingBlock
```

## API and storage notes

- `metadata` лучше хранить как `JSONB` в PostgreSQL.
- `ExercisesService.toResponseDto()` должен отдавать `metadata` без потери структуры.
- Все числовые веса для MILP должны либо храниться в `metadata`, либо вычисляться из `metadata` и истории.
- Для планирования недели `WorkoutTemplate` используется как контейнер тренировок, а `TrainingBlock` как контейнер недели.
