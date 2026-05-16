# Architecture

## Overview

Flutter-клиент фитнес-приложения. Feature-first архитектура с Riverpod 2.x (`riverpod_annotation` + `riverpod_generator`) для стейт-менеджмента и DI. Кодогенерация (`freezed` + `json_serializable`) для моделей. Роутинг — `go_router` с declarative redirect.

## Tech Stack

| Категория | Технология | Версия |
|---|---|---|
| Flutter SDK | Flutter + FVM | ^3.9.2 |
| State management | `flutter_riverpod` + `riverpod_annotation` | ^2.6.1 |
| Code generation (state) | `riverpod_generator` | ^2.6.3 |
| Code generation (models) | `freezed` + `json_serializable` | ^2.5.7 / ^6.9.4 |
| Routing | `go_router` | ^14.8.1 |
| Network | `dio` | ^5.7.0 |
| Local storage | `shared_preferences` | ^2.3.4 |
| Device info | `device_info_plus` | ^11.2.0 |

## UI Rules

Полный референс всех UI-правил: `ai_tools/rules.md`. Skills для opencode: `.opencode/skills/`.

| # | Правило | Суть |
|---|---|---|
| 1 | **InkWell** | Приоритет для tap-обработки. GestureDetector — только свайпы |
| 2 | **ValueNotifier** | Локальное состояние — ValueNotifier + ValueListenableBuilder |
| 3 | **Без buildSomething** | → отдельный `_PrivateWidget` или `part`/`part of` |
| 4 | **Без Padding между** | `Column(spacing:)`, `SizedBox`. Padding — только внутренний |
| 5 | **Widget.loading()** | Union-паттерн: `const factory .loading() = _LoadingWidget` |
| 6 | **API: value + onChanged** | `<T> value`, `ValueChanged<T>? onChanged`, контроллеры optional |
| 7 | **Dumb / Smart** | Dumb: нет riverpod, нет навигации. Smart: обёртка с riverpod |
| 8 | **Riverpod — запросы + глобал** | Не для локального состояния. Retry: max 3, backoff 1-2-3с |
| 9 | **< 250 строк** | Иначе `part`/`part of` или отдельный файл |
| 10 | **WidgetContainer** | Группа виджетов: `List<T>` + `.loading()`, error на уровне страницы |

### Feature-структура

```
features/<feature>/
├── public.dart                          # Экспорт для других фич
├── <feature>_provider.dart              # Riverpod-провайдеры
├── data/
│   ├── <feature>_api.dart               # API-слой (Dio wrapper)
│   └── <feature>_repository.dart        # Репозиторий
├── domain/
│   └── <model>.dart                      # @freezed модели
└── presentation/
    ├── <feature>_page.dart               # Страница (ErrorHandlingMixin)
    ├── widgets/                          # Dumb-виджеты
    └── smart_widgets/                    # Smart-обёртки
```

### Принцип выделения Feature

Feature — ограниченный контекст предметной области с собственной моделью, provider'ом или страницей. Признаки: отдельный эндпоинт, отдельный роут, собственная доменная модель. Smart-виджеты НЕ выносятся в core — они живут внутри своей фичи.

## Layers

```
UI (Widgets/Pages)
    ↓  ref.watch(provider)
Features (@riverpod Notifiers)
    ↓
Repositories (абстракция над API)
    ↓
API Layer (Dio client, typed methods)
    ↓  HTTP
Backend (NestJS REST API, port 3001)
```

- **UI** — виджеты, страницы, роутинг (go_router). Не содержит бизнес-логики. Dumb-виджеты — чистый UI, Smart — обёртки с riverpod
- **Features** — Riverpod-провайдеры (`@riverpod` / `@Riverpod(keepAlive: true)`), Notifier/AsyncNotifier
- **Repositories** — классы с бизнес-логикой (device ID, token management, data transformation)
- **API Layer** — типизированные методы над Dio (auth_api.dart)
- **Core** — инфраструктура: Dio client, interceptors, exceptions, storage, router, mixins, utils

## Project Structure

```
mobile/
├── .opencode/skills/                   # Skills для opencode (5 skill-файлов)
├── ai_tools/
│   └── rules.md                        # Полный референс 10 UI-правил
│
├── lib/
│   ├── main.dart                       # runApp, ProviderScope, MaterialApp.router
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart      # baseUrl (localhost:3001), таймауты, storage keys
│   │   ├── mixins/
│   │   │   └── error_handling_mixin.dart # Toast + reload при AppException
│   │   ├── network/
│   │   │   ├── dio_client.dart         # @Riverpod(keepAlive: true) Dio instance
│   │   │   ├── api_interceptor.dart    # JWT injection + typed exception mapping
│   │   │   └── exceptions.dart         # sealed class AppException → 5 подтипов
│   │   ├── storage/
│   │   │   └── auth_storage.dart       # @Riverpod(keepAlive: true) SharedPreferences wrapper
│   │   ├── router/
│   │   │   └── app_router.dart         # @Riverpod(keepAlive: true) GoRouter, auth redirect
│   │   └── utils/
│   │       └── retry.dart              # withRetry wrapper (max 3, backoff 1-2-3с)
│   │
│   ├── design_system/
│   │   ├── app_colors.dart             # AppColors, AppGradients
│   │   ├── app_typography.dart         # AppTypography (cached getters, Poppins)
│   │   ├── app_shadows.dart            # AppShadows
│   │   ├── app_theme.dart              # AppTheme.light
│   │   ├── design_system.dart          # barrel export (включая widgets/)
│   │   └── widgets/
│   │       ├── shimmer_card.dart       # ShimmerCard — shimmer-заглушка для карточек
│   │       └── shimmer_field.dart      # ShimmerField — shimmer-заглушка для полей ввода
│   │
│   └── features/
│       ├── auth/
│       │   ├── public.dart             # Экспорт: UserModel, AuthState, authProvider, contraindicationsProvider
│       │   ├── auth_provider.dart      # @Riverpod(keepAlive: true) Auth AsyncNotifier
│       │   ├── data/
│       │   │   ├── auth_api.dart       # @riverpod AuthApi — Dio wrapper
│       │   │   └── auth_repository.dart # @riverpod AuthRepository
│       │   └── domain/
│       │       ├── user_model.dart     # @freezed UserModel + UserMetadata
│       │       └── auth_state.dart     # @freezed AuthState + AuthStatus enum
│       │
│       ├── home/
│       │   ├── public.dart             # Экспорт: HomeData, WeekSession, dumb-виджеты
│       │   ├── home_provider.dart      # @Riverpod(keepAlive: true) Home Notifier (mock)
│       │   ├── domain/
│       │   │   ├── home_data.dart      # @freezed HomeData, ActiveBlock, TodaySession
│       │   │   └── week_session.dart   # @freezed WeekSession, DayOfWeek enum
│       │   └── presentation/
│       │       ├── home_page.dart      # Главная страница (ConsumerWidget)
│       │       ├── widgets/            # Dumb: ProfileHeader, WeekCalendar, DayCard, WorkoutReminder, DictionaryGrid, SectionHeader, ViewAllLink (все с .loading())
│       │       └── smart_widgets/      # Smart: ProfileHeaderSmart, WeekCalendarSmart, DictionaryGridSmart, ViewAllLinkSmart
│       │
│       ├── onboarding/
│       │   ├── public.dart             # Экспорт: OnboardingState, onboardingProvider
│       │   ├── domain/
│       │   │   └── onboarding_state.dart # @freezed OnboardingState
│       │   ├── onboarding_provider.dart  # @riverpod Onboarding Notifier
│       │   └── presentation/
│       │       ├── onboarding_page.dart  # PageView, 5 шагов (part-файлы для <250 строк)
│       │       ├── _progress_dots.dart   # part of onboarding_page.dart
│       │       ├── _navigation_buttons.dart # part of onboarding_page.dart
│       │       ├── _gradient_button.dart   # part of onboarding_page.dart
│       │       ├── widgets/              # Dumb: StepName, StepGender, StepAge, StepBodyParams, StepContraindications
│       │       └── smart_widgets/        # Smart: StepNameSmart, StepGenderSmart, StepAgeSmart, StepBodyParamsSmart, StepContraindicationsSmart
│       │
│       ├── splash/
│       │   └── splash_page.dart        # Инициализация auth, loading/error UI
│       │
│       ├── dictionaries/
│       │   └── presentation/
│       │       ├── equipment_page.dart  # Заглушка: Инвентарь
│       │       └── muscles_page.dart    # Заглушка: Мышцы
│       │
│       ├── workouts/
│       │   └── presentation/
│       │       └── workouts_page.dart   # Заглушка: Тренировки
│       │
│       ├── exercises/
│       │   └── presentation/
│       │       └── exercises_page.dart  # Заглушка: Упражнения
│       │
│       └── profile/
│           └── presentation/
│               └── profile_page.dart    # Заглушка: Профиль
```

## Key Patterns

### 1. Code-Generated Providers (`@riverpod`)

Все провайдеры используют аннотации `riverpod_annotation`. Генерация через `build_runner`.

```dart
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() => const AuthState();

  Future<void> initialize() async { ... }
}
```

Глобальные singleton-провайдеры: `@Riverpod(keepAlive: true)` — Dio, AuthStorage, GoRouter, Auth.
Feature-scoped: `@riverpod` — Onboarding, AuthApi, AuthRepository.

### 2. Freezed Models

Все data-классы иммутабельные через `@freezed`. JSON-сериализация через `@Freezed(fromJson: true, toJson: true)` + `json_serializable`.

```dart
@Freezed(fromJson: true, toJson: true)
class UserModel with _$UserModel {
  const UserModel._();
  const factory UserModel({ ... }) = _UserModel;
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  bool get isProfileComplete => ...;
}
```

### 3. GoRouter с Auth Redirect

Роутер реактивно реагирует на изменения `AuthState` через `refreshListenable`:

```dart
redirect: (context, state) {
  // initial/loading → /splash
  // onboarding → /onboarding
  // authenticated → / (home)
  // error → /splash (retry)
}
```

Роуты: `/splash`, `/onboarding`, `/`, `/profile`, `/workouts`, `/exercises`, `/muscles`, `/equipment`.

### 4. Typed Exception Hierarchy

`sealed class AppException` с подтипами:
- `NetworkException` (connection errors, 404)
- `AuthException` (401, 403) — автоматически clear JWT при 401
- `ServerException` (5xx)
- `TimeoutException`
- `UnknownException`

ApiInterceptor маппит `DioException` → `AppException` subtypes.

### 5. Feature Isolation

Каждый feature-модуль самодостаточен: `data/` (API + Repository) → `domain/` (models + state) → `presentation/` (widgets + smart_widgets + pages). Provider файл на уровне feature.

**public.dart** в каждой фиче экспортирует модели и виджеты для использования в других фичах. Кросс-фичные импорты — только через `public.dart`. Smart-виджеты НЕ выносятся в core — живут внутри своей фичи.

### 6. Dumb / Smart Separation

- **Dumb** (`presentation/widgets/`): рисует данные, API = `value` + `onChanged`/`onTap`, имеет `.loading()`, не знает про riverpod, не навигирует
- **Smart** (`presentation/smart_widgets/`): обёртка над dumb, подключает `ref.watch`/`ref.read`, обрабатывает навигацию `context.go()`

### 7. Error Handling

`ErrorHandlingMixin` на уровне страниц (ConsumerStatefulWidget) — ловит `AppException`, показывает SnackBar, предоставляет `runWithErrorHandling()`.

`withRetry()` — универсальный retry-wrapper: max 3 попытки, exponential backoff 1с-2с-3с.

## Module Dependencies

```
main.dart (ProviderScope + MaterialApp.router)
│
├── AppRouter (@Riverpod keepAlive)
│   ├── watches authProvider → redirect logic
│   ├── SplashPage → authProvider.notifier.initialize()
│   ├── OnboardingPage → onboardingProvider
│   └── HomePage → homeProvider + smart_widgets → authProvider (via public.dart)
│
├── Core Providers (@Riverpod keepAlive)
│   ├── dioProvider → Dio + ApiInterceptor
│   ├── authStorageProvider → SharedPreferences (JWT + deviceId)
│   ├── authProvider → Auth AsyncNotifier (state machine)
│   ├── homeProvider → Home Notifier (mock data, future: API)
│   └── appRouterProvider → GoRouter
│
├── Core Infrastructure
│   ├── ErrorHandlingMixin → toast + reload
│   └── retry.dart → withRetry (max 3, backoff 1-2-3с)
│
├── Auth Feature
│   ├── authApiProvider → AuthApi (Dio wrapper)
│   ├── authRepositoryProvider → AuthRepository
│   └── contraindicationsProvider → FutureProvider (GET /contraindications)
│
├── Home Feature
│   ├── homeProvider → Home Notifier (mock → future API)
│   ├── dumb widgets: ProfileHeader, WeekCalendar, DayCard, WorkoutReminder, DictionaryGrid, SectionHeader, ViewAllLink
│   └── smart widgets: ProfileHeaderSmart, WeekCalendarSmart, DictionaryGridSmart, ViewAllLinkSmart
│
├── Onboarding Feature
│   ├── onboardingProvider → Onboarding Notifier
│   ├── dumb widgets: StepName, StepGender, StepAge, StepBodyParams, StepContraindications
│   └── smart widgets: StepNameSmart, StepGenderSmart, StepAgeSmart, StepBodyParamsSmart, StepContraindicationsSmart
│
├── Dictionaries Feature (placeholder)
│   ├── EquipmentPage → /equipment
│   └── MusclesPage → /muscles
│
├── Splash Feature
│   └── SplashPage → authProvider.initialize()
│
└── DesignSystem (pure UI, no dependencies)
    ├── AppColors, AppGradients, AppTypography, AppShadows, AppTheme
    └── ShimmerCard, ShimmerField
```

## Auth Flow

```
App Start
  → SplashPage
    → authProvider.initialize()
      → AuthRepository.getDeviceId() (generate or read from SharedPreferences)
      → AuthApi.authenticateDevice(deviceId) → POST /auth/device
      → Save JWT to SharedPreferences
      → Check isProfileComplete
        → true: AuthStatus.authenticated → GoRouter redirect → HomePage
        → false: AuthStatus.onboarding → GoRouter redirect → OnboardingPage
```

## Onboarding Flow

```
OnboardingPage (5 steps, PageView)
  Step 0: Name (required)
  Step 1: Gender (required, male/female)
  Step 2: Age (optional)
  Step 3: Weight + Height (optional)
  Step 4: Contraindications (optional, loaded from GET /contraindications)
  → On submit: PATCH /users/profile → authProvider.completeOnboarding()
  → GoRouter redirect → HomePage
```

## API Integration

Backend: NestJS REST API на порту 3001.

| Endpoint | Mobile Provider | Freezed Model |
|---|---|---|
| `POST /auth/device` | `authProvider` | `UserModel` |
| `GET /users/profile` | `authRepositoryProvider` | `UserModel` |
| `PATCH /users/profile` | `authProvider.updateProfile()` | `UserModel` |
| `GET /contraindications` | `contraindicationsProvider` | `List<Map>` (raw) |

## Code Generation

Команда для генерации:
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

Генерируемые файлы:
- `*.g.dart` — Riverpod providers, JSON serialization
- `*.freezed.dart` — Freezed models (copyWith, equality, toString)

## Config

| Переменная | Описание | По умолчанию |
|---|---|---|
| `baseUrl` | URL бэкенда | `http://localhost:3001` |
| `connectTimeout` | Таймаут подключения | 15s |
| `receiveTimeout` | Таймаут ответа | 15s |
