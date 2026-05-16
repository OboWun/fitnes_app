---
name: create-smart-widget
description: Создание умной (smart) обёртки — ConsumerWidget/ConsumerStatefulWidget, который подключает riverpod, навигацию и lifecycle к dumb-виджету. < 250 строк. Всегда внутри features/<feature>/presentation/smart_widgets/.
---

## Что я делаю

Создаю **умную (smart) обёртку** — виджет, который:
- Оборачивает dumb-виджет
- Подключает riverpod (`ref.watch`, `ref.read`)
- Обрабатывает навигацию
- Управляет lifecycle (контроллеры, подписки)
- Передаёт данные в dumb-виджет через его API (value/onChanged)

## Когда использовать

- Dumb-виджет нужно подключить к riverpod-провайдеру
- Dumb-виджет должен инициировать навигацию при действии
- Нужен lifecycle (создание/dispose контроллеров, подписки)
- Страница использует виджет, но данные идут через provider

## Чек-лист

### Обязательные проверки:

- [ ] **Оборачивает dumb-виджет** — не рисует UI сам
- [ ] **Riverpod:** `ref.watch` для данных, `ref.read` для действий
- [ ] **Навигация:** `context.go()`, `context.push()` и т.д.
- [ ] **Lifecycle:** `initState`, `dispose` (контроллеры, подписки)
- [ ] **Передаёт данные через API dumb-виджета** — `value` + `onChanged`
- [ ] **< 250 строк**
- [ ] **Размещение:** `features/<feature>/presentation/smart_widgets/`
- [ ] **Экспорт:** добавлен в `features/<feature>/public.dart`

## Шаблон: ConsumerWidget (без состояния)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/features/exercises/presentation/widgets/exercise_card.dart';
import 'package:mobile/features/exercises/exercises_provider.dart';

class ExerciseCardSmart extends ConsumerWidget {
  final String exerciseId;

  const ExerciseCardSmart({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExercise = ref.watch(exerciseProvider(exerciseId));

    return asyncExercise.when(
      data: (exercise) => ExerciseCard(
        exercise: exercise,
        onTap: (e) => context.push('/exercises/${e.id}'),
      ),
      loading: () => const ExerciseCard.loading(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}
```

## Шаблон: ConsumerStatefulWidget (с состоянием/lifecycle)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/features/exercises/presentation/widgets/exercise_search_field.dart';
import 'package:mobile/features/exercises/exercises_provider.dart';

class ExerciseSearchSmart extends ConsumerStatefulWidget {
  const ExerciseSearchSmart({super.key});

  @override
  ConsumerState<ExerciseSearchSmart> createState() => _ExerciseSearchSmartState();
}

class _ExerciseSearchSmartState extends ConsumerState<ExerciseSearchSmart> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseSearchField(
      controller: _controller,
      onChanged: (query) {
        ref.read(exerciseSearchProvider.notifier).search(query);
      },
    );
  }
}
```

## Шаблон: Smart-обёртка с ValueNotifier для локального состояния

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/features/home/presentation/widgets/week_calendar.dart';
import 'package:mobile/features/home/home_provider.dart';

class WeekCalendarSmart extends ConsumerWidget {
  const WeekCalendarSmart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeProvider);

    return homeData.when(
      data: (data) => WeekCalendar(
        sessions: data.weekSessions,
        onSessionTap: (session) {
          context.push('/workouts/${session.id}');
        },
      ),
      loading: () => const WeekCalendar.loading(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}
```

## Паттерн: Error на уровне smart-виджета

Если smart-виджет обрабатывает ошибку самостоятельно (не на уровне страницы):

```dart
return asyncExercise.when(
  data: (exercise) => ExerciseCard(exercise: exercise, onTap: onTap),
  loading: () => const ExerciseCard.loading(),
  error: (e, _) {
    // Ошибка обрабатывается на уровне страницы через ErrorHandlingMixin
    // Smart-виджет не показывает ошибки сам
    return const ExerciseCard.loading();
  },
);
```

**Важно:** Ошибки обрабатываются на уровне **страницы** (ErrorHandlingMixin). Smart-виджет в случае ошибки может показать loading-состояние или пустое место. Если нужна кастомная обработка — спросить разработчика.

## Критерии готовности

- [ ] Оборачивает dumb-виджет, не дублирует UI
- [ ] Riverpod подключен корректно
- [ ] Навигация работает
- [ ] Lifecycle управляется (контроллеры dispose)
- [ ] Данные передаются через API dumb-виджета
- [ ] < 250 строк
- [ ] Добавлен в `public.dart` фичи

## Ссылки

- Полные правила: `ai_tools/rules.md`
- Dumb-виджет для обёртки: skill `create-dumb-widget`
- Страница (верхний уровень): skill `create-page`
