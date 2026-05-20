# MILP Common

## 1. Два уровня оптимизации

### 1.1 Workout MILP

**Что делает:** выбирает упражнения и число подходов для одной тренировки с учётом цели, опыта, пола и недельного объёма.

**Входной контракт:**

```ts
interface WorkoutMILPInput {
  userId: string;
  sessionDurationMin: number;       // 20..120, обязательный
  experienceLevel?: string;         // beginner | intermediate | advanced
  goal?: string;                    // strength | hypertrophy | endurance | weight_loss | general_health | rehab | mobility | glute_growth | recomposition
  focusMuscles?: string[];          // мышечные группы для акцента
  specificMuscles?: string[];       // конкретные мышцы для приоритета
  exerciseCount?: number;           // 3..8, auto-derived если не указан
  setsPerExercise?: number;         // legacy, игнорируется если есть compoundSets/isolationSets
  compoundSets?: number;            // подходы для compound-упражнений (3-5)
  isolationSets?: number;           // подходы для isolation-упражнений (2-3)
  restBetweenSetsSec?: number;      // auto-derived из goal
  availableEquipment: string[];
  phase?: string;
  fatigueByMuscle: Record<string, number>;
  usedExercises: string[];
  mandatoryMuscles?: string[];
  userContraindications?: string[];
  gender?: string;                  // male | female
  weeklyVolumeByMuscle?: Record<string, number>;
  activityLevel?: string;           // sedentary | light | moderate | active
  cardioPreference?: string;        // running | cycling | rowing | jump_rope | swimming | any
  primaryLifts?: string[];          // squat | bench | deadlift | ohp
  enduranceType?: string;           // muscular | cardio | mixed
  age?: number;
  heightCm?: number;
  weightKg?: number;
}
```

**Выходной контракт:**

```ts
interface WorkoutMILPOutput {
  exercises: {
    exerciseSlug: string;
    sets: number;          // переменный: compound 3-5, isolation 2-3
    repsPerSet: number;    // определяется goal: strength=5, hypertrophy=10, endurance=15
    order: number;
  }[];
  totalLoadByMuscle: Record<string, number>;
  totalTimeSec: number;
  usedFallback?: boolean;
  partialCoverage?: boolean;
  unmetMandatory?: string[];
}
```

**Ключевое:** `sets` и `repsPerSet` — переменные, зависят от типа упражнения (compound/isolation) и цели.

### 1.2 Weekly Process MILP

**Что делает:** строит план на неделю с автоподбором сплита и распределением объёма по мышцам.

**Входной контракт:**

```ts
interface WeeklyProcessInput {
  userId: string;
  availableDays: DayOfWeek[];
  trainingCountPerWeek: number;     // 2..6
  sessionDurationMin: number;       // 20..120
  experienceLevel: string;          // beginner | intermediate | advanced
  goal: string;
  gender: string;                   // male | female
  availableEquipment: string[];
  phase?: string;
  userContraindications?: string[];
  splitType?: string;               // auto | full_body | upper_lower | ppl
  activityLevel?: string;           // sedentary | light | moderate | active
  cardioPreference?: string;        // running | cycling | rowing | jump_rope | swimming | any
  primaryLifts?: string[];          // squat | bench | deadlift | ohp
  enduranceType?: string;           // muscular | cardio | mixed
  targetWeightKg?: number;          // для weight_loss
  age?: number;
  heightCm?: number;
  weightKg?: number;
}
```

**Выходной контракт:**

```ts
interface WeeklyProcessOutput {
  planId: string;
  splitName: string;                // ppl, upper_lower, full_body и т.д.
  sessions: {
    dayOfWeek: DayOfWeek;
    sessionType: 'full_body' | 'upper' | 'lower' | 'push' | 'pull' | 'legs';
    exercises: { exerciseSlug: string; sets: number; repsPerSet: number; order: number }[];
    loadByMuscle: Record<string, number>;
    totalTimeSec: number;
    usedFallback?: boolean;
    repsPerSet: number;
  }[];
  totalWeeklyLoad: number;
  weeklyVolumeByMuscle: Record<string, number>;
}
```

**Ключевое:** сплит и session types подбираются автоматически из матрицы `SPLIT_STRATEGIES`.

## 2. Правила модели

1. Выбирать только упражнения, доступные по оборудованию и противопоказаниям.
2. `forbidden` противопоказание = упражнение исключается из кандидатов.
3. `not_recommended` = штраф в objective (×0.5).
4. `low_weight` = мягкий штраф (×0.8).
5. Фокус-группы получают минимум упражнений: chest/back/legs ≥ 2, shoulders/arms/core ≥ 1.
6. Баланс push/pull: разница не более 1 упражнения.
7. Контролировать повторяемость: штраф за упражнения из последних N сессий.
8. Не выходить за лимит времени.
9. Не превышать усталость по мышцам (FATIGUE_LIMIT = 3.0).
10. Недельный объём отслеживается: мышцы ≥ max → deprioritized (×0.3), < min×0.5 → boosted (×1.3).
11. Gender-aware: female → glutes/hamstrings ×1.3 (×1.7 for glute_growth), male → chest/shoulders/lats ×1.2.
12. Session-type-aware scoring: different SESSION_TARGETS и SESSION_DEPRIORITIZE per slot.
13. Variable sets: compound (multi-muscle) → больше подходов, isolation → меньше.
14. Goal → reps: strength 1-5, hypertrophy 6-12, endurance 15-25, glute_growth 6-20, recomposition 8-15.
15. Age-aware: AGE_VOLUME_SCALE (<25:1.1, 25-40:1.0, 40-55:0.85, >55:0.7), AGE_REST_MODIFIER (>40:1.1, >55:1.2).
16. BMI-aware: BMI>30 → bodyweight ×0.7 scoring; BMI<18.5 → high-impact ×0.8.

## 3. Metadata-слой

### 3.1 ExerciseMetadata

```ts
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

### 3.2 UserMetadata

```ts
{
  goal?: string | null;
  trainingAgeMonths?: number | null;
  experienceLevel?: string | null;
  recoveryCapacity?: number | null;
  availableEquipment?: string[] | null;
  injuryHistory?: string[] | null;
  currentLimitations?: string[] | null;
  preferredExercises?: string[] | null;
  dislikedExercises?: string[] | null;
  preferredMovementPatterns?: string[] | null;
}
```

### 3.3 TrainingBlockMetadata

```ts
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

### 3.4 WorkoutSessionMetadata

```ts
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

## 4. Severity маппинг

```
k(forbidden)        = 0.0  → упражнение исключается
k(not_recommended)  = 0.5  → weight *= 0.5
k(low_weight)       = 0.8  → weight *= 0.8
```

## 5. Priors (из hybrid_model.ipynb)

```
alpha_1 = 1.5    вес сложности
alpha_2 = 0.5    вес частоты
alpha_3 = 2.0    вес аффинности
delta   = 0.2    вес разнообразия
epsilon = 0.2    вес штрафа усталости
theta   = 1.5    порог усталости
lambda  = 0.345  скорость восстановления
diversity_window = 4
```

## 6. Контракт между Workout MILP и Weekly Process MILP

Weekly Process вызывает Workout MILP для каждой тренировки.

**Что Weekly передает в Workout:**
- `sessionDurationMin` — из входного параметра
- `experienceLevel`, `goal`, `gender` — из входных параметров
- `compoundSets`, `isolationSets` — auto-derived из level + goal
- `focusMuscles` / `specificMuscles` — из `SESSION_MUSCLE_FOCUS[slot]`
- `mandatoryMuscles` — из primary muscles слота + gender expansions
- `phase` — из входных параметров
- `fatigueByMuscle` — пересчитанная после предыдущей тренировки
- `usedExercises` — упражнения из уже сгенерированных сессий недели
- `availableEquipment` — из входных параметров
- `weeklyVolumeByMuscle` — накопленный объём за неделю

**Что Workout возвращает в Weekly:**
- `loadByMuscle` — для обновления усталости
- `totalTimeSec` — для контроля лимита времени
- `exercises` с `sets` и `repsPerSet` — для записи в WorkoutSession

**Метрика нагрузки:**
```
load(e, m) = fatigueCost(e) × primaryMuscleWeight(e, m)
```

## 7. Split Selection

Матрица `SPLIT_STRATEGIES`:

| Key | Split | Sessions |
|-----|-------|----------|
| `2-beginner` | full_body | FB, FB |
| `2-intermediate` | upper_lower | Upper, Lower |
| `3-beginner` | full_body | FB, FB, FB |
| `3-intermediate` | ppl | Push, Pull, Legs |
| `4-beginner` | upper_lower | Upper, Lower, FB, FB |
| `4-intermediate` | upper_lower | Upper, Lower, Upper, Lower |
| `4-advanced` | ppl_plus | Push, Pull, Legs, FB |
| `5-intermediate` | ppl_ul | Push, Pull, Legs, Upper, Lower |
| `5-advanced` | ppl_pp | Push, Pull, Legs, Push, Pull |
| `6-*` | ppl_ppl | Push, Pull, Legs, Push, Pull, Legs |

Goal modifiers: `rehab`/`mobility` → все FB; `weight_loss`/`endurance` → до половины сессий FB; `glute_growth` → female ×1.7 / male ×1.5 mandatory muscles.
Experience caps: beginner ≤ 3-4 days, intermediate ≤ 5, advanced ≤ 6.
