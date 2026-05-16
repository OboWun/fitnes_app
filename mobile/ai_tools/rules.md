# Правила архитектуры UI — Flutter Fitness App

Этот файл — единый источник истины для всех UI-правил проекта. Все скиллы в `.opencode/skills/` ссылаются сюда.

---

## Принцип выделения Feature

Feature — это **ограниченный контекст предметной области**, который:
1. Имеет собственную **доменную модель** (data-классы, enum'ы)
2. Имеет хотя бы один **provider** (riverpod) или **страницу**
3. Может иметь **API-слой** (если ходит в бэкенд)
4. Имеет **public.dart** — экспорт всего, что может использоваться в других фичах

### Признаки того, что это отдельная фича:
- Есть отдельный эндпоинт бэкенда
- Есть отдельная страница/роут
- Есть собственная доменная модель, не являющаяся частью другой фичи

### Признаки того, что это НЕ отдельная фича:
- Виджет используется только внутри одной фичи → остаётся в `presentation/widgets/`
- Модель является вложенной частью другой модели → остаётся в `domain/` этой фичи
- Provider читает данные чужой фичи → это consumer, а не owner

### Примеры фич:
- `auth` — device auth, profile, JWT (owns UserModel, AuthState)
- `onboarding` — 5-step wizard (owns OnboardingState)
- `home` — главная страница (owns HomeData, WeekSession)
- `exercises` — каталог упражнений (owns Exercise, ExerciseCategory)
- `workouts` — тренировки (owns Workout, WorkoutSession)
- `profile` — профиль пользователя

---

## public.dart

В каждой фиче создаётся `public.dart`, который экспортирует всё, что может использоваться в других фичах:

```dart
// features/exercises/public.dart
export 'domain/exercise.dart';
export 'domain/exercise_category.dart';
export 'presentation/widgets/exercise_card.dart';
export 'presentation/smart_widgets/exercise_picker.dart';
```

Другие фичи импортируют только через `public.dart`:
```dart
import 'package:mobile/features/exercises/public.dart';
```

---

## Правило 1. InkWell для обработки нажатий

**Приоритет:** `InkWell` > `GestureDetector`

`InkWell` предоставляет визуальную обратную связь (ripple). `GestureDetector` используем только если:
- Нужны свайпы, длинное нажатие, двойной тап
- InkWell конфликтует с родительским Material

```dart
// ✅ Правильно
InkWell(
  onTap: onTap,
  borderRadius: BorderRadius.circular(12),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Text(user.name),
  ),
)

// ❌ Неправильно
GestureDetector(
  onTap: onTap,
  child: Text(user.name),
)
```

---

## Правило 2. ValueNotifier для локального состояния

**Приоритет:** `ValueNotifier` + `ValueListenableBuilder` > `setState` > Riverpod

Локальное состояние виджета (текущая страница, раскрыто/скрыто, выбранный таб) — на `ValueNotifier`.

Riverpod — только для данных с бэкенда или глобального состояния.

```dart
class WeekCalendar extends StatelessWidget {
  final List<WeekSession> sessions;
  final ValueChanged<WeekSession>? onSessionTap;

  const WeekCalendar({super.key, required this.sessions, this.onSessionTap});
  const WeekCalendar.loading({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPage = ValueNotifier<DateTime>(DateTime.now());

    return ValueListenableBuilder<DateTime>(
      valueListenable: currentPage,
      builder: (context, date, _) {
        return Row(
          children: sessions.map((s) => _DayCard(session: s, onTap: onSessionTap)).toList(),
        );
      },
    );
  }
}
```

---

## Правило 3. Без buildSomething методов

`buildHeader()`, `buildBody()`, `buildFooter()` — **дурной тон**. Каждый такой метод — кандидат в виджет.

### Варианты:
1. **Отдельный приватный виджет** — если используется только в этом файле
2. **Отдельный публичный виджет** — если может переиспользоваться
3. **`part` / `part of`** — если файл разрастается, но виджет логически единый

```dart
// ❌ Неправильно
class HomePage extends StatelessWidget {
  Widget _buildHeader() => ...;
  Widget _buildCalendar() => ...;
  Widget _buildDictionary() => ...;
}

// ✅ Правильно — приватные виджеты
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileHeader(user: user),
        _WeekCalendar(sessions: sessions),
        _DictionaryGrid(items: items),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget { ... }
class _WeekCalendar extends StatelessWidget { ... }
class _DictionaryGrid extends StatelessWidget { ... }
```

### part / part of — когда файл > 250 строк

```dart
// home_page.dart
part '_profile_header.dart';
part '_week_calendar.dart';
part '_dictionary_grid.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileHeader(user: user),
        _WeekCalendar(sessions: sessions),
        _DictionaryGrid(items: items, onTap: onItemTap),
      ],
    );
  }
}

// _profile_header.dart
part of 'home_page.dart';

class _ProfileHeader extends StatelessWidget { ... }
```

---

## Правило 4. Без Padding для отступов между виджетами

### Запрещено:
- `Padding` для задания отступа **между** виджетами
- `margin` (в контексте Container) для отступов между виджетами

### Разрешено:
- `Column(spacing: 16)` / `Row(spacing: 16)` — если отступ одинаковый
- `const SizedBox(height: 16)` / `const SizedBox(width: 16)` — если разный
- `Padding` — **только для внутренних отступов** виджета (чтобы разместить свой контент)

```dart
// ✅ Правильно — spacing на Column
Column(
  spacing: 16,
  children: [
    _ProfileHeader(user: user),
    _WeekCalendar(sessions: sessions),
    _DictionaryGrid(items: items),
  ],
)

// ✅ Правильно — SizedBox для разного отступа
Column(
  children: [
    _ProfileHeader(user: user),
    const SizedBox(height: 8),
    _SectionHeader(title: 'Тренировки'),
    const SizedBox(height: 16),
    _WeekCalendar(sessions: sessions),
  ],
)

// ✅ Правильно — внутренний padding виджета (карточка размещает свой контент)
class _ExerciseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [...]),
      ),
    );
  }
}

// ❌ Неправильно — padding как отступ между виджетами
Column(
  children: [
    _ProfileHeader(user: user),
    Padding(padding: EdgeInsets.only(bottom: 16)), // ЗАПРЕЩЕНО
    _WeekCalendar(sessions: sessions),
  ],
)
```

### Для Sliver — запланированные утилиты:
- `SliverGap` — отступ между sliver-элементами
- `SliverDecoratedBox` — декоративный бокс в sliver-контексте

Разместить в `design_system/widgets/` при необходимости.

---

## Правило 5. Widget.loading() — union-паттерн

Каждый виджет должен уметь рисовать своё загрузочное состояние. Паттерн — **без freezed**, через `const factory` и приватные классы.

### StatelessWidget:

```dart
class UserCard extends StatelessWidget {
  final UserModel? _user;
  final ValueChanged<UserModel>? _onTap;

  const UserCard({super.key, required UserModel user, ValueChanged<UserModel>? onTap})
      : _user = user,
        _onTap = onTap;
  const UserCard.loading({super.key})
      : _user = null,
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const _UserCardLoading();
    return _UserCardData(user: _user!, onTap: _onTap);
  }
}

class _UserCardData extends StatelessWidget {
  final UserModel user;
  final ValueChanged<UserModel>? onTap;

  const _UserCardData({required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(user),
      child: Text(user.name),
    );
  }
}

class _UserCardLoading extends StatelessWidget {
  const _UserCardLoading();

  @override
  Widget build(BuildContext context) {
    return const ShimmerCard();
  }
}
```

### StatefulWidget:

Для StatefulWidget делаем **абстрактный класс** с const-конструктором без параметров, от которого наследуются:
- Основной виджет с параметрами (StatefulWidget)
- Loading-виджет (StatelessWidget)

```dart
abstract class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  const factory AuthForm.data({
    required UserModel user,
    ValueChanged<UserModel>? onSubmit,
    TextEditingController? loginController,
    TextEditingController? passwordController,
  }) = _DataAuthForm;

  const factory AuthForm.loading() = _LoadingAuthForm;
}

class _DataAuthForm extends AuthForm {
  final UserModel user;
  final ValueChanged<UserModel>? onSubmit;
  final TextEditingController? loginController;
  final TextEditingController? passwordController;

  const _DataAuthForm({
    required this.user,
    this.onSubmit,
    this.loginController,
    this.passwordController,
  });

  @override
  State<_DataAuthForm> createState() => _DataAuthFormState();
}

class _LoadingAuthForm extends StatelessWidget implements AuthForm {
  const _LoadingAuthForm();

  @override
  State<StatefulWidget> createState() => StatefulElement(this).state;

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ShimmerField(),
        SizedBox(height: 16),
        ShimmerField(),
      ],
    );
  }
}
```

### Важно:
- Все дочерние виджеты (Data/Loading) — **приватные**
- Публичный API только через factory-конструкторы на главном классе
- Loading-вариант не принимает данных, не имеет контроллеров

---

## Правило 6. API виджета — value + onChanged

Виджет предоставляет API для работы со своим состоянием:

```dart
// Паттерн: <T> value + ValueChanged<T>? onChanged
class GenderSelector extends StatelessWidget {
  final Gender value;
  final ValueChanged<Gender>? onChanged;

  const GenderSelector({super.key, required this.value, this.onChanged});
  const GenderSelector.loading({super.key});

  @override
  Widget build(BuildContext context) { ... }
}
```

### Контроллеры — optional:
```dart
class SearchField extends StatelessWidget {
  final String value;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchField({
    super.key,
    required this.value,
    this.onChanged,
    this.controller,
  });
  const SearchField.loading({super.key});
}
```

`onChanged` вызывается как **факт совершения действия** (аналог `Checkbox.onChanged`).

---

## Правило 7. Концепция Dumb / Smart виджетов

### Dumb-виджет (глупый):
- Рисует данные
- Предоставляет API: `value` + `onChanged` / `onTap`
- **НЕ** знает про riverpod (ни `ref.watch`, ни `ref.read`)
- **НЕ** осуществляет навигацию (`context.go()`, `Navigator.push()`)
- **НЕ** создаёт провайдеры
- `const`-constructible по возможности

### Smart-виджет (умный):
- Оборачивает dumb-виджет
- Подключает riverpod (`ref.watch`, `ref.read`)
- Обрабатывает навигацию
- Управляет lifecycle (контроллеры, подписки)
- Передаёт данные в dumb-виджет через его API

### Где живёт:
- **Dumb** — `features/<feature>/presentation/widgets/`
- **Smart** — `features/<feature>/presentation/smart_widgets/`
- **Page** — это базовый smart-виджет (самый верхний уровень)

### Пример:

```dart
// Dumb — features/exercises/presentation/widgets/exercise_card.dart
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final ValueChanged<Exercise>? onTap;

  const ExerciseCard({super.key, required this.exercise, this.onTap});
  const ExerciseCard.loading({super.key});

  @override
  Widget build(BuildContext context) { ... }
}

// Smart — features/exercises/presentation/smart_widgets/exercise_card_smart.dart
class ExerciseCardSmart extends ConsumerWidget {
  final String exerciseId;

  const ExerciseCardSmart({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = ref.watch(exerciseProvider(exerciseId));
    return exercise.when(
      data: (e) => ExerciseCard(exercise: e, onTap: (e) => context.push('/exercises/${e.id}')),
      loading: () => const ExerciseCard.loading(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

---

## Правило 8. Riverpod — только для запросов и глобального состояния

### Riverpod используем для:
- HTTP-запросов (AsyncNotifier, FutureProvider)
- Глобального состояния (auth, пользователь, настройки)

### НЕ используем Riverpod для:
- Локального состояния виджета → `ValueNotifier`
- Локального состояния страницы → `StatefulWidget` + `setState` / `ValueNotifier`
- Состояния формы → `TextEditingController` + `GlobalKey<FormState>`

### Retry в Riverpod:
- Максимум **3 retry** с exponential backoff: **1с, 2с, 3с**
- Реализуется на уровне riverpod provider (не Dio interceptor)
- При ошибке показывается toast (ErrorHandlingMixin на странице)

---

## Правило 9. Максимум 250 строк

Файл верстки виджета/страницы **не может превышать 250 строк**.

### Если файл разрастается:
1. Выделить приватные виджеты (`_PrivateWidget`)
2. Использовать `part` / `part of` для разбивки файла
3. Вынести в отдельный файл в той же папке

### Базовый флоу страницы:
```
1. Page (ConsumerStatefulWidget + ErrorHandlingMixin)
2. ref.watch(provider) → AsyncValue
3. AsyncValue.when(
     loading: () => DumbWidget.loading(),
     data: (data) => DumbWidget(data: data),
     error: (e, _) => handled by ErrorHandlingMixin (toast + reload),
   )
```

---

## Правило 10. WidgetContainer для групп виджетов

Для отрисовки группы/списка виджетов создаётся **WidgetContainer**.

### API:
- Принимает `List<T>` данных + `ValueChanged<T>? onTap`
- Имеет `const factory Container.loading()` — сам решает сколько скелетонов рисовать
- **НЕ имеет error-состояния** — ошибка обрабатывается на уровне страницы

```dart
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
    if (_exercises == null) {
      return const _ExerciseGridLoading();
    }
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
      children: exercises.map((e) => ExerciseCard(exercise: e, onTap: onTap)).toList(),
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

---

## Планируемые инфраструктурные элементы

### ErrorHandlingMixin
- Файл: `core/mixins/error_handling_mixin.dart`
- Mixin для StatefulWidget
- Ловит `AppException`, показывает toast сверху с кнопкой перезагрузки
- При ошибке страница в состоянии загрузки

### Retry-wrapper для Riverpod
- Файл: `core/utils/retry.dart`
- Максимум 3 retry, exponential backoff (1с, 2с, 3с)
- Используется внутри provider'ов

### SliverGap, SliverDecoratedBox
- Файл: `design_system/widgets/sliver_gap.dart`, `design_system/widgets/sliver_decorated_box.dart`
- Утилиты для работы со sliver-контекстом

---

## Обновление правил

Правила могут появляться и изменяться в процессе разработки. При каждом изменении:
1. Обновить этот файл (`ai_tools/rules.md`)
2. Обновить соответствующий skill в `.opencode/skills/`
3. Сообщить разработчику о изменениях
