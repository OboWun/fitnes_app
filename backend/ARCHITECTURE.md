# Architecture

## Overview

NestJS REST API с **Repository Pattern** и PostgreSQL. Чистое разделение на слои через DI-токены (Symbol). Доступ к БД — через параметризованные SQL-запросы (без ORM).

## Layers

```
Controller  ->  Service  ->  Repository Interface  <-  SQL Repository (impl)
   (HTTP)       (Logic)       (common/repositories/)     (*-sql.repository.ts)
                                                          │
                                                  DatabaseService (pg.Pool)
                                                          │
                                                     PostgreSQL
```

- **Controllers** — HTTP, валидация, Swagger-декораторы
- **Services** — бизнес-логика, маппинг slug → полные объекты
- **Repository Interfaces** — абстракция доступа к данным (`Symbol`-токены)
- **SQL Repositories** — реализации с параметризованными SQL-запросами через `DatabaseService`
- **DatabaseService** — singleton с `pg.Pool`, методы `query()`, `queryOne()`, `transaction()`
- **Entities** — TypeScript-интерфейсы доменных моделей
- **DTOs** — валидация запросов (class-validator) и контракт ответов (Swagger)

## Project Structure

```
backend/
├── sql/
│   ├── schema.sql              # DDL: таблицы, индексы, SQL-функции
│   └── seed.ts                 # Миграция JSON → PostgreSQL
├── media/                      # GIF-файлы упражнений (~1500), раздаются как static
│
├── src/
│   ├── main.ts                 # Bootstrap, dotenv, express.static, Swagger
│   ├── app.module.ts           # Root module, imports DatabaseModule + все feature modules
│   ├── app.controller.ts       # GET / — health check
│   ├── app.service.ts
│   │
│   ├── common/
│   │   ├── database/           # DatabaseModule (global), DatabaseService (pg.Pool)
│   │   ├── dto/                # PaginationQueryDto, PaginatedResponseDto
│   │   └── repositories/       # Интерфейсы + Symbol-токены для DI
│   │
│   ├── entities/               # Доменные интерфейсы (Exercise, User, Muscle...)
│   │
│   ├── auth/                   # Аутентификация (JWT + deviceId)
│   │   ├── auth.module.ts
│   │   ├── auth.controller.ts  # POST /auth/device
│   │   ├── auth.service.ts
│   │   ├── guards/jwt-auth.guard.ts
│   │   ├── strategies/jwt.strategy.ts
│   │   ├── decorators/current-user.decorator.ts
│   │   └── dto/
│   │
│   ├── users/                  # Профиль пользователя
│   │   ├── users.module.ts
│   │   ├── users.controller.ts # GET/PATCH /users/profile (JWT protected)
│   │   ├── users.service.ts
│   │   ├── users-sql.repository.ts
│   │   └── dto/
│   │
│   ├── exercises/              # Упражнения (фильтрация, пагинация, similar, antagonist)
│   │   ├── exercises.module.ts
│   │   ├── exercises.controller.ts
│   │   ├── exercises.service.ts
│   │   ├── exercises-sql.repository.ts
│   │   └── dto/
│   │
│   ├── bodyparts/              # Части тела
│   ├── equipments/             # Оборудование
│   ├── muscles/                # Мышцы (+ антагонисты)
│   ├── contraindications/      # Противопоказания
│   │
│   └── workout-templates/      # Шаблоны тренировок + расписание
│       ├── workout-templates.module.ts
│       ├── workout-templates.controller.ts
│       ├── workout-templates.service.ts
│       ├── workout-templates-sql.repository.ts
│       └── dto/
│
├── .env                        # Переменные окружения (gitignored)
├── .env.example                # Шаблон .env
└── sql/schema.sql              # Полная схема БД
```

## Key Patterns

1. **Symbol-based DI** — каждый репозиторий зарегистрирован через `Symbol('...')` токен, что позволяет менять реализацию без изменения сервисов
2. **Raw SQL (no ORM)** — все запросы через параметризованный SQL в `DatabaseService`, включая SQL-функции в PostgreSQL (`find_exercise_full_by_slug`)
3. **Slug References** — упражнения хранят ссылки на мышцы/части тела/оборудование как slug-строки; `ExercisesService.toResponseDto()` резолвит их в полные объекты из кэша
4. **Device Auth** — без логина/пароля; пользователь аутентифицируется по `deviceId`, получает JWT (30 дней)
5. **Async Repositories** — все методы репозиториев асинхронные (`Promise<T>`), транзакции через `DatabaseService.transaction()`
6. **Static Media** — GIF-файлы раздаются через `express.static('/media')` из папки `media/`

## Module Dependencies

```
AppModule
├── DatabaseModule (global) — pg.Pool
├── AuthModule (imports UsersModule, PassportModule, JwtModule)
├── UsersModule
├── ExercisesModule (imports MusclesModule, BodypartsModule, EquipmentsModule)
├── BodypartsModule
├── EquipmentsModule
├── MusclesModule
├── ContraindicationsModule
└── WorkoutTemplatesModule
```

## Config

Переменные окружения загружаются через `dotenv` из `.env`:

| Переменная | Описание | По умолчанию |
|---|---|---|
| `DATABASE_URL` | Connection string PostgreSQL | — |
| `PORT` | Порт сервера | `3000` |
| `JWT_SECRET` | Секрет для JWT-токенов | hardcoded fallback |
| `APP_URL` | Базовый URL для генерации gifUrl | `http://localhost:3000` |

Swagger: `/api/docs`
