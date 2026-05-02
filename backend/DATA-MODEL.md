# Data Model

Все сущности определены в `src/entities/`. Хранятся в PostgreSQL (миграция с `data/*.json`).

## Exercise

```typescript
{
  exerciseId: string;
  name: string;
  slug: string;
  gifUrl: string;
  targetMuscles: string[];       // slug-ссылки на Muscle
  secondaryMuscles?: string[];   // slug-ссылки на Muscle
  bodyParts: string[];           // slug-ссылки на Bodypart
  equipments: string[];          // slug-ссылки на Equipment
  instructions: string[];
  contraindications?: { slug: string; severity: 'forbidden' | 'not_recommended' | 'low_weight' }[];
  alias?: string[];
  exerciseType?: 'strength' | 'hypertrophy' | 'endurance' | 'mobility' | 'stability' | 'cardio' | 'plyometric' | 'rehab' | 'stretching';
  difficulty?: 'beginner' | 'intermediate' | 'advanced';
  movementPattern?: 'push' | 'pull' | 'squat' | 'hinge' | 'lunge' | 'carry' | 'rotate' | ... ;
  description?: string;
  confidence?: number;
  variations?: string[];
}
```

## User

```typescript
{
  id: string;
  deviceId: string;
  name?: string;
  weight?: number;           // 20-300
  height?: number;           // 50-300
  age?: number;              // 10-120
  contraindications?: string[];  // slug-ссылки на Contraindication
  createdAt: string;
}
```

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
  dayOfWeek: 'monday' | 'tuesday' | 'wednesday' | 'thursday' | 'friday' | 'saturday' | 'sunday';
  time: string;
  createdAt: string;
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
ScheduledWorkout ---> templateId ---> WorkoutTemplate
```

Все связи — через slug-строки (или FK в PostgreSQL). Резолвинг в полные объекты происходит в `ExercisesService.toResponseDto()`.
