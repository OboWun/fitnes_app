# MILP Models

Математическая постановка двух MILP-моделей. Все коэффициенты читаются из `metadata`-слоя сущностей.

## 1. Обозначения

### Множества

- `E` — все упражнения в БД
- `M` — все мышечные группы
- `D` — дни недели: monday..sunday
- `T` — тренировки в неделе (индексы 1..N)
- `K` — типы оборудования
- `S` — уровни severity: forbidden, not_recommended, low_weight

### Переменные решения

- `x_e ∈ {0,1}` — выбрано ли упражнение `e`
- `s_e ∈ {2..5}` — количество подходов упражнения `e` (variable: compound = `compoundSets`, isolation = `isolationSets`)
- `y_t,d ∈ {0,1}` — назначена ли тренировка `t` на день `d`
- `z_t,e ∈ {0,1}` — входит ли упражнение `e` в тренировку `t`

### Параметры из metadata

| Параметр | Источник | Описание |
|----------|----------|----------|
| `complexityScore(e)` | `Exercise.metadata.complexityScore` | сложность упражнения, 0..1 |
| `fatigueCost(e)` | `Exercise.metadata.fatigueCost` | утомляемость, 0..10 |
| `timeCostSec(e)` | `Exercise.metadata.timeCostSec` | время выполнения, 20..600 сек |
| `riskLevel(e)` | `Exercise.metadata.riskLevel` | риск, 0..1 |
| `jointStress(e)` | `Exercise.metadata.jointStress` | нагрузка на суставы, 0..10 |
| `primaryMuscleWeights(e)` | `Exercise.metadata.primaryMuscleWeights` | нагрузка на основные мышцы |
| `secondaryMuscleWeights(e)` | `Exercise.metadata.secondaryMuscleWeights` | нагрузка на синергисты |
| `phaseAffinity(e)` | `Exercise.metadata.phaseAffinity` | уместность в фазе |
| `variationGroup(e)` | `Exercise.metadata.variationGroup` | группа заменяемости |
| `difficulty(e)` | `Exercise.difficulty` + маппинг: beginner=1, intermediate=2, advanced=3 |
| `recoveryCapacity(u)` | `User.metadata.recoveryCapacity` | 0..1, дефолт 0.5 |
| `goal(u)` | `User.metadata.goal` | цель, дефолт general_fitness |
| `sessionDurationMin` | входной параметр запроса | лимит времени, 20..120 |
| `goal` | входной параметр запроса | цель: strength, hypertrophy, endurance, weight_loss, general_health, rehab, mobility, glute_growth, recomposition |
| `experienceLevel` | входной параметр запроса | beginner, intermediate, advanced |
| `gender` | `User.gender` | male, female — влияет на веса выбора упражнений |
| `age` | `User.age` | влияет на AGE_VOLUME_SCALE и AGE_REST_MODIFIER |
| `heightCm` | `User.height` | используется для BMI |
| `weightKg` | `User.weight` | используется для BMI и bodyweight упражнений |
| `compoundSets` | auto-derived из level + goal | подходы для compound-упражнений (3-5) |
| `isolationSets` | auto-derived из level + goal | подходы для isolation-упражнений (2-3) |
| `repsPerSet` | auto-derived из goal | повторения: strength=5, hypertrophy=10, endurance=15 |
| `weeklyVolumeByMuscle` | вычисляется из последних 7 дней | накопленный недельный объём по мышцам |
| `minRestDays` | `TrainingBlock.metadata.minRestDays` | мин отдых, дефолт 1 |
| `maxRestDays` | `TrainingBlock.metadata.maxRestDays` | макс отдых, дефолт 3 |
| `weeklyLoadLimit` | `TrainingBlock.metadata.weeklyLoadLimit` | лимит нагрузки |
| `consecutiveLimit` | `TrainingBlock.metadata.consecutiveTrainingDaysLimit` | макс подряд, дефолт 2 |
| `phase` | `TrainingBlock.metadata.phase` | фаза периода |
| `weekType` | `TrainingBlock.metadata.weekType` | тип недели |

### Priors (дефолтные значения)

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

## 2. Workout MILP — генерация одной тренировки

### 2.1 Целевая функция

Максимизировать суммарный вес выбранных упражнений:

```
max Z = Σ_{e∈E} x_e * w_e - Σ_{e∈E} x_e * riskPenalty(e) - Σ_{e∈E} x_e * contraPenalty(e)
```

#### Вес упражнения `w_e`

Гибридная формула из hybrid_model.ipynb:

```
w_e = w_data(e) * (1 + delta * V_e) * (1 - epsilon * P_e)
```

#### Data-driven компонента `w_data(e)`

```
w_data(e) = (1 + alpha_1 * f_complexity(e)) * (1 + alpha_2 * f_frequency(e)) * (1 + alpha_3 * f_affinity(e))
```

Где:

```
f_complexity(e) = 1 / (1 + |complexityScore(e) - currentPhaseLevel|)
```

`currentPhaseLevel` — числовое значение фазы: accumulation=1, intensification=2, realization=3, deload=1, transition=1.

```
f_frequency(e) = usageCount(e, last4weeks) / max_usage_count
```

Если истории нет, `f_frequency(e) = 0.5` для всех.

```
f_affinity(e) = 1 если phase ∈ phaseAffinity(e), иначе 0
```

#### Разнообразие `V_e`

```
V_e = min(1, sessionsSinceLastUse(e) / diversity_window)
```

`sessionsSinceLastUse(e)` — количество тренировок с последнего использования упражнения `e` в текущей неделе. Если не использовалось, `V_e = 1`.

#### Штраф за усталость `P_e`

```
P_e = min(1, Σ_{m∈M} I(e,m) * max(0, F_m - theta))
```

Где:
- `I(e,m)` = нагрузка упражнения `e` на мышцу `m`, берётся из `primaryMuscleWeights` и `secondaryMuscleWeights`
- `F_m` = текущая усталость мышцы `m`, передаётся из Weekly Process MILP
- `theta = 1.5`

#### Штраф за риск `riskPenalty(e)`

```
riskPenalty(e) = riskLevel(e)
```

#### Штраф за противопоказания `contraPenalty(e)`

```
contraPenalty(e) = Σ_{c ∈ contraindications(e) ∩ userContraindications} (1 - k(severity(c)))
```

### 2.2 Hard constraints

```
Σ_{e∈E} x_e = N                              // ровно N упражнений
```
`N` — входной параметр, 3..8.

```
Σ_{e∈E} x_e * I(e,m) >= 1  для m ∈ mandatoryMuscles
```
Обязательное покрытие целевых мышц. `mandatoryMuscles` = `['квадрицепс', 'спина', 'грудь']` по дефолту.

```
Σ_{e∈E} x_e * requiresEquipment(e,k) = 0  для k ∉ availableEquipment
```
Упражнения, требующие недоступное оборудование, исключаются. `requiresEquipment(e,k)` = 1 если `k ∈ Exercise.equipments`.

```
x_e = 0  если ∃ c ∈ contraindications(e) ∩ userContraindications : severity(c) = 'forbidden'
```
Упражнения с forbidden-противопоказанием исключаются.

```
Σ_{e∈E} x_e * timeCostSec(e) * s_e <= sessionDurationMin * 60
```
Суммарное время не превышает лимит. `s_e` = `compoundSets` для compound, `isolationSets` для isolation.

```
Σ_{e∈E} x_e * I(e,m) <= fatigueLimit(m)  для m ∈ M
```
Усталость по мышце не превышает порог. `fatigueLimit(m) = 3.0` по дефолту.

```
Σ_{e∈E, variationGroup(e)=g} x_e <= 1  для каждого g
```
Не более 1 упражнения из одной группы заменяемости.

### 2.3 Soft constraints (в objective)

```
balancePenalty = |Σ_{e:pattern(e)=push} x_e - Σ_{e:pattern(e)=pull} x_e|
```
Баланс push/pull. Разница не более 1. Реализуется как два ограничения:

```
Σ push - Σ pull <= 1
Σ pull - Σ push <= 1
```

## 3. Weekly Process MILP — генерация расписания на неделю

### 3.1 Целевая функция

```
max Z_week = Σ_{t∈T} sessionScore(t) - overloadPenalty - imbalancePenalty
```

```
sessionScore(t) = Σ_{e∈E} z_{t,e} * w_e(t)
```
Сумма весов упражнений в тренировке `t`, где `w_e(t)` рассчитывается через Workout MILP.

```
overloadPenalty = Σ_{m∈M} max(0, weeklyLoad(m) - weeklyLoadLimit)
```
Штраф за превышение недельного лимита по мышце.

```
imbalancePenalty = Σ_{t1,t2 ∈ T} |load(t1) - load(t2)|
```
Штраф за дисбаланс нагрузки между тренировками.

### 3.2 Hard constraints

```
Σ_{d∈D} y_{t,d} = 1  для каждого t
```
Каждая тренировка назначается ровно на 1 день.

```
Σ_{t∈T} y_{t,d} <= 1  для каждого d
```
Не более 1 тренировки в день.

```
Σ_{t∈T} y_{t,d} = 0  для d ∉ availableDays
```
Тренировки только в доступные дни.

```
rest(t_i, t_j) >= minRestDays  для всех пар соседних тренировок
```
Минимальный отдых между тренировками.

```
rest(t_i, t_j) <= maxRestDays  для всех пар соседних тренировок
```
Максимальный отдых между тренировками.

```
consecutiveTrainingDays <= consecutiveLimit
```
Не более `consecutiveLimit` дней тренировок подряд.

### 3.3 Динамика усталости

После каждой тренировки `t` усталость обновляется:

```
F_m(t+1) = F_m(t) * exp(-lambda * restDays) + Σ_{e∈E_t} I(e,m) * s_e
```

Где:
- `F_m(t)` — усталость мышцы `m` перед тренировкой `t`
- `lambda = 0.345` (prior)
- `restDays` — количество дней отдыха с предыдущей тренировки
- `I(e,m)` — нагрузка упражнения `e` на мышцу `m`
- `s_e` — количество подходов (variable: compound или isolation)

### 3.4 Прогрессия внутри недели

Для loading-недель:

```
load(t_{i+1}) >= load(t_i) * 0.9
```

Для deload-недель:

```
load(t_i) <= weeklyLoadLimit * 0.7
```

## 4. Замена одной тренировки

При замене тренировки `t_replace` в неделе:

### 4.1 Вход

```ts
interface ReplaceWorkoutInput {
  sessionId: string;               // ID заменяемой сессии
  allowedTimeDeviationMin: number; // допустимое отклонение по времени
  allowedLoadDeviation: number;    // допустимое отклонение по нагрузке
  forbiddenExercises: string[];    // slug-коды запрещённых упражнений
  mandatoryMuscles: string[];      // мышцы, которые нельзя потерять
}
```

### 4.2 Правила замены

Вызов Workout MILP с дополнительными ограничениями:

```
x_e = 0  для e ∈ forbiddenExercises
Σ_{e∈E} x_e * I(e,m) >= Σ_{e∈E_old} x_e * I(e,m) * (1 - allowedLoadDeviation)  для m ∈ mandatoryMuscles
Σ_{e∈E} x_e * timeCostSec(e) <= oldDuration + allowedTimeDeviationMin * 60
Σ_{e∈E} x_e * timeCostSec(e) >= oldDuration - allowedTimeDeviationMin * 60
```

После замены пересчитать:
- `sessionLoadByMuscle` в `WorkoutSession.metadata`
- недельную усталость `F_m` для последующих тренировок

## 5. Нормализационные функции

```
norm(x) = x / max(all values)
clamp(x, lo, hi) = min(hi, max(lo, x))
recencyScore(e) = min(1, sessionsSinceLastUse(e) / diversity_window)
recoveryScore(m) = clamp(1 - F_m / theta, 0, 1)
equipmentMatch(e) = |available ∩ required(e)| / |required(e)|
contraScore(e,u) = Π k(severity_i) по всем пересечениям противопоказаний
```
