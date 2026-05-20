# Fitness App — Backend

REST API для мобильного приложения по созданию персонализированных тренировок.

## Назначение

Серверная часть фитнес-приложения, которое позволяет пользователю:
- Просматривать каталог упражнений с фильтрацией по мышцам, оборудованию и противопоказаниям
- Находить похожие и антагонистические упражнения
- Управлять профилем (вес, рост, возраст, пол, противопоказания)
- Создавать шаблоны тренировок и расписание
- Генерировать одну тренировку (MILP-оптимизация с учётом цели, опыта, пола)
- Генерировать план на неделю с автоподбором сплита (Full Body / Upper-Lower / PPL)
- Управлять тренировочными планами (TrainingPlan): активация, архивация, расписание, замена тренировок
- Через диалоговую систему пошагово собрать параметры для генерации тренировки
- Общаться с AI-тренером в чате: вопросы о похудении, наборе массы, питании, технике, восстановлении
- Создавать тренировки прямо из чата (режим workout)
- Аутентифицироваться по устройству (без логина/пароля)

## Стек

| Технология | Версия | Назначение |
|---|---|---|
| NestJS | 11 | Фреймворк |
| TypeScript | 5 | Язык |
| PostgreSQL | 18 | База данных |
| pg (node-postgres) | 8 | Драйвер PostgreSQL (raw SQL, без ORM) |
| Passport + JWT | — | Аутентификация |
| class-validator | — | Валидация |
| Swagger (OpenAPI) | — | Документация API |
| Jest | 30 | Тестирование |

## Хранилище данных

PostgreSQL. Схема — в `sql/schema.sql`, миграции — в `sql/migrations/`, сидинг из JSON — `sql/seed.ts`. Репозитории абстрагированы через интерфейсы (`Symbol`-токены DI).

**Миграции** (выполнять после schema.sql):
```bash
psql -U postgres -d fitness_app -f sql/migrations/training_plans.sql
psql -U postgres -d fitness_app -f sql/migrations/chat.sql
```

## Запуск

```bash
npm install

# Настроить .env (см. .env.example)
cp .env.example .env

# Создать БД и применить схему
psql -U postgres -c "CREATE DATABASE fitness_app;"
psql -U postgres -d fitness_app -f sql/schema.sql
psql -U postgres -d fitness_app -c "CREATE EXTENSION IF NOT EXISTS pg_trgm; CREATE INDEX idx_exercises_name ON exercises USING gin (name gin_trgm_ops);"

# Заполнить данными (из JSON)
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/fitness_app npx tsx sql/seed.ts

# Запуск
npm run start:dev    # development (watch mode)
npm run start:prod   # production
```

Swagger-документация: `http://localhost:3001/api/docs`

## Переменные окружения

| Переменная | Описание | По умолчанию |
|---|---|---|
| `DATABASE_URL` | Connection string PostgreSQL | — |
| `PORT` | Порт сервера | `3001` |
| `JWT_SECRET` | Секрет для JWT-токенов | hardcoded fallback |
| `APP_URL` | Базовый URL для генерации gifUrl | `http://localhost:3001` |

## Скрипты

| Команда | Описание |
|---|---|
| `npm run build` | Сборка |
| `npm run start:dev` | Dev-режим с hot-reload |
| `npm run start:prod` | Production-режим |
| `npm run test` | Unit-тесты |
| `npm run test:e2e` | E2E-тесты |
| `npm run lint` | Линтинг + автофикс |

## Документация проекта

- [ARCHITECTURE.md](./ARCHITECTURE.md) — архитектура и структура
- [API.md](./API.md) — справочник эндпоинтов
- [DATA-MODEL.md](./DATA-MODEL.md) — модель данных
- [DATA_FLOW.md](./DATA_FLOW.md) — потоки данных Backend ↔ PostgreSQL
- [MILP.md](./MILP.md) — математическая постановка MILP-моделей
- [MILP-COMMON.md](./MILP-COMMON.md) — контракты входов/выходов MILP, priors, split selection
- [CONTEXT.md](./CONTEXT.md) — текущее состояние реализации MILP
- [TRAIN_SPEC.md](./TRAIN_SPEC.md) — спецификация тренировочной науки (цель→повторения, пол, объём)
