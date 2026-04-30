# Architecture

## Overview

NestJS REST API с **Repository Pattern** и JSON-файловым хранилищем. Чистое разделение на слои через DI-токены (Symbol).

## Layers

```
Controller  ->  Service  ->  Repository Interface  <-  JSON Repository (impl)
   (HTTP)       (Logic)       (common/repositories/)     (*-json.repository.ts)
```

- **Controllers** — HTTP, валидация, Swagger-декораторы
- **Services** — бизнес-логика, маппинг slug -> полные объекты
- **Repository Interfaces** — абстракция доступа к данным (`Symbol`-токены)
- **JSON Repositories** — конкретные реализации, читают `data/*.json`
- **Entities** — TypeScript-интерфейсы доменных моделей
- **DTOs** — валидация запросов (class-validator) и контракт ответов (Swagger)

## Project Structure

```
backend/src/
├── main.ts                          # Bootstrap, Swagger (/api/docs), ValidationPipe
├── app.module.ts                    # Root module, imports all feature modules
├── app.controller.ts                # GET / — health check
├── app.service.ts
│
├── auth/                            # Аутентификация (JWT + deviceId)
│   ├── auth.module.ts
│   ├── auth.controller.ts           # POST /auth/device
│   ├── auth.service.ts
│   ├── guards/jwt-auth.guard.ts
│   ├── strategies/jwt.strategy.ts
│   ├── decorators/current-user.decorator.ts
│   └── dto/
│
├── users/                           # Профиль пользователя
│   ├── users.module.ts
│   ├── users.controller.ts          # GET/PATCH /users/profile (JWT protected)
│   ├── users.service.ts
│   ├── users-json.repository.ts     # Единственный repo с записью на диск
│   └── dto/
│
├── exercises/                       # Упражнения (фильтрация, пагинация, similar, antagonist)
│   ├── exercises.module.ts
│   ├── exercises.controller.ts      # GET /exercises, /:slug/similar, /:slug/antagonist
│   ├── exercises.service.ts
│   ├── exercises-json.repository.ts
│   └── dto/
│
├── bodyparts/                       # Части тела
├── equipments/                      # Оборудование
├── muscles/                         # Мышцы (+ антагонисты)
├── contraindications/               # Противопоказания
│
├── entities/                        # Доменные интерфейсы (Exercise, User, Muscle...)
│   └── index.ts
│
└── common/
    ├── dto/                         # PaginationQueryDto, PaginatedResponseDto
    └── repositories/                # Интерфейсы + Symbol-токены для DI
```

## Key Patterns

1. **Symbol-based DI** — каждый репозиторий зарегистрирован через `Symbol('...')` токен, что позволяет заменить JSON-реализацию на БД без изменения сервисов
2. **Slug References** — упражнения хранят ссылки на мышцы/части тела/оборудование как slug-строки; `ExercisesService.toResponseDto()` резолвит их в полные объекты
3. **Device Auth** — без логина/пароля; пользователь аутентифицируется по `deviceId`, получает JWT (30 дней)
4. **JSON Storage** — все данные в `data/*.json`; только `UsersJsonRepository` пишет на диск

## Module Dependencies

```
AppModule
├── AuthModule (imports UsersModule, PassportModule, JwtModule)
├── UsersModule
├── ExercisesModule (imports MusclesModule, BodypartsModule, EquipmentsModule)
├── BodypartsModule
├── EquipmentsModule
├── MusclesModule
└── ContraindicationsModule
```

## Config

- **Port**: `process.env.PORT` или `3000`
- **JWT Secret**: `process.env.JWT_SECRET`
- **Swagger**: `/api/docs`
