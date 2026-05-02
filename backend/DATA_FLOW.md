# DATA FLOW: Backend ↔ PostgreSQL

## Общая архитектура

```
┌──────────────────────────────────────────────────────────────┐
│                        NestJS Backend                        │
│                                                              │
│  ┌──────────┐   ┌───────────────┐   ┌─────────────────────┐ │
│  │Controller│──▶│    Service     │──▶│  SQL Repository     │ │
│  │  (HTTP)  │   │ (business logic)│   │ (*-sql.repository)  │ │
│  └──────────┘   └───────────────┘   └──────────┬──────────┘ │
│                                                  │            │
│                                        ┌─────────▼─────────┐ │
│                                        │  DatabaseService   │ │
│                                        │   (pg.Pool query)  │ │
│                                        └─────────┬─────────┘ │
└──────────────────────────────────────────────────┼───────────┘
                                                   │ TCP/SQL
                                         ┌─────────▼─────────┐
                                         │    PostgreSQL      │
                                         │   (tables, funcs)  │
                                         └───────────────────┘
```

---

## Слой подключения: DatabaseModule / DatabaseService

### DatabaseModule
- Глобальный NestJS-модуль (`@Global()`)
- Провайдит `DatabaseService` как singleton
- Читает конфиг из переменных окружения (`DATABASE_URL`)

### DatabaseService
- Держит `pg.Pool` (connection pool)
- Экспортирует методы:
  - `query<T>(sql: string, params?: unknown[]): Promise<T[]>` — выполнение SQL
  - `transaction<T>(fn: (client: pg.PoolClient) => Promise<T>): Promise<T>` — выполнение в транзакции

---

## Потоки данных по модулям

### 1. Справочники (Read-Only из БД)

#### Bodyparts / Equipments / Contraindications / Muscles

```
Client ──GET /muscles──▶ MusclesController
                              │
                         MusclesService
                              │
                    MusclesSqlRepository
                              │
                    ──SELECT * FROM muscles──▶ PostgreSQL
                              │
                    ◀── Muscle[] ──────────────
```

SQL-запрос (пример для muscles):
```sql
SELECT id, name, slug FROM muscles ORDER BY name;
```

#### Muscles: поиск антагонистов

```sql
SELECT m.name, m.slug
FROM muscles m
JOIN muscle_antagonists ma ON m.id = ma.antagonist_id
WHERE ma.muscle_id = (SELECT id FROM muscles WHERE slug = $1);
```

### 2. Упражнения (Read-Only, фильтрация)

#### Пагинированный поиск с фильтрами

SQL (динамически строится в зависимости от фильтров):

```sql
-- Подсчёт общего количества
SELECT COUNT(DISTINCT e.id) AS total
FROM exercises e
WHERE 1=1
  AND EXISTS (
    SELECT 1 FROM exercise_equipments ee
    JOIN equipments eq ON eq.id = ee.equipment_id
    WHERE ee.exercise_id = e.id AND eq.slug = ANY($1::text[])
  )
  AND NOT EXISTS (
    SELECT 1 FROM exercise_contraindications ec
    JOIN contraindications c ON c.id = ec.contraindication_id
    WHERE ec.exercise_id = e.id AND c.slug = ANY($2::text[])
  )
  AND e.name ILIKE '%' || $3 || '%';

-- Получение страницы данных (через SQL-функцию)
SELECT find_exercise_full_by_slug(e.slug)
FROM exercises e
WHERE /* те же фильтры */
ORDER BY e.name
LIMIT $4 OFFSET $5;
```

#### Поиск похожих упражнений

```sql
SELECT e.*, /* + агрегация связей */
FROM exercises e
WHERE e.slug != $1
  AND EXISTS (
    SELECT 1 FROM exercise_target_muscles etm
    WHERE etm.exercise_id = e.id
    AND etm.muscle_id = ANY(
      SELECT etm2.muscle_id FROM exercise_target_muscles etm2
      WHERE etm2.exercise_id = (SELECT id FROM exercises WHERE slug = $1)
    )
  )
ORDER BY e.name
LIMIT $2 OFFSET $3;
```

### 3. Пользователи (Read-Write)

#### Авторизация

```sql
-- findByDeviceId
SELECT id, device_id, name, weight, height, age, created_at
FROM users WHERE device_id = $1;

-- create
INSERT INTO users (id, device_id, created_at)
VALUES ($1, $2, NOW())
RETURNING *;

-- update
UPDATE users SET name = $2, weight = $3, height = $4, age = $5
WHERE id = $1
RETURNING *;
```

#### Обновление противопоказаний (транзакция)

```sql
BEGIN;
  UPDATE users SET name = $2, weight = $3, height = $4, age = $5 WHERE id = $1;
  DELETE FROM user_contraindications WHERE user_id = $1;
  INSERT INTO user_contraindications (user_id, contraindication_id)
    SELECT $1, id FROM contraindications WHERE slug = ANY($6::text[]);
COMMIT;
```

### 4. Workout Templates (Read-Write, транзакции)

#### Создание шаблона

```sql
BEGIN;
  INSERT INTO workout_templates (id, user_id, name, description)
  VALUES ($1, $2, $3, $4);

  INSERT INTO workout_exercises (template_id, exercise_slug, sets, reps, rest_between_sets, rest_after_exercise, sort_order)
  VALUES ($1, $5, $6, $7, $8, $9, $10), ...;
COMMIT;
```

#### Получение расписания

```sql
SELECT sw.*, wt.name AS template_name
FROM scheduled_workouts sw
JOIN workout_templates wt ON wt.id = sw.template_id
WHERE sw.user_id = $1
ORDER BY sw.day_of_week, sw.time;
```

---

## Среда выполнения: переменные окружения

```env
DATABASE_URL=postgresql://user:password@localhost:5432/fitness_app
```

---

## Пул соединений

```
┌─────────────────────────────────┐
│         pg.Pool                 │
│  max: 20 connections            │
│  idleTimeoutMillis: 30000       │
│  connectionTimeoutMillis: 2000  │
│                                 │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐  │
│  │ c1 │ │ c2 │ │ c3 │ │... │  │
│  └────┘ └────┘ └────┘ └────┘  │
└─────────────────────────────────┘
        ▲           ▼
   DatabaseService.query(sql, params)
        ▲           ▼
   *SqlRepository methods
```

- Каждый вызов `query()` берёт соединение из pool и возвращает обратно
- Для транзакций — `pool.connect()` захватывает одно соединение на всю транзакцию

---

## Статические файлы: media

```
Client ──GET /media/trmte8s.gif──▶ NestJS (express.static middleware)
                                       │
                                  ┌────▼─────────────┐
                                  │ backend/media/    │
                                  │   trmte8s.gif     │
                                  │   LMGXZn8.gif     │
                                  │   ... (~1500)     │
                                  └──────────────────┘
```

Конфигурация в `main.ts`:
```typescript
app.use('/media', express.static(path.join(__dirname, '..', 'media')));
```

Поле `gifUrl` в ответе API содержит относительный путь `/media/{exerciseId}.gif`.
