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

## Правило 11. Навигация — context.push()

**Приоритет:** `context.push()` > `context.go()`

`context.push()` добавляет маршрут в стек, позволяя пользователю вернуться назад системной кнопкой. `context.go()` заменяет стек — пользователь теряет возможность навигации назад.

### Когда использовать push:
- Переход на вложенную страницу (деталка, профиль, настройки)
- Любой переход, откуда пользователь ожидает вернуться назад

### Когда можно использовать go:
- После успешного логина → замена стека на главный экран
- После завершения onboarding → замена стека на home
- Сброс навигации (logout → auth)

```dart
// ✅ Правильно
context.push('/exercises');
context.push('/profile');

// ❌ Неправильно
context.go('/exercises');
context.go('/profile');
```

---

## Правило 12. Мок-данные — только в API-слое

Все mock-данные находятся **только в `_api.dart`** (в методах API-класса).
Provider'ы и Repository **никогда** не содержат mock-логику.

### Иерархия:
1. `_api.dart` — mock-ответы (до подключения реального бэкенда)
2. `_repository.dart` — бизнес-логика, маппинг, error handling (без mock)
3. `*_provider.dart` — state management (без mock)

```dart
// ✅ Правильно — mock в API
class ProfileApi {
  final Dio _dio;

  Future<List<Map<String, dynamic>>> getWeightHistory(String period) async {
    // TODO: подключить реальный endpoint
    return _mockWeightHistory(period);
  }

  List<Map<String, dynamic>> _mockWeightHistory(String period) {
    return [
      {'date': '2026-05-17', 'weight': 75.0},
      {'date': '2026-05-16', 'weight': 75.5},
    ];
  }
}

// ❌ Неправильно — mock в provider
@riverpod
Future<List<WeightRecord>> weightHistory(Ref ref) async {
  return [WeightRecord(date: DateTime.now(), weight: 75)]; // ЗАПРЕЩЕНО
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

## Готовые виджеты design_system

### GradientFlexibleSpace

Файл: `design_system/widgets/gradient_flexible_space.dart`

Переиспользуемый виджет для `SliverAppBar.flexibleSpace`. Обеспечивает единообразный паттерн: gradient-фон с анимированным переключением между раскрытым (expanded) и свёрнутым (collapsed) состояниями.

**Используется в:** OnboardingPage, ProfilePage, EquipmentDetailPage, PresetDetailPage.

```dart
GradientFlexibleSpace(
  expandedHeight: expandedHeight,
  expandedChild: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.person, size: 48, color: AppColors.whiteColor),
        ),
        const SizedBox(height: 12),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(name, style: AppTypography.h3Bold.copyWith(color: AppColors.whiteColor)),
        ),
      ],
    ),
  ),
  collapsedChild: Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person_outline, size: 24, color: AppColors.whiteColor),
        const SizedBox(width: 8),
        Text(name, style: AppTypography.mediumTextSemiBold.copyWith(color: AppColors.whiteColor)),
      ],
    ),
  ),
)
```

**Параметры:**

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `expandedHeight` | `double` | — (required) | Высота раскрытого appBar |
| `expandedChild` | `Widget` | — (required) | Контент при раскрытии |
| `collapsedChild` | `Widget` | — (required) | Контент при схлопывании |
| `collapsedHeight` | `double` | `60` | Высота свёрнутого appBar |
| `gradient` | `LinearGradient` | `AppGradients.blueLinear` | Градиент фона |
| `borderRadius` | `BorderRadius?` | `bottom: 32` | Скругление контейнера |
| `collapseThreshold` | `double` | `0.6` | Порог переключения (0..1) |

**Правило:** Для новых страниц с SliverAppBar + gradient-фоном **всегда** использовать `GradientFlexibleSpace` вместо ручного LayoutBuilder + Opacity/Stack.

---

## Правило 13. Списки и пагинация

### Для пагинированных списков (данные подгружаются страницами с бэкенда):
- Использовать `infinite_scroll_pagination` (Flutter Favorite)
- `PagingController` живёт на странице (не в riverpod provider)
- Provider предоставляет данные по запрошенной странице
- `addAutomaticKeepAlives: false` на `PagedListView` / `PagedSliverList`

### Для обычных списков (все данные уже в памяти):
- `ListView.builder` / `ListView.separated` с `addAutomaticKeepAlives: false`
- `shrinkWrap: true` — только если список вложен в другой ScrollView и известно что элементов мало

### Запрещено:
- `Column` + `SingleChildScrollView` + `ListView.builder(shrinkWrap: true, NeverScrollableScrollPhysics)` — для списков с пагинацией или потенциально большим количеством элементов
- Ручной `ScrollController.addListener` для детекции конца списка при наличии `infinite_scroll_pagination`

### Разрешено:
- `Column` + `Expanded(child: ListView / PagedListView)` — для фиксированной шапки над списком
- `CustomScrollView` + slivers — для сложных страниц

### Пример пагинированного списка:

```dart
class ExercisesPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends ConsumerState<ExercisesPage> {
  late final _pagingController = PagingController<int, ExerciseShort>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => _fetchPage(pageKey),
  );

  Future<List<ExerciseShort>> _fetchPage(int pageKey) async {
    final repo = ref.read(exerciseRepositoryProvider);
    final result = await repo.getExercises(page: pageKey, limit: 20, ...);
    return result.data;
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => PagedListView<int, ExerciseShort>(
          state: state,
          fetchNextPage: fetchNextPage,
          addAutomaticKeepAlives: false,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) => ExerciseListItem(
              exercise: item,
              onTap: () => context.push('/exercises/${item.slug}'),
            ),
            firstPageProgressIndicatorBuilder: () => _LoadingList(),
            newPageProgressIndicatorBuilder: () => _LoadingItem(),
          ),
        ),
      ),
    );
  }
}
```

---

## Обновление правил

Правила могут появляться и изменяться в процессе разработки. При каждом изменении:
1. Обновить этот файл (`ai_tools/rules.md`)
2. Обновить соответствующий skill в `.opencode/skills/`
3. Сообщить разработчику о изменениях
