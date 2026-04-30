# Fitness App — Mobile

## Зачем

Мобильный клиент для фитнес-приложения. Позволяет пользователю:
- Находить упражнения с фильтрацией по мышцам, оборудованию, частям тела
- Исключать упражнения по противопоказаниям (с учётом severity)
- Находить похожие упражнения и упражнения на мышцы-антагонисты
- Вести профиль (вес, рост, возраст, противопоказания)

Аутентификация — по `deviceId` (без логина/пароля), JWT на 30 дней.

## Tech Stack

| Категория | Пакет | Назначение |
|---|---|---|
| State + DI | `flutter_riverpod` ^3.0 | Провайдеры, Notifier, AsyncNotifier, scoped state |
| Routing | `auto_route` ^10 | Декларативный роутинг, nested routes, guards, deep links |
| Models | `freezed` + `json_serializable` | Иммутабельные data-классы, копирование, JSON |
| API Client | `retrofit` + `dio` | Типизированный REST-клиент из интерфейса |
| Navigation | `auto_route` | Типобезопасный роутинг с codegen |
| Storage | `shared_preferences` | JWT, deviceId, локальный кэш |
| UI | `flutter` Material 3 | Design system из Figma tokens (Poppins, gradients, shadows) |
| Linting | `flutter_lints` ^5.0 | Статический анализ |
| Env | `flutter_dotenv` | Конфигурация среды (API URL) |

### Code Generation

После изменения `*.freezed.dart`, `*.g.dart`, `*.gr.dart` файлов:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Для watch-режима:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Запуск

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Backend API

REST API на NestJS. Полная документация: `../backend/API.md` и Swagger `/api/docs`.

## Документация

- `ARCHITECTURE.md` — архитектура, структура папок, паттерны, взаимодействия модулей
- `../backend/API.md` — REST API референс
- `../backend/DATA-MODEL.md` — модели данных и связи
- `../backend/ARCHITECTURE.md` — архитектура бэкенда
