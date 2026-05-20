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
│   ├── training-plans/         # Training Plans (replaced TrainingBlocks)
│   │   ├── training-plans.module.ts
│   │   ├── training-plans.controller.ts   # CRUD + activate + archive + assign/unassign + replace
│   │   ├── training-plans.service.ts      # activate(), archive(), assignTemplate(), replaceWorkout()
│   │   ├── training-plans-sql.repository.ts
│   │   └── dto/
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
│   ├── chat/                    # Unified chat (AI trainer + workout creation)
│   │   ├── chat.module.ts
│   │   ├── chat.controller.ts              # 6 endpoints (sessions, messages, mode switch)
│   │   ├── chat.service.ts                 # Routing by mode (chat → MockLLM, workout → DialogService)
│   │   ├── chat-sessions-sql.repository.ts
│   │   ├── chat-messages-sql.repository.ts
│   │   ├── llm/
│   │   │   ├── llm-provider.interface.ts   # ILLMProvider + LLM_PROVIDER Symbol
│   │   │   └── mock-llm.provider.ts        # Keyword-matching MockLLM
│   │   ├── knowledge/
│   │   │   └── fitness-knowledge.ts        # ~22 fitness articles for MockLLM
│   │   └── dto/
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
7. **Gender-aware selection** — мягкие бонусы (×1.2–×1.7) в зависимости от пола и цели
8. **Weekly volume tracking** — отслеживание накопленного объёма по мышцам за неделю
9. **Variable sets** — compound упражнения получают больше подходов чем isolation
10. **Dialog state machine** — 16-шаговый сбор параметров с conditional routing и advanced settings gate
11. **Self-providing repos** — `WorkoutMilpModule`, `WorkoutDialogModule`, `EquipmentPresetsModule`, `HomeModule` не импортируют чужие модули, а самостоятельно регистрируют чужие `*SqlRepository` классы как свои провайдеры
12. **Metrics endpoint** — `POST /workout-milp/metrics` вычисляет метрики (тоннаж, калории, fatigue index) для произвольного набора упражнений
13. **Set Planner** — `SetPlannerService` generates per-set planned data (warmup + working weights) based on exercise history, e1RM estimation, RPE-based progression, BMI-based defaults
14. **Auto-skip cron** — `@nestjs/schedule` cron job at midnight auto-skips stale planned sessions
15. **Training Plan system** — TrainingPlan → TrainingPlanSession → WorkoutSession hierarchy with activate/archive lifecycle
16. **9 training goals** — strength, hypertrophy, endurance, weight_loss, general_health, rehab, mobility, glute_growth, recomposition
17. **Age & BMI personalization** — AGE_VOLUME_SCALE, AGE_REST_MODIFIER, BMI-based exercise scoring and default weights
18. **Chat + Workout in one UI** — unified chat with two modes (chat/workout), ILLMProvider interface for LLM swap
19. **Template-first MILP** — weekly MILP creates WorkoutTemplates + schedule, not WorkoutSessions; activate creates sessions from templates
20. **Active plan editing** — update() works for active plans; schedule changes recreate planned sessions

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
├── TrainingPlansModule (replaced TrainingBlocksModule)
├── WorkoutSessionsModule (самопробрасывает ExercisesSqlRepository + UsersSqlRepository для SetPlanner, ScheduleModule.forRoot)
├── WorkoutMilpModule (самопробрасывает 6 чужих SqlRepository)
├── WorkoutDialogModule (самопробрасывает 4 чужих SqlRepository, exports WorkoutDialogService)
├── ChatModule (imports WorkoutDialogModule, самопробрасывает UsersSqlRepository)
├── HomeModule (самопробрасывает TrainingPlansRepository + WorkoutSessionsRepository)
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
