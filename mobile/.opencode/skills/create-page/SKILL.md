---
name: create-page
description: Создание страницы — ConsumerStatefulWidget + ErrorHandlingMixin. Флоу: riverpod loading → data → render dumb-виджетов. Retry max 3, exponential backoff. Ошибки через toast. < 250 строк. public.dart в каждой фиче.
---

## Что я делаю

Создаю **страницу** — верхний уровень UI-иерархии:
- Consumes riverpod-провайдеры
- Обрабатывает ошибки (ErrorHandlingMixin)
- Рендерит dumb/smart виджеты
- Управляет lifecycle страницы

## Когда использовать

- Создание нового экрана/роута
- Рефакторинг существующей страницы

## Чек-лист

### Обязательные проверки:

- [ ] **ConsumerStatefulWidget** + **ErrorHandlingMixin**
- [ ] **ref.watch(provider)** → `AsyncValue`
- [ ] **Флоу:** loading → data → render dumb/smart виджетов
- [ ] **Retry:** max 3, exponential backoff (1с, 2с, 3с) на уровне riverpod
- [ ] **< 250 строк**
- [ ] **Создаёт контроллеры**, передаёт в dumb/smart-виджеты
- [ ] **Нет `buildSomething()` методов** → виджеты
- [ ] **Нет Padding между виджетами**
- [ ] **public.dart** в фиче — экспорт страницы

## Шаблон: Базовая страница

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/core/mixins/error_handling_mixin.dart';
import 'package:mobile/features/exercises/exercises_provider.dart';
import 'package:mobile/features/exercises/presentation/smart_widgets/exercise_grid_smart.dart';

class ExercisesPage extends ConsumerStatefulWidget {
  const ExercisesPage({super.key});

  @override
  ConsumerState<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends ConsumerState<ExercisesPage>
    with ErrorHandlingMixin {
  @override
  Widget build(BuildContext context) {
    final asyncExercises = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Упражнения')),
      body: asyncExercises.when(
        loading: () => const ExerciseGridContainer.loading(),
        data: (exercises) => ExerciseGridContainer(
          exercises: exercises,
          onTap: (exercise) {
            // навигация через smart-обёртку или страницу
          },
        ),
        error: (e, st) {
          handleError(e, st, onRetry: () => ref.invalidate(exercisesProvider));
          return const ExerciseGridContainer.loading();
        },
      ),
    );
  }
}
```

## Шаблон: Страница с несколькими провайдерами

```dart
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with ErrorHandlingMixin {
  @override
  Widget build(BuildContext context) {
    final asyncHomeData = ref.watch(homeProvider);
    final asyncUser = ref.watch(authProvider);

    return Scaffold(
      body: switch ((asyncHomeData, asyncUser)) {
        (AsyncData(:final value), AsyncData(:final value as user)) => _HomeContent(
            homeData: value,
            user: user,
          ),
        _ => const _HomeLoading(),
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeData homeData;
  final UserModel user;

  const _HomeContent({required this.homeData, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 16,
        children: [
          ProfileHeader(user: user),
          WeekCalendarContainer(
            sessions: homeData.weekSessions,
            onSessionTap: (s) => context.push('/workouts/${s.id}'),
          ),
          DictionaryGridContainer(
            items: homeData.dictionaryItems,
            onTap: (item) => context.push(item.route),
          ),
        ],
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        spacing: 16,
        children: [
          ProfileHeader.loading(),
          WeekCalendarContainer.loading(),
          DictionaryGridContainer.loading(),
        ],
      ),
    );
  }
}
```

## ErrorHandlingMixin (планируемый)

Файл: `core/mixins/error_handling_mixin.dart`

```dart
mixin ErrorHandlingMixin on ConsumerStatefulWidget {
  void handleError(
    Object error,
    StackTrace stackTrace, {
    VoidCallback? onRetry,
  }) {
    final message = switch (error) {
      NetworkException(:final message) => message,
      AuthException() => 'Ошибка авторизации',
      ServerException(:final message) => message,
      TimeoutException() => 'Превышено время ожидания',
      _ => 'Произошла ошибка',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(label: 'Повторить', onPressed: onRetry)
            : null,
      ),
    );
  }
}
```

## Retry-wrapper для Riverpod (планируемый)

Файл: `core/utils/retry.dart`

```dart
Future<T> withRetry<T>(
  Future<T> Function() action, {
  int maxAttempts = 3,
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await action();
    } catch (e) {
      if (attempt == maxAttempts - 1) rethrow;
      await Future.delayed(Duration(seconds: attempt + 1));
    }
  }
  throw StateError('Unreachable');
}
```

Использование в provider:

```dart
@riverpod
Future<List<Exercise>> exercises(ExercisesRef ref) async {
  return withRetry(() => ref.read(exercisesApiProvider).getExercises());
}
```

## public.dart (в каждой фиче)

Файл: `features/<feature>/public.dart`

```dart
// Экспорт для использования в других фичах
export 'domain/exercise.dart';
export 'domain/exercise_category.dart';
export 'presentation/widgets/exercise_card.dart';
export 'presentation/smart_widgets/exercise_card_smart.dart';
// НЕ экспортируем: page, provider (они внутренние)
```

## Структура фичи

```
features/<feature>/
├── public.dart                          # Экспорт для других фич
├── <feature>_provider.dart              # Riverpod-провайдеры
├── data/
│   ├── <feature>_api.dart               # API-слой (Dio wrapper)
│   └── <feature>_repository.dart        # Репозиторий (бизнес-логика)
├── domain/
│   ├── <model>.dart                      # @freezed модели
│   └── ...
└── presentation/
    ├── <feature>_page.dart               # Страница (ConsumerStatefulWidget + ErrorHandlingMixin)
    ├── widgets/                          # Dumb-виджеты
    │   ├── <widget>.dart
    │   └── ...
    └── smart_widgets/                    # Smart-обёртки
        ├── <widget>_smart.dart
        └── ...
```

## Критерии готовности

- [ ] Страница < 250 строк
- [ ] ErrorHandlingMixin подключен
- [ ] Retry работает (max 3, exponential backoff)
- [ ] Все dumb-виджеты без riverpod
- [ ] public.dart создан
- [ ] Нет Padding между виджетами
- [ ] Флоу: loading → data → render

## Планируемые инфраструктурные элементы

Перед созданием первой страницы убедиться, что созданы:
- [ ] `core/mixins/error_handling_mixin.dart` — ErrorHandlingMixin
- [ ] `core/utils/retry.dart` — withRetry wrapper
- [ ] `design_system/widgets/sliver_gap.dart` — SliverGap
- [ ] `design_system/widgets/sliver_decorated_box.dart` — SliverDecoratedBox

Если их нет — создать перед страницей или спросить разработчика.

## Ссылки

- Полные правила: `ai_tools/rules.md`
- Dumb-виджеты на странице: skill `create-dumb-widget`
- Smart-обёртки на странице: skill `create-smart-widget`
- Контейнеры виджетов: skill `create-widget-container`
