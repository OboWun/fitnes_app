---
name: create-widget-container
description: Создание WidgetContainer — виджета для отрисовки группы/списка однотипных виджетов. Принимает List<T> + ValueChanged<T>? onTap. Имеет .loading() с количеством скелетонов. Без error-состояния. < 250 строк.
---

## Что я делаю

Создаю **WidgetContainer** — виджет, задача которого отрисовать группу однотипных виджетов:
- Принимает коллекцию данных
- Имеет `loading()`-состояние (решает сколько скелетонов рисовать)
- Не имеет error-состояния (ошибка на уровне страницы)

## Когда использовать

- Нужно отрисовать список/сетку/группу однотипных элементов
- **Все данные уже в памяти** (до ~10-15 элементов)
- Карточки упражнений (превью), списки тренировок, группы мышц
- Нужен loading-состояние с несколькими скелетонами

### НЕ использовать WidgetContainer когда:
- Данные подгружаются страницами с бэкенда → использовать `infinite_scroll_pagination` на уровне страницы
- Потенциально большое количество элементов → `ListView.builder` / `PagedListView`

## Чек-лист

### Обязательные проверки:

- [ ] **Принимает `List<T>`** данных + `ValueChanged<T>? onTap`
- [ ] **`const factory Container.loading()`** — приватный loading-класс, решает количество скелетонов
- [ ] **Нет error-состояния** — ошибка обрабатывается на уровне страницы
- [ ] **`spacing` на Column/Row** для одинаковых отступов, **`SizedBox`** для разных
- [ ] **< 250 строк**
- [ ] **Все дочерние виджеты приватные** (`_`)
- [ ] **Нет Padding для отступов между виджетами**
- [ ] **Внутренние виджеты — dumb** (без riverpod, без навигации)

## Шаблон: Grid-контейнер

```dart
import 'package:flutter/material.dart';

class ExerciseGridContainer extends StatelessWidget {
  final List<Exercise>? _exercises;
  final ValueChanged<Exercise>? _onTap;

  const ExerciseGridContainer({
    super.key,
    required List<Exercise> exercises,
    ValueChanged<Exercise>? onTap,
  })  : _exercises = exercises,
        _onTap = onTap;

  const ExerciseGridContainer.loading({super.key})
      : _exercises = null,
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_exercises == null) return const _ExerciseGridLoading();
    return _ExerciseGridData(exercises: _exercises!, onTap: _onTap);
  }
}

class _ExerciseGridData extends StatelessWidget {
  final List<Exercise> exercises;
  final ValueChanged<Exercise>? onTap;

  const _ExerciseGridData({required this.exercises, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: exercises
          .map((e) => ExerciseCard(exercise: e, onTap: onTap))
          .toList(),
    );
  }
}

class _ExerciseGridLoading extends StatelessWidget {
  const _ExerciseGridLoading();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(6, (_) => const ExerciseCard.loading()),
    );
  }
}
```

## Шаблон: List-контейнер

```dart
import 'package:flutter/material.dart';

class WorkoutListContainer extends StatelessWidget {
  final List<Workout>? _workouts;
  final ValueChanged<Workout>? _onTap;

  const WorkoutListContainer({
    super.key,
    required List<Workout> workouts,
    ValueChanged<Workout>? onTap,
  })  : _workouts = workouts,
        _onTap = onTap;

  const WorkoutListContainer.loading({super.key})
      : _workouts = null,
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_workouts == null) return const _WorkoutListLoading();
    return _WorkoutListData(workouts: _workouts!, onTap: _onTap);
  }
}

class _WorkoutListData extends StatelessWidget {
  final List<Workout> workouts;
  final ValueChanged<Workout>? onTap;

  const _WorkoutListData({required this.workouts, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: workouts
          .map((w) => WorkoutCard(workout: w, onTap: onTap))
          .toList(),
    );
  }
}

class _WorkoutListLoading extends StatelessWidget {
  const _WorkoutListLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: List.generate(3, (_) => const WorkoutCard.loading()),
    );
  }
}
```

## Шаблон: Контейнер с заголовком секции

```dart
class ExerciseSectionContainer extends StatelessWidget {
  final String title;
  final List<Exercise>? _exercises;
  final ValueChanged<Exercise>? _onTap;
  final VoidCallback? _onViewAll;

  const ExerciseSectionContainer({
    super.key,
    required this.title,
    required List<Exercise> exercises,
    ValueChanged<Exercise>? onTap,
    VoidCallback? onViewAll,
  })  : _exercises = exercises,
        _onTap = onTap,
        _onViewAll = onViewAll;

  const ExerciseSectionContainer.loading({super.key, required this.title})
      : _exercises = null,
        _onTap = null,
        _onViewAll = null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onViewAll: _onViewAll,
        ),
        const SizedBox(height: 12),
        if (_exercises == null)
          const _ExerciseSectionLoading()
        else
          _ExerciseSectionData(exercises: _exercises!, onTap: _onTap),
      ],
    );
  }
}

class _ExerciseSectionData extends StatelessWidget {
  final List<Exercise> exercises;
  final ValueChanged<Exercise>? onTap;

  const _ExerciseSectionData({required this.exercises, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 12,
        children: exercises
            .map((e) => ExerciseCard(exercise: e, onTap: onTap))
            .toList(),
      ),
    );
  }
}

class _ExerciseSectionLoading extends StatelessWidget {
  const _ExerciseSectionLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 12,
        children: List.generate(4, (_) => const ExerciseCard.loading()),
      ),
    );
  }
}
```

## Количество скелетонов

Loading-вариант решает сколько скелетонов рисовать:
- **Grid/Wrap:** 6 штук (типичная сетка 2-3 колонки)
- **Horizontal scroll:** 4 штука
- **Vertical list:** 3 штука
- **Кастомное:** если известно точное количество — использовать его

## Критерии готовности

- [ ] Есть data-конструктор и `.loading()`-конструктор
- [ ] Loading решает количество скелетонов
- [ ] Нет error-состояния
- [ ] Нет Padding между виджетами (только spacing/SizedBox)
- [ ] < 250 строк
- [ ] Все дочерние виджеты приватные

## Ссылки

- Полные правила: `ai_tools/rules.md`
- Dumb-виджет внутри контейнера: skill `create-dumb-widget`
- Smart-обёртка для контейнера: skill `create-smart-widget`
- Страница с контейнером: skill `create-page`
