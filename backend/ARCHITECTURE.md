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
- **Services** — бизнес-логика, MILP-оптимизация, диалоговый движок
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
│   ├── app.service.ts          # AppService (stub)
│   │
│   ├── common/
│   │   ├── database/           # DatabaseModule (global), DatabaseService (pg.Pool)
│   │   ├── dto/                # PaginationQueryDto, PaginatedResponseDto
│   │   └── repositories/       # Интерфейсы + Symbol-токены для DI
│   │
│   ├── entities/               # Доменные интерфейсы (Exercise, User, WorkoutDialog...)
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
│   ├── users/                  # Профиль пользователя (включая gender)
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
│   ├── equipment-presets/      # Пресеты оборудования (системные + пользовательские)
│   │   ├── equipment-presets.module.ts
│   │   ├── equipment-presets.controller.ts  # GET system, CRUD user presets, clone
│   │   ├── equipment-presets.service.ts
│   │   ├── equipment-presets-sql.repository.ts
│   │   └── dto/
│   │
│   ├── workout-templates/      # Шаблоны тренировок + расписание
│   │   ├── workout-templates.module.ts
│   │   ├── workout-templates.controller.ts
│   │   ├── workout-templates.service.ts
│   │   ├── workout-templates-sql.repository.ts
│   │   └── dto/
│   │
│   ├── training-blocks/        # Недельные блоки периодизации
│   │   ├── training-blocks.module.ts
│   │   ├── training-blocks-sql.repository.ts
│   │   └── ...
│   │
│   ├── workout-sessions/       # Тренировочные сессии внутри блоков
│   │   ├── workout-sessions.module.ts
│   │   ├── workout-sessions.controller.ts  # CRUD + POST /:id/complete, POST /:id/skip
│   │   ├── workout-sessions.service.ts     # complete(), skip(), reschedule()
│   │   ├── workout-sessions-sql.repository.ts
│   │   ├── set-planner.service.ts          # Per-set planned weight prediction
│   │   ├── cron/auto-skip.cron.ts          # Auto-skip stale planned sessions
│   │   └── dto/
│   │
│   ├── workout-milp/           # MILP-оптимизация тренировок
│   │   ├── workout-milp.module.ts
│   │   ├── workout-milp.controller.ts    # POST /generate, POST /metrics, POST /weekly-plan
│   │   ├── workout-milp.service.ts        # LP solver, веса, fallback, weekly volume, metrics
│   │   ├── weekly-process-milp.service.ts # Сплиты, распределение объёма, день недели
│   │   └── dto/
│   │
│   └── workout-dialog/         # Диалоговый сбор параметров
│       ├── workout-dialog.module.ts
│       ├── workout-dialog.controller.ts   # POST /start, POST /:id/answer, GET /:id
│       ├── workout-dialog.service.ts      # Step engine, skip logic, Russian texts
│       ├── workout-dialogs-sql.repository.ts
│       └── dto/
│
│   └── home/                    # Главная страница мобильного приложения
│       ├── home.module.ts
│       ├── home.controller.ts   # GET /home/data
│       ├── home-data.service.ts
│       └── dto/
│
├── .env                        # Переменные окружения (gitignored)
├── .env.example                # Шаблон .env
└── sql/schema.sql              # Полная схема БД
```

## Key Patterns

1. **Symbol-based DI** — каждый репозиторий зарегистрирован через `Symbol('...')` токен
2. **Raw SQL (no ORM)** — все запросы через параметризованный SQL в `DatabaseService`
3. **Slug References** — упражнения хранят ссылки на мышцы/части тела/оборудование как slug-строки
4. **Device Auth** — аутентификация по `deviceId`, JWT на 30 дней
5. **MILP Optimization** — `javascript-lp-solver` для выбора упражнений, жадный fallback при неудаче
6. **Session-aware scoring** — веса упражнений зависят от типа сессии (push/pull/legs/upper/lower/full_body)
7. **Gender-aware selection** — мягкие бонусы (×1.2–×1.3) в зависимости от пола
8. **Weekly volume tracking** — отслеживание накопленного объёма по мышцам за неделю
9. **Variable sets** — compound упражнения получают больше подходов чем isolation
10. **Dialog state machine** — пошаговый сбор параметров с skip-логикой
11. **Self-providing repos** — `WorkoutMilpModule`, `WorkoutDialogModule`, `EquipmentPresetsModule` не импортируют чужие модули, а самостоятельно регистрируют чужие `*SqlRepository` классы как свои провайдеры
12. **Metrics endpoint** — `POST /workout-milp/metrics` вычисляет метрики (тоннаж, калории, fatigue index) для произвольного набора упражнений
13. **Set Planner** — `SetPlannerService` generates per-set planned data (warmup + working weights) based on exercise history, e1RM estimation, RPE-based progression
14. **Auto-skip cron** — `@nestjs/schedule` cron job at midnight auto-skips stale planned sessions
15. **Self-providing repos** (extended) — `WorkoutSessionsModule` now also self-provides `ExercisesSqlRepository` and `UsersSqlRepository` for SetPlanner

## Module Dependencies

```
AppModule
├── DatabaseModule (global) — pg.Pool
├── AuthModule (imports UsersModule, PassportModule, JwtModule)
├── UsersModule
├── ExercisesModule (imports AuthModule, MusclesModule, BodypartsModule, EquipmentsModule)
├── BodypartsModule
├── EquipmentsModule
├── MusclesModule
├── ContraindicationsModule
├── EquipmentPresetsModule (самопробрасывает EquipmentsSqlRepository)
├── WorkoutTemplatesModule
├── TrainingBlocksModule
├── WorkoutSessionsModule (самопробрасывает ExercisesSqlRepository + UsersSqlRepository для SetPlanner, ScheduleModule.forRoot)
├── WorkoutMilpModule (самопробрасывает 6 чужих SqlRepository)
├── WorkoutDialogModule (самопробрасывает 3 чужих SqlRepository)
├── HomeModule (самопробрасывает TrainingBlocksSqlRepository + WorkoutSessionsSqlRepository)
```

## Config

Переменные окружения загружаются через `dotenv` из `.env`:

| Переменная | Описание | По умолчанию |
|---|---|---|
| `DATABASE_URL` | Connection string PostgreSQL | — |
| `PORT` | Порт сервера | `3001` |
| `JWT_SECRET` | Секрет для JWT-токенов | hardcoded fallback |
| `APP_URL` | Базовый URL для генерации gifUrl | `http://localhost:3001` |

Swagger: `/api/docs`
