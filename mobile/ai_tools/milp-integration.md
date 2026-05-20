# MILP Integration — Workout Dialog → Template / Plan → Activate

## Обзор

Когда пользователь завершает диалог с тренером (workout-dialog), собранные параметры (`generateParams` или `weeklyParams`) передаются в MILP-эндпоинты бэкенда. MILP генерирует упражнения и создаёт WorkoutTemplate (для одной тренировки) или TrainingPlan с WorkoutSession'ами (для недельного плана). После создания — модальное окно с предложением активировать план.

---

## Текущее состояние

### Что уже работает

1. **Workout-dialog** — полный флоу из 16 шагов, завершается `DialogComplete` с `planType` ('generate' / 'weekly') и собранными параметрами
2. **MILP endpoints на бэкенде** — `POST /workout-milp/generate` и `POST /workout-milp/weekly-plan` — оба работают и возвращают результаты
3. **CRUD шаблонов/планов** — создание, просмотр, удаление
4. **List providers** — `templateListProvider` и `planListProvider` с `refresh()` для обновления списков
5. **Activate** — `POST /training-plans/:id/activate` (после фикса `block_id DROP NOT NULL`)
6. **Home provider** — `homeProvider` с `refresh()` методом, `keepAlive: true`

### Что не работает (зазор)

1. После завершения диалога — страница просто показывает `DialogCompleteCard` и закрывается. **MILP не вызывается.**
2. Нет `WorkoutMilpApi` / `WorkoutMilpRepository` на фронте
3. Нет модального окна "Активировать план?"
4. После активации — `homeProvider` не инвалидируется

---

## Data Flow

### planType = 'generate' (одна тренировка)

```
DialogComplete.generateParams
    │
    ▼
POST /workout-milp/generate { experienceLevel, goal, focusMuscles, ... }
    │
    ▼
Response: {
    templateId: string,           ← Бэкенд УЖЕ создаёт шаблон!
    exercises: [{ exerciseSlug, sets, repsPerSet, order }],
    totalTimeSec: number,
    totalLoadByMuscle: Record<string, number>,
    usedFallback?: boolean,
    partialCoverage?: boolean,
    unmetMandatory?: string[],
    metrics: {
        totalSets, totalReps, estimatedTonnageKg,
        relativeIntensity, activeTimeSec, restTimeSec,
        estimatedCalories, muscleLoadScores, fatigueIndex
    }
}
    │
    ▼
Navigate to /workouts/{templateId}   ← TemplateDetailPage
```

**Важно:** Бэкенд `/workout-milp/generate` УЖЕ создаёт WorkoutTemplate в БД (строка `this.createTemplateFromResult` в контроллере). Фронту не нужно создавать шаблон отдельно — достаточно вызвать MILP и получить `templateId`.

### planType = 'weekly' (план на неделю)

```
DialogComplete.weeklyParams
    │
    ▼
POST /workout-milp/weekly-plan { experienceLevel, goal, availableDays, ... }
    │
    ▼
Response: {
    planId: string,               ← ID созданного TrainingPlan
    splitName: string,
    sessions: [{
        dayOfWeek: string,
        sessionType: string,      ← 'full_body' | 'upper' | 'lower' | 'push' | 'pull' | 'legs'
        exercises: [{ exerciseSlug, sets, repsPerSet, order }],
        loadByMuscle: Record<string, number>,
        totalTimeSec: number,
        usedFallback?: boolean,
        repsPerSet: number
    }],
    totalWeeklyLoad: number,
    weeklyVolumeByMuscle: Record<string, number>
}
    │
    ▼
Show activate dialog → if yes: POST /training-plans/{planId}/activate
    │
    ▼
Navigate to /training-plans/{planId}   ← PlanDetailPage
```

**Важно:** Бэкенд `/workout-milp/weekly-plan` УЖЕ создаёт TrainingPlan с WorkoutSession'ами (создаёт entity в БД через `WeeklyProcessMilpService`). Однако план создаётся как `isActive: false`. Для начала тренировок нужно активировать.

---

## Mapping: Dialog → MILP

### generate (planType = 'generate')

| Dialog field (generateParams) | MILP param (GenerateWorkoutDto) | Примечание |
|---|---|---|
| `experienceLevel` | `experienceLevel` | Прямой маппинг |
| `goal` | `goal` | Прямой маппинг |
| `availableEquipment` | `availableEquipment` | Массив строк |
| `sessionDurationMin` | `sessionDurationMin` | Number или null |
| `focusMuscles` | `focusMuscles` | Массив строк |
| `activityLevel` | `activityLevel` | Прямой маппинг |
| `cardioPreference` | `cardioPreference` | Прямой маппинг |
| `primaryLifts` | `primaryLifts` | Массив строк |
| `enduranceType` | `enduranceType` | Прямой маппинг |
| `targetWeightKg` | — | Не передаётся в generate |
| — | `equipmentPresetId` | Не используется (оборудование уже resolved) |

### weekly (planType = 'weekly')

| Dialog field (weeklyParams) | MILP param (GenerateWeeklyPlanDto) | Примечание |
|---|---|---|
| `experienceLevel` | `experienceLevel` | Прямой маппинг |
| `goal` | `goal` | Прямой маппинг |
| `availableEquipment` | `availableEquipment` | Массив строк |
| `sessionDurationMin` | `sessionDurationMin` | Number или null |
| `availableDays` | `availableDays` | Массив строк (monday..sunday) |
| `trainingCountPerWeek` | `trainingCountPerWeek` | Number или null |
| `splitType` | `splitType` | Строка (auto/full_body/upper_lower/ppl) |
| `activityLevel` | `activityLevel` | Прямой маппинг |
| `cardioPreference` | `cardioPreference` | Прямой маппинг |
| `primaryLifts` | `primaryLifts` | Массив строк |
| `enduranceType` | `enduranceType` | Прямой маппинг |
| `targetWeightKg` | `targetWeightKg` | Number |

**Автоматические параметры бэкенда** (фронту не нужно передавать):
- `fatigueByMuscle` — вычисляется из 14-дневной истории
- `usedExercises` — вычисляется из 14-дневной истории
- `userContraindications` — из профиля пользователя
- `gender`, `age`, `heightCm`, `weightKg` — из профиля
- `weeklyVolumeByMuscle` — вычисляется из 7-дневной истории
- Equipment resolution (preset > explicit > profile)

---

## Файлы для создания

### 1. `lib/features/workout_milp/data/workout_milp_api.dart`

```dart
@riverpod
WorkoutMilpApi workoutMilpApi(WorkoutMilpApiRef ref) {
    return WorkoutMilpApi(ref.watch(dioProvider));
}

class WorkoutMilpApi {
    final Dio _dio;

    // POST /workout-milp/generate
    Future<Map<String, dynamic>> generate(Map<String, dynamic> params) async {
        final response = await _dio.post('/workout-milp/generate', data: params);
        return response.data as Map<String, dynamic>;
    }

    // POST /workout-milp/weekly-plan
    Future<Map<String, dynamic>> weeklyPlan(Map<String, dynamic> params) async {
        final response = await _dio.post('/workout-milp/weekly-plan', data: params);
        return response.data as Map<String, dynamic>;
    }
}
```

### 2. `lib/features/workout_milp/data/workout_milp_repository.dart`

```dart
@riverpod
WorkoutMilpRepository workoutMilpRepository(WorkoutMilpRepositoryRef ref) {
    return WorkoutMilpRepository(ref.watch(workoutMilpApiProvider));
}

class WorkoutMilpRepository {
    final WorkoutMilpApi _api;

    // Возвращает { templateId, exercises, totalTimeSec, metrics, ... }
    Future<Map<String, dynamic>> generate(Map<String, dynamic> params) async {
        return withRetry(() => _api.generate(params));
    }

    // Возвращает { planId, splitName, sessions[], ... }
    Future<Map<String, dynamic>> weeklyPlan(Map<String, dynamic> params) async {
        return withRetry(() => _api.weeklyPlan(params));
    }
}
```

**Примечание:** Доменные модели для MILP-результата НЕ нужны — достаточно `Map<String, dynamic>`. Причина: результат MILP используется только для извлечения `templateId` / `planId` и навигации. Детали уже доступны через `GET /workout-templates/:id` и `GET /training-plans/:id`.

---

## Изменяемые файлы

### 3. `workout_dialog_page.dart` — основная интеграция

**Текущий флоу завершения:**
```
_sendAnswer() → result is DialogComplete → _completeResult = result → показывает DialogCompleteCard → onClose → pop()
```

**Новый флоу завершения:**
```
_sendAnswer() → result is DialogComplete → _completeResult = result →
    показывает DialogCompleteCard с кнопкой "Создать тренировку" / "Создать план" →
    _onCreate() →
        setState(_isCreating = true) →
        вызывает MILP →
        result['templateId'] или result['planId'] →
        если weekly: _showActivateDialog(planId) →
        навигация на деталку
```

**Изменения в `_sendAnswer`:**
- При получении `DialogComplete`: вместо простого хранения — добавить кнопку CTA в messages

**Новый метод `_onCreateFromDialog()`:**
```dart
Future<void> _onCreateFromDialog() async {
    if (_completeResult == null) return;
    setState(() => _isCreating = true);

    try {
        final repo = ref.read(workoutMilpRepositoryProvider);
        final params = _completeResult!.generateParams ?? _completeResult!.weeklyParams ?? {};

        if (_completeResult!.planType == 'generate') {
            final result = await repo.generate(params);
            final templateId = result['templateId'] as String;

            if (mounted) {
                ref.read(templateListProvider.notifier).refresh();
                context.push('/workouts/$templateId');
            }
        } else {
            final result = await repo.weeklyPlan(params);
            final planId = result['planId'] as String;

            if (mounted) {
                ref.read(planListProvider.notifier).refresh();
                final shouldActivate = await _showActivateDialog(context);
                if (shouldActivate == true) {
                    final planRepo = ref.read(trainingPlanRepositoryProvider);
                    await planRepo.activate(planId);
                    ref.read(planListProvider.notifier).refresh();
                    ref.read(homeProvider.notifier).refresh();
                }
                context.push('/training-plans/$planId');
            }
        }
    } catch (e) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка: $e')),
            );
        }
    } finally {
        if (mounted) setState(() => _isCreating = false);
    }
}
```

**Новый метод `_showActivateDialog()`:**
```dart
Future<bool?> _showActivateDialog(BuildContext context) {
    return showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
            title: Text('План готов!'),
            content: Text(
                'Сделать этот план активным? '
                'Вы всегда сможете отредактировать его позже.',
            ),
            actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text('Позже'),
                ),
                ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text('Активировать'),
                ),
            ],
        ),
    );
}
```

### 4. `dialog_complete_card.dart` — заменить кнопку "Закрыть" на CTA

**Текущий API:**
```dart
DialogCompleteCard({ required DialogComplete result, VoidCallback? onClose })
```

**Новый API:**
```dart
DialogCompleteCard({
    required DialogComplete result,
    VoidCallback? onCreate,     // основная CTA
    bool isCreating = false,    // loading state
})
```

**Изменения в UI:**
- Убрать кнопку "Закрыть"
- Добавить кнопку:
  - generate: "Создать тренировку" (gradient blue, full width)
  - weekly: "Создать план" (gradient purple, full width)
- Кнопка показывает `CircularProgressIndicator` при `isCreating = true`
- Под кнопкой мелкий текст: "Это может занять несколько секунд"

### 5. `workout_dialog_page.dart` — после навигации

**При `pop()` из деталки (возврат на диалог):**
- Диалог закрывается (pop) — пользователь уже на деталке шаблона/плана
- Или: диалог остаётся до нажатия CTA, после навигации — pop диалога

**Рекомендуемый флоу:**
1. Пользователь жмёт "Создать" → loading → MILP → навигация на деталку
2. DialogPage pop'ается — пользователь видит TemplateDetailPage / PlanDetailPage
3. Если weekly + activate → `homeProvider.refresh()` → пользователь при возврате на HomePage видит обновлённые данные

---

## Activate Dialog — дизайн

```
┌─────────────────────────────────────┐
│                                     │
│        🎉 План готов!              │
│                                     │
│   Сделать этот план активным?       │
│   Вы всегда сможете отредактировать │
│   его позже.                        │
│                                     │
│   ┌──────────┐  ┌─────────────────┐ │
│   │  Позже    │  │  Активировать   │ │
│   └──────────┘  └─────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

**Если "Активировать":**
1. `POST /training-plans/{planId}/activate`
2. `ref.read(planListProvider.notifier).refresh()` — обновить список планов
3. `ref.read(homeProvider.notifier).refresh()` — обновить главную (появятся planned sessions)
4. `context.push('/training-plans/$planId')` — перейти на деталку плана

**Если "Позже":**
1. `context.push('/training-plans/$planId')` — перейти на деталку плана
2. На PlanDetailPage будет кнопка "Активировать"

---

## Error Handling

### MILP возвращает `usedFallback: true`
- Показать тост: "Подобрали ближайший вариант под ваши параметры"

### MILP возвращает `partialCoverage: true`
- Показать тост: "Не все целевые мышцы покрыты — вы можете дополнить план вручную"

### MILP падает (network error / 500)
- Показать тост с ошибкой
- Предложить: "Попробовать ещё раз" или "Создать вручную"
- Кнопка "Создать вручную" → `context.push('/workouts/new')` или `context.push('/training-plans/new')`
- Параметры диалога теряются — пользователь создаёт с нуля

### Activate падает (400 — план уже активен / другой активен)
- Показать тост с ошибкой
- Всё равно перейти на деталку плана

---

## Порядок реализации

| # | Задача | Файлы | Сложность |
|---|--------|-------|-----------|
| 1 | Создать WorkoutMilpApi | `workout_milp_api.dart` | low |
| 2 | Создать WorkoutMilpRepository | `workout_milp_repository.dart` | low |
| 3 | Обновить DialogCompleteCard — заменить "Закрыть" на CTA | `dialog_complete_card.dart` | medium |
| 4 | Обновить WorkoutDialogPage — _onCreateFromDialog + _showActivateDialog | `workout_dialog_page.dart` | high |
| 5 | Добавить state flags: _isCreating, обработка ошибок | `workout_dialog_page.dart` | medium |
| 6 | Инвалидация провайдеров после создания | `workout_dialog_page.dart` | low |
| 7 | Home refresh после activate | `workout_dialog_page.dart` | low |
| 8 | build_runner + flutter analyze | — | low |

**Общая оценка:** ~3-4 часа работы

---

## Зависимости

### Должно быть сделано ДО:
- [x] Фикс `block_id NOT NULL` (миграция бэкенда)
- [x] `templateListProvider` + `planListProvider` с `refresh()`
- [x] `homeProvider` с `refresh()` методом
- [x] Роуты: `/workouts/:id`, `/training-plans/:id`
- [x] `WorkoutDialogPage` с `_completeResult` хранением

### Может быть сделано ПОСЛЕ:
- Анимация загрузки при генерации (прогресс-бар, shimmer)
- Кэширование результатов MILP для offline
- Retry при ошибке MILP с exponential backoff
- Pre-fill диалога из профиля пользователя (бэкенд уже делает auto-skip)

---

## Тестирование

### Ручной тест-кейс: generate
1. Открыть HomePage → нажать "С тренером" (или FAB на WorkoutsPage)
2. Пройти диалог: plan_type = "generate", goal = "strength", experience = "intermediate"
3. После завершения — увидеть карточку с параметрами + кнопку "Создать тренировку"
4. Нажать — появляется loading
5. MILP возвращает templateId → навигация на `/workouts/{id}`
6. TemplateDetailPage показывает сгенерированные упражнения

### Ручной тест-кейс: weekly + activate
1. Открыть диалог: plan_type = "weekly"
2. Выбрать 3 дня, цель "hypertrophy"
3. После завершения — кнопка "Создать план"
4. Нажать → loading → MILP → planId
5. Появляется диалог "План готов! Активировать?"
6. Нажать "Активировать" → activate → homeProvider.refresh()
7. Навигация на `/training-plans/{planId}` — виден бейдж "Активный"
8. Вернуться на HomePage → увидеть NextWorkoutCard с planned session

### Ручной тест-кейс: weekly + "Позже"
1. То же что выше, но нажать "Позже"
2. Навигация на `/training-plans/{planId}` — кнопка "Активировать" внизу
3. HomePage не обновляется (нет planned sessions)

### Ручной тест-кейс: ошибка MILP
1. Отключить бэкенд или вернуть 500
2. Нажать "Создать" → ошибка → тост "Ошибка: ..."
3. Кнопка снова доступна для повторной попытки

---

## Схема навигации

```
HomePage
  │
  ├── [FAB] "С тренером" ──→ WorkoutDialogPage
  │     │
  │     ├── 16 шагов диалога
  │     │
  │     ├── DialogCompleteCard
  │     │     │
  │     │     ├── [generate] "Создать тренировку"
  │     │     │     └── MILP generate → templateId
  │     │     │         └── push /workouts/{id} → TemplateDetailPage
  │     │     │
  │     │     └── [weekly] "Создать план"
  │     │           └── MILP weekly-plan → planId
  │     │               └── ActivateDialog
  │     │                     ├── [Да] → activate → homeRefresh → push /training-plans/{id}
  │     │                     └── [Нет] → push /training-plans/{id}
  │     │
  │     └── (после навигации диалог закрывается)
  │
  └── [если activeBlock != null]
        └── NextWorkoutCard → push /workout-session/{id}
```
