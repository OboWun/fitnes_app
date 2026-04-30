# Architecture

## Overview

Flutter-клиент фитнес-приложения. Feature-first архитектура с Riverpod 3.0 для стейт-менеджмента и DI. Кодогенерация (freezed + retrofit) для моделей и API-клиента.

## Layers

```
UI (Widgets/Pages)
    ↓
Features (scoped providers)
    ↓
Repositories (абстракция над data sources)
    ↓
Data Sources (Retrofit API client, local cache)
```

- **UI** — виджеты, страницы, роутинг (auto_router). Не содержит бизнес-логики
- **Features** — Riverpod-провайдеры со scoped состоянием на роут, бизнес-логика
- **Repositories** — интерфейсы (`abstract class`), реализуются Retrofit-клиентом
- **Data Sources** — Retrofit-генерированный API-клиент, локальное хранилище (SharedPreferences/Hive)

## Project Structure

```
mobile/lib/
├── main.dart                          # runApp, ProviderScope, MaterialApp.router
├── app_router.dart                    # AutoRouter конфигурация, guards
│
├── core/
│   ├── network/
│   │   ├── dio_client.dart            # Dio instance (baseURL, interceptors, JWT)
│   │   └── api_interceptor.dart       # Добавляет accessToken к запросам
│   ├── storage/
│   │   └── auth_storage.dart          # Сохранение/чтение JWT + deviceId
│   ├── errors/
│   │   └── failures.dart              # Failure классы (freezed)
│   └── constants/
│       └── app_constants.dart         # URLs, таймауты и т.д.
│
├── design_system/                     # ✅ Уже создано
│   ├── app_colors.dart
│   ├── app_typography.dart
│   ├── app_shadows.dart
│   ├── app_theme.dart
│   └── design_system.dart
│
├── shared/
│   └── widgets/
│       ├── app_bar_custom.dart
│       ├── loading_indicator.dart
│       ├── error_widget.dart
│       └── ...
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_api.dart          # Retrofit @POST('/auth/device')
│   │   │   └── auth_repository.dart   # Impl: login/register, token management
│   │   ├── domain/
│   │   │   └── auth_state.dart        # Freezed классы (AuthState, UserModel)
│   │   ├── presentation/
│   │   │   └── auth_page.dart
│   │   └── auth_provider.dart         # Riverpod NotifierProvider<AuthNotifier>
│   │
│   ├── exercises/
│   │   ├── data/
│   │   │   ├── exercises_api.dart     # Retrofit @GET('/exercises')
│   │   │   └── exercises_repository.dart
│   │   ├── domain/
│   │   │   ├── exercise_model.dart    # Freezed модель упражнения
│   │   │   └── filters.dart           # Freezed классы фильтров
│   │   ├── presentation/
│   │   │   ├── exercises_page.dart
│   │   │   ├── exercise_detail_page.dart
│   │   │   └── widgets/
│   │   └── exercises_provider.dart    # AsyncNotifierProvider + пагинация
│   │
│   ├── profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── dictionaries/                  # Bodyparts, Muscles, Equipments, Contraindications
│       ├── data/
│       │   └── dictionaries_api.dart  # Все GET /dictionary эндпоинты
│       └── dictionaries_provider.dart
│
└── l10n/                              # Локализация (при необходимости)
```

## Key Patterns

1. **Riverpod 3.0 Notifiers** — каждый feature экспортирует `*Provider.dart` с `Notifier` или `AsyncNotifier`. UI подписывается через `ref.watch()`
2. **Freezed модели** — все data-классы иммутабельные через `@freezed`. JSON-сериализация через `json_serializable`
3. **Retrofit API** — типизированный REST-клиент генерируется из интерфейса. Один `Dio`-инстанс через Riverpod provider
4. **Auto Router** — декларативный роутинг с nested-роутами, guards для auth, deep-link поддержка
5. **Feature isolation** — каждый feature-модуль самодостаточен: data/domain/presentation в своей папке

## Module Dependencies

```
main.dart
├── AppRouter (AutoRouter)
│   ├── AuthGuard → проверяет JWT
│   ├── AuthPage
│   ├── ExercisesPage → ExercisesProvider → ExercisesRepository → ExercisesApi
│   ├── ExerciseDetailPage → ExerciseDetailProvider
│   ├── ProfilePage → ProfileProvider → UsersRepository → UsersApi
│   └── DictionariesProvider (глобальный, кэшированный)
│
├── Core Providers (глобальные)
│   ├── dioProvider → Dio с interceptor
│   ├── authStorageProvider → SharedPreferences wrapper
│   └── dictionariesProvider → AsyncNotifier (lazy, кэш в памяти)
│
└── DesignSystem (тема, цвета, типографика)
```

## API Integration

Backend: NestJS REST API. Базовый URL через env/config.

| Endpoint | Mobile Provider | Freezed Model |
|---|---|---|
| `POST /auth/device` | `authProvider` | `AuthResponse` |
| `GET /users/profile` | `profileProvider` | `UserModel` |
| `PATCH /users/profile` | `profileProvider` | `UserModel` |
| `GET /exercises` | `exercisesProvider` | `ExerciseModel`, `PaginatedResponse` |
| `GET /exercises/:slug/similar` | `exerciseDetailProvider` | `List<ExerciseModel>` |
| `GET /exercises/:slug/antagonist` | `exerciseDetailProvider` | `List<ExerciseModel>` |
| `GET /bodyparts` | `dictionariesProvider` | `DictionaryItem` |
| `GET /equipments` | `dictionariesProvider` | `DictionaryItem` |
| `GET /muscles` | `dictionariesProvider` | `MuscleModel` |
| `GET /contraindications` | `dictionariesProvider` | `DictionaryItem` |

## State Management Flow

```
UI (ref.watch(provider))
  → Notifier (business logic)
    → Repository (abstract)
      → Retrofit API (network) / LocalStorage (cache)
  ← Freezed state (immutable)
  ← UI rebuilds
```
