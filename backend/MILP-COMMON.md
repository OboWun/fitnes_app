# MILP Common

## 1. Два уровня оптимизации

### 1.1 Workout MILP

**Что делает:** выбирает упражнения и число подходов для одной тренировки.

**Входной контракт:**

```ts
interface WorkoutMILPInput {
  userId: string;
  sessionDurationMin: number;       // 20..120, обязательный параметр запроса
  exerciseCount: number;            // 3..8
  setsPerExercise: number;          // 1..6
  availableEquipment: string[];     // slug-коды Equipment
  phase?: string;                   // accumulation | intensification | realization | deload | transition
  fatigueByMuscle: Record<string, number>;  // slug мышцы -> уровень усталости
  usedExercises: string[];          // slug-коды упражнений из предыдущих тренировок недели
  mandatoryMuscles?: string[];      // slug-коды мышц, которые обязательно покрыть
}
```

**Выходной контракт:**

```ts
interface WorkoutMILPOutput {
  exercises: {
    exerciseSlug: string;
    sets: number;
    order: number;
  }[];
  totalLoadByMuscle: Record<string, number>;  // slug мышцы -> суммарная нагрузка
  totalTimeSec: number;
}
```

**Тренировка = упражнение + количество подходов.** `reps` не используется.

### 1.2 Weekly Process MILP

**Что делает:** строит расписание тренировок на неделю с привязкой к дням и контролем отдыха.

**Входной контракт:**

```ts
interface WeeklyProcessMILPInput {
  userId: string;
  availableDays: DayOfWeek[];       // дни, в которые можно тренироваться
  trainingCountPerWeek: number;     // 2..6
  sessionDurationMin: number;       // лимит на одну сессию
  minRestDays: number;              // минимум дней отдыха между сессиями
  maxRestDays: number;              // максимум дней отдыха между сессиями
  weeklyLoadLimit: number;          // суммарный лимит нагрузки на неделю
  consecutiveTrainingDaysLimit: number; // максимум подряд идущих тренировочных дней
  phase: string;                    // accumulation | intensification | realization | deload | transition
  weekType: string;                 // base | build | taper | recovery
  startFatigueByMuscle: Record<string, number>; // начальная усталость по мышцам
}
```

**Выходной контракт:**

```ts
interface WeeklyProcessMILPOutput {
  sessions: {
    dayOfWeek: DayOfWeek;
    time: string;
    exercises: {
      exerciseSlug: string;
      sets: number;
      order: number;
    }[];
    loadByMuscle: Record<string, number>;
    durationMin: number;
  }[];
  restDays: number[];               // количество дней отдыха между сессиями
  totalWeeklyLoad: number;
}
```

## 2. Правила модели

1. Выбирать только упражнения, доступные по оборудованию и противопоказаниям.
2. `forbidden` противопоказание = упражнение исключается из кандидатов.
3. `not_recommended` = штраф в objective.
4. `low_weight` = мягкий штраф в objective.
5. Балансировать мышечные группы: минимум 1 упражнение на основные группы.
6. Балансировать push/pull: разница не более 1 упражнения.
7. Контролировать повторяемость: штраф за упражнения, которые были недавно.
8. Не выходить за лимит времени.
9. Не превышать усталость по мышцам.
10. Между тренировками соблюдать минимальный и максимальный отдых.

## 3. Metadata-слой

Все числовые коэффициенты хранятся в JSONB-поле `metadata` у соответствующих сущностей.

### 3.1 Exercise.metadata

```ts
{
  complexityScore: number;        // 0..1
  fatigueCost: number;            // 0..10
  timeCostSec: number;            // 20..600
  riskLevel: number;              // 0..1
  jointStress: number;            // 0..10
  primaryMuscleWeights: { slug: string; weight: number }[];   // weight 0.5..1.0
  secondaryMuscleWeights: { slug: string; weight: number }[]; // weight 0.1..0.6
  phaseAffinity: string[];        // accumulation | intensification | realization | deload | rehab | general_preparation
  variationGroup: string;         // например: horizontal_push, vertical_pull, knee_dominant_squat
}
```

### 3.2 User.metadata

```ts
{
  goal?: string | null;                      // strength | hypertrophy | endurance | fat_loss | general_fitness | mobility | rehab
  trainingAgeMonths?: number | null;         // 0..240+
  experienceLevel?: string | null;           // beginner | intermediate | advanced
  recoveryCapacity?: number | null;          // 0..1
  availableEquipment?: string[] | null;      // slug-коды Equipment
  injuryHistory?: string[] | null;           // knee | lower_back | shoulder | neck | elbow | ankle
  currentLimitations?: string[] | null;      // pain_knee | pain_back | limited_rom_shoulder | no_overhead_press
  preferredExercises?: string[] | null;      // slug-коды упражнений
  dislikedExercises?: string[] | null;       // slug-коды упражнений
  preferredMovementPatterns?: string[] | null;
}
```

Все поля nullable. Если поле `null`, MILP использует дефолтное значение или пропускает ограничение.

**Fallback при null:**
- `availableEquipment = null` -> использовать только bodyweight-упражнения или запросить у пользователя.
- `goal = null` -> использовать `general_fitness`.
- `recoveryCapacity = null` -> использовать 0.5.
- `experienceLevel = null` -> использовать `beginner`.

### 3.3 WorkoutTemplate.metadata

```ts
{
  sessionDurationMin?: number;    // лимит времени на тренировку, 20..120
  trainingGoal?: string;          // цель данной тренировки
  expectedLoad?: number;          // ожидаемая суммарная нагрузка
  recoveryWindowDays?: number;    // дней до следующей тренировки
  blockType?: string;             // heavy | moderate | light | recovery | technique
  phase?: string;                 // accumulation | intensification | realization | deload | transition
}
```

`sessionDurationMin` хранится здесь, а не в `User`, потому что это параметр конкретной тренировки, а не свойство пользователя.

### 3.4 TrainingBlock.metadata

```ts
{
  phase?: string;                         // accumulation | intensification | realization | deload | transition
  weekType?: string;                      // base | build | taper | recovery
  minRestDays?: number;                   // минимум дней отдыха
  maxRestDays?: number;                   // максимум дней отдыха
  weeklyLoadLimit?: number;               // лимит нагрузки на неделю
  consecutiveTrainingDaysLimit?: number;  // максимум подряд идущих тренировочных дней
}
```

### 3.5 WorkoutSession.metadata

```ts
{
  previousSessionId?: string;
  nextSessionId?: string;
  sessionDurationMin?: number;
  sessionLoadByMuscle?: { slug: string; load: number }[];
  mandatoryMuscles?: string[];
  forbiddenExercises?: string[];
  allowedTimeDeviationMin?: number;
  allowedLoadDeviation?: number;
}
```

## 4. Перевод категорий в числа

### 4.1 ContraindicationSeverity

```
k(forbidden)        = 0.0  -> упражнение исключается из множества кандидатов
k(not_recommended)  = 0.5  -> штраф в objective: weight *= k(severity)
k(low_weight)       = 0.8  -> мягкий штраф в objective: weight *= k(severity)
```

### 4.2 Difficulty

```
k(beginner)     = 1
k(intermediate) = 2
k(advanced)     = 3
```

### 4.3 RecoveryCapacity

```
диапазон: 0..1
null -> дефолт 0.5
```

### 4.4 Readiness / Soreness / Pain

```
readiness: 0..10
soreness: 0..10
pain: 0..10
```

## 5. Типы ограничений

- **hard constraint** — нарушение недопустимо. Реализуется как ограничение ILP.
- **soft constraint** — нарушение допустимо с штрафом. Реализуется как слагаемое в objective.
- **preference** — влияет на вес упражнения в objective.
- **progression** — задаёт рост или спад нагрузки между тренировками.
- **recovery** — задаёт отдых между сессиями.

## 6. Стартовые priors из hybrid_model.ipynb

Использовать как дефолтные значения до появления собственной статистики:

```
alpha_1 = 1.5    вес сложности
alpha_2 = 0.5    вес частоты
alpha_3 = 2.0    вес аффинности
delta   = 0.2    вес разнообразия
epsilon = 0.2    вес штрафа усталости
theta   = 1.5    порог усталости
lambda  = 0.345  скорость восстановления
diversity_window = 4  тренировки
```

Матрица интенсивности `I_{e,m}`:
- основная мышца: 1.0
- выраженный синергист: 0.5
- слабый синергист: 0.3

## 7. Структура внедрения

1. **Workout MILP** — сервис, строящий состав одной тренировки.
2. **Weekly Process MILP** — сервис, строящий расписание на неделю.
3. **Adaptive Update Layer** — сервис, обновляющий priors по истории выполнения.

## 8. Контракт между Workout MILP и Weekly Process MILP

Weekly Process MILP вызывает Workout MILP для каждой тренировки в неделе.

**Что Weekly передает в Workout:**
- `sessionDurationMin` из `WorkoutTemplate.metadata`
- `phase` из `TrainingBlock.metadata`
- `fatigueByMuscle` — текущая усталость, пересчитанная после предыдущей тренировки
- `usedExercises` — упражнения, уже использованные в неделе
- `availableEquipment` из `User.metadata`
- `mandatoryMuscles` из `TrainingBlock.targetMuscles`

**Что Workout возвращает в Weekly:**
- `loadByMuscle` — для обновления усталости
- `totalTimeSec` — для контроля лимита времени

**Единая метрика нагрузки:**

```
load(e, m) = fatigueCost(e) * primaryMuscleWeight(e, m)
```

где `fatigueCost` берётся из `Exercise.metadata.fatigueCost`, а `primaryMuscleWeight` из `Exercise.metadata.primaryMuscleWeights`.
