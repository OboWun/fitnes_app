# API Reference

Base URL: `http://localhost:3001`
Swagger UI: `/api/docs`

## Auth

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/auth/device` | No | Регистрация/вход по deviceId. Возвращает JWT + профиль |

**Body**: `{ "deviceId": "string" }`
**Response**: `{ "accessToken": "...", "user": { ... } }`

## Users

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/users/profile` | JWT | Текущий профиль |
| PATCH | `/users/profile` | JWT | Обновление профиля |
| GET | `/users/weight-history` | JWT | История изменений веса |

**PATCH Body** (все поля optional):
```json
{
  "name": "string",
  "gender": "male" | "female",
  "weight": 70,
  "height": 175,
  "age": 25,
  "contraindications": ["slug1"],
  "goal": "hypertrophy",
  "experienceLevel": "intermediate",
  "availableEquipment": ["barbell", "dumbbell"]
}
```

Поля `goal`, `experienceLevel`, `availableEquipment`, `defaultEquipmentPresetId` сохраняются в `user.metadata`. Поле `gender` сохраняется в отдельную колонку `users.gender`. При обновлении метаданных существующие поля не затираются (merge). При обновлении `weight` автоматически создаётся запись в `weight_logs`.

### GET /users/weight-history

**Query params**:

| Параметр | Обязателен | Описание |
|---|---|---|
| `period` | Нет | `week` (7 дней), `month` (30 дней), `all` (всё время). По умолчанию — `all` |

**Response**:
```json
[
  { "date": "2026-05-17", "weight": 75.0 },
  { "date": "2026-05-15", "weight": 75.5 }
]
```

**Response** (включает `metadata`):
```json
{
  "id": "l1a2b3c",
  "deviceId": "device-abc123",
  "name": "Иван",
  "gender": "male",
  "weight": 75,
  "height": 180,
  "age": 30,
  "contraindications": [],
  "createdAt": "2026-01-01T00:00:00.000Z",
  "metadata": {
    "goal": "hypertrophy",
    "experienceLevel": "intermediate",
    "availableEquipment": ["barbell", "dumbbell"],
    "defaultEquipmentPresetId": "preset-gym-full"
  }
}
```

## Exercises

Все эндпоинты упражнений требуют JWT.

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/exercises` | JWT | Список с пагинацией, фильтрами и персональной сортировкой |
| GET | `/exercises/:slug` | JWT | Детализация упражнения |
| GET | `/exercises/:slug/similar` | JWT | Похожие упражнения (те же целевые мышцы) |
| GET | `/exercises/:slug/antagonist` | JWT | Упражнения на антагонистические мышцы |

### GET /exercises

**Query params**:

| Параметр | Обязателен | Описание |
|---|---|---|
| `page` | Нет | int, default 1 |
| `limit` | Нет | int, default 20 |
| `search` | Нет | Поиск по имени/slug |
| `contraindications` | Нет | CSV slugs — исключить упражнения с этими противопоказаниями |
| `equipments` | Нет | CSV slugs — фильтр по оборудованию |
| `targetMuscles` | Нет | CSV slugs — фильтр по целевым мышцам |
| `isPersonal` | Нет | boolean — сортировать по доступности пользователю (безопасные первыми, запрещённые последними). Использует противопоказания из профиля |

**Response** (массив коротких DTO):
```json
{
  "data": [
    {
      "slug": "barbell-bench-press",
      "name": "Жим штанги лёжа",
      "imageUrl": "https://localhost:3001/media/abc123.gif",
      "description": "Базовое упражнение для груди",
      "equipments": [
        { "name": "штанга", "slug": "barbell", "description": null, "imageUrl": null }
      ],
      "contraindication": null
    },
    {
      "slug": "dumbbell-fly",
      "name": "Разведение гантелей",
      "imageUrl": "https://localhost:3001/media/def456.gif",
      "description": null,
      "equipments": [
        { "name": "гантель", "slug": "dumbbell", "description": null, "imageUrl": null }
      ],
      "contraindication": "not_recommended"
    }
  ],
  "total": 1250,
  "page": 1,
  "limit": 20,
  "totalPages": 63
}
```

- `contraindication` — самое тяжёлое совпадение противопоказания упражнения с профилем пользователя
- Значения: `null` (безопасно), `low_weight`, `not_recommended`, `forbidden`
- При `isPersonal=true`: безопасные упражнения первыми, `forbidden` — последними
- При `isPersonal=false` или отсутствии `contraindications` в профиле: `contraindication` всегда `null`

### GET /exercises/:slug

Детализация упражнения с персональными противопоказаниями и похожими упражнениями.

**Response**:
```json
{
  "slug": "barbell-bench-press",
  "name": "Жим штанги лёжа",
  "imageUrl": "https://localhost:3001/media/abc123.gif",
  "description": "Базовое упражнение для развития грудных мышц",
  "exerciseType": "strength",
  "difficulty": "intermediate",
  "movementPattern": "push",
  "confidence": 0.86,
  "instructions": ["Лягте на скамью...", "Опустите штангу..."],
  "targetMuscles": [
    { "name": "Грудь", "slug": "chest" }
  ],
  "secondaryMuscles": [
    { "name": "Трицепс", "slug": "triceps" }
  ],
  "bodyParts": [
    { "name": "Грудь", "slug": "chest" }
  ],
  "equipments": [
    { "name": "штанга", "slug": "barbell", "description": null, "imageUrl": null }
  ],
  "variations": ["dumbbell-bench-press"],
  "alias": ["bench press"],
  "userContraindications": [
    { "slug": "herniated_disc", "severity": "not_recommended" }
  ],
  "similarExercises": [
    {
      "slug": "dumbbell-bench-press",
      "name": "Жим гантелей лёжа",
      "imageUrl": "https://localhost:3001/media/xyz.gif",
      "description": null,
      "equipments": [{ "name": "гантель", "slug": "dumbbell", "description": null, "imageUrl": null }],
      "contraindication": null
    }
  ]
}
```

- `userContraindications` — **только** пересечение противопоказаний упражнения с профилем пользователя. `null` если совпадений нет
- `similarExercises` — до 5 похожих упражнений в коротком DTO (с `contraindication` для текущего пользователя)

## Dictionaries

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/bodyparts` | No | Все части тела |
| GET | `/equipments` | No | Всё оборудование |
| GET | `/muscles` | No | Все мышцы (с антагонистами) |
| GET | `/contraindications` | No | Все противопоказания |

### GET /equipments response

```json
[
  {
    "name": "Гантель",
    "slug": "dumbbell",
    "description": "Свободный вес для изолирующих и базовых упражнений",
    "imageUrl": null
  }
]
```

| Поле | Тип | Описание |
|------|-----|----------|
| `name` | string | Название |
| `slug` | string | Идентификатор |
| `description` | string (nullable) | Краткое описание инвентаря |
| `imageUrl` | string (nullable) | Путь к картинке |

## Equipment Presets

Пресеты оборудования — именованные наборы equipment-слагов. Системные пресеты — только чтение, пользовательские — полный CRUD.

### System Presets (только чтение, без авторизации)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/equipment-presets/system` | No | Все системные пресеты |

**Query params**: `includeDetails=true` — добавить `equipmentDetails` (slug + name для каждого оборудования).

**Response**:
```json
[
  {
    "id": "preset-gym-full",
    "name": "Тренажёрный зал (полный)",
    "slug": "gym-full",
    "isSystem": true,
    "equipmentSlugs": ["barbell", "dumbbell", "cable", "..."],
    "equipmentDetails": [
      { "slug": "barbell", "name": "штанга" },
      { "slug": "dumbbell", "name": "гантель" }
    ],
    "createdAt": "...",
    "updatedAt": "..."
  }
]
```

### User Presets (CRUD, JWT обязателен)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/equipment-presets` | JWT | Все пресеты пользователя |
| POST | `/equipment-presets` | JWT | Создать пресет |
| PATCH | `/equipment-presets/:id` | JWT | Обновить пресет |
| DELETE | `/equipment-presets/:id` | JWT | Удалить пресет |
| POST | `/equipment-presets/clone/:sourceId` | JWT | Клонировать пресет (системный или пользовательский) |

**Query params для GET**: `includeDetails=true` — добавить `equipmentDetails`.

**Create Body**:
```json
{
  "name": "Мой зал",
  "slug": "my-gym",
  "equipmentSlugs": ["barbell", "dumbbell", "cable"]
}
```

**Clone Body**:
```json
{
  "name": "Мой зал (кастом)",
  "slug": "my-gym-custom"
}
```

**Update Body** (все поля optional):
```json
{
  "name": "Обновлённый зал",
  "equipmentSlugs": ["barbell", "dumbbell", "cable", "kettlebell"]
}
```

**Системные пресеты** (по умолчанию):

| ID | Название | Описание |
|----|----------|----------|
| `preset-gym-full` | Тренажёрный зал (полный) | Всё оборудование зала (~25 позиций) |
| `preset-gym-basic` | Тренажёрный зал (базовый) | Минимальный набор (штанга, гантели, кабельный тренажёр и т.д.) |
| `preset-home` | Домашняя тренировка | Гантели, гиря, эспандер, фитбол и т.д. |
| `preset-bodyweight` | Только вес тела | Пустой массив `[]` |
| `preset-outdoor` | Уличная площадка | Эспандер, канат, лента |

## Workout Templates

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/workout-templates` | JWT | Все шаблоны пользователя |
| GET | `/workout-templates/:id` | JWT | Шаблон по ID |
| POST | `/workout-templates` | JWT | Создать шаблон |
| PATCH | `/workout-templates/:id` | JWT | Обновить шаблон |
| DELETE | `/workout-templates/:id` | JWT | Удалить шаблон |
| GET | `/workout-templates/schedule/all` | JWT | Расписание пользователя |
| POST | `/workout-templates/schedule` | JWT | Добавить в расписание |
| PATCH | `/workout-templates/schedule/:scheduleId` | JWT | Обновить запись расписания |
| DELETE | `/workout-templates/schedule/:scheduleId` | JWT | Удалить запись расписания |

## Training Blocks

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/training-blocks` | JWT | Все блоки пользователя |
| GET | `/training-blocks/:id` | JWT | Блок по ID |
| POST | `/training-blocks` | JWT | Создать блок |
| PATCH | `/training-blocks/:id` | JWT | Обновить блок |
| DELETE | `/training-blocks/:id` | JWT | Удалить блок |

## Workout Sessions

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/workout-sessions` | JWT | Все сессии пользователя (с фильтрацией) |
| GET | `/workout-sessions/block/:blockId` | JWT | Сессии конкретного блока |
| GET | `/workout-sessions/:id` | JWT | Сессия по ID (с setDetails[]) |
| POST | `/workout-sessions` | JWT | Создать сессию |
| POST | `/workout-sessions/:id/complete` | JWT | Завершить сессию с actual-данными |
| POST | `/workout-sessions/:id/skip` | JWT | Пропустить сессию (с опциональным переносом) |
| PATCH | `/workout-sessions/:id` | JWT | Обновить сессию |
| DELETE | `/workout-sessions/:id` | JWT | Удалить сессию |

**Query params для GET /workout-sessions**:

| Параметр | Обязателен | Описание |
|---|---|---|
| `limit` | Нет | Ограничение количества |
| `status` | Нет | Фильтр по статусу (CSV): `planned`, `completed`, `skipped`, `replaced` |
| `sort` | Нет | `id_desc` (default), `id_asc` |

Примеры:
- `GET /workout-sessions?limit=3&status=completed` — последние 3 завершённые тренировки
- `GET /workout-sessions?status=planned&sort=id_asc` — все запланированные, старые первыми

**GET /workout-sessions/:id Response** включает `setDetails[]` для каждого упражнения:

```json
{
  "id": "session-1",
  "blockId": "block-123",
  "userId": "user-1",
  "dayOfWeek": "monday",
  "status": "planned",
  "exercises": [
    {
      "exerciseSlug": "bench-press",
      "sets": 4,
      "order": 1,
      "setDetails": [
        { "setNumber": 1, "setType": "warmup", "plannedWeightKg": 20, "plannedReps": 15 },
        { "setNumber": 2, "setType": "warmup", "plannedWeightKg": 30, "plannedReps": 10 },
        { "setNumber": 3, "setType": "working", "plannedWeightKg": 60, "plannedReps": 10 },
        { "setNumber": 4, "setType": "working", "plannedWeightKg": 60, "plannedReps": 10 }
      ]
    }
  ]
}
```

- `setDetails` содержит per-set данные: planned (при создании/планировании) и actual (после complete)
- `setType`: `warmup` (разминочные, только для compound), `working` (рабочие), `dropset`
- Для completed-сессий `setDetails` включает `actualWeightKg`, `actualReps`, `actualRpe`, `completedAt`

### POST /workout-sessions/:id/complete

Завершает тренировочную сессию. Фронт отправляет все actual-данные по сетам разом. Минимум 1 actual сет обязателен.

**Body**:
```json
{
  "sets": [
    {
      "exerciseSlug": "bench-press",
      "setNumber": 1,
      "actualWeightKg": 20,
      "actualReps": 15,
      "actualRpe": 4
    },
    {
      "exerciseSlug": "bench-press",
      "setNumber": 2,
      "actualWeightKg": 60,
      "actualReps": 10,
      "actualRpe": 7
    }
  ]
}
```

| Поле | Обязателен | Описание |
|---|---|---|
| `sets` | Да | Массив actual-данных. Минимум 1 элемент |
| `sets[].exerciseSlug` | Да | Slug упражнения |
| `sets[].setNumber` | Да | Номер подхода (1-based) |
| `sets[].actualWeightKg` | Нет | Фактический вес (кг) |
| `sets[].actualReps` | Нет | Фактические повторения |
| `sets[].actualDurationSec` | Нет | Фактическая длительность (сек) — для кардио |
| `sets[].actualDistanceM` | Нет | Фактическая дистанция (м) — для кардио |
| `sets[].actualRpe` | Нет | Оценка усилия (1.0–10.0) |

**Constraints:**
- Сессия должна быть в статусе `planned`
- После complete статус → `completed`
- SetPlanner автоматически планирует сеты для следующей planned-сессии

### POST /workout-sessions/:id/skip

Пропускает плановую тренировку. Опционально создаёт дубликат на следующий свободный день.

**Body**:
```json
{
  "reschedule": true
}
```

| Поле | Обязателен | Описание |
|---|---|---|
| `reschedule` | Нет | `true` — создать дубликат сессии на следующий свободный день недели |

**Constraints:**
- Сессия должна быть в статусе `planned`
- При `reschedule=true`: создаётся новая planned-сессия с теми же упражнениями на следующий доступный день
- Оригинальная сессия помечается `skipped`

## Workout MILP

Генерация тренировок на основе MILP-оптимизации. Все эндпоинты требуют JWT.

### POST /workout-milp/generate

Генерация одной тренировки с учётом цели, опыта, пола, недельного объёма.

**Body**:
```json
{
  "sessionDurationMin": 60,
  "experienceLevel": "intermediate",
  "goal": "hypertrophy",
  "focusMuscles": ["chest", "back"],
  "specificMuscles": ["lats", "rear_delts"],
  "availableEquipment": ["barbell", "dumbbell"],
  "phase": "accumulation"
}
```

| Поле | Обязателен | Описание |
|------|-----------|----------|
| `sessionDurationMin` | Да | Длительность тренировки (20–120 мин) |
| `experienceLevel` | Нет | `beginner`, `intermediate`, `advanced` (default: `intermediate`) |
| `goal` | Нет | `strength`, `hypertrophy`, `endurance`, `weight_loss`, `general_health`, `rehab`, `mobility` |
| `focusMuscles` | Нет | Мышечные группы для акцента (`chest`, `back`, `legs`, `shoulders`, `arms`, `core`) |
| `specificMuscles` | Нет | Конкретные мышцы для приоритета (`lats`, `rear_delts`, `upper_chest` и т.д.) |
| `availableEquipment` | Нет | Slug-коды оборудования; пустой массив = только bodyweight |
| `equipmentPresetId` | Нет | ID пресета оборудования — переопределяет `availableEquipment` |
| `phase` | Нет | Фаза периодизации (`accumulation`, `intensification`, `realization`, `deload`) |

**Response**:
```json
{
  "exercises": [
    {
      "exerciseSlug": "barbell-bench-press",
      "sets": 4,
      "repsPerSet": 10,
      "order": 1
    }
  ],
  "totalTimeSec": 3000,
  "totalLoadByMuscle": { "chest": 12, "triceps": 0.72 },
  "templateId": "abc123",
  "usedFallback": false,
  "partialCoverage": false,
  "unmetMandatory": [],
  "metrics": {
    "totalSets": 15,
    "totalReps": 150,
    "estimatedTonnageKg": 4500,
    "relativeIntensity": 72,
    "activeTimeSec": 600,
    "restTimeSec": 900,
    "estimatedCalories": 280,
    "muscleLoadScores": { "chest": 8.5 },
    "fatigueIndex": 45
  }
}
```

- `sets` — переменный: compound-упражнения получают больше подходов (3–5), isolation — меньше (2–3)
- `repsPerSet` — определяется целью: strength 1–5, hypertrophy 6–12, endurance 15–25
- `usedFallback` — `true` если LP-решатель не нашёл решение и использовался жадный fallback
- `partialCoverage` — `true` если не все обязательные мышцы покрыты

### POST /workout-milp/metrics

Расчёт метрик для заданного набора упражнений.

**Body**:
```json
{
  "exercises": [
    { "exerciseSlug": "barbell-bench-press", "sets": 4 },
    { "exerciseSlug": "dumbbell-curl", "sets": 3 }
  ],
  "restBetweenSetsSec": 90,
  "bodyweightKg": 75,
  "goal": "hypertrophy"
}
```

| Поле | Обязателен | Описание |
|------|-----------|----------|
| `exercises` | Да | Массив упражнений (slug + sets) |
| `restBetweenSetsSec` | Нет | Отдых между подходами (default: 90) |
| `bodyweightKg` | Нет | Вес тела для оценки тонажа (default: 70) |
| `goal` | Нет | Цель — влияет на повторения и интенсивность |

**Response**:
```json
{
  "totalSets": 7,
  "totalReps": 70,
  "estimatedTonnageKg": 2100,
  "relativeIntensity": 72,
  "activeTimeSec": 280,
  "restTimeSec": 540,
  "estimatedCalories": 120,
  "muscleLoadScores": { "chest": 8.5, "triceps": 2.1 },
  "fatigueIndex": 45
}
```

### POST /workout-milp/weekly-plan

Генерация плана на неделю с автоподбором сплита.

**Body**:
```json
{
  "availableDays": ["monday", "wednesday", "friday"],
  "trainingCountPerWeek": 3,
  "sessionDurationMin": 60,
  "experienceLevel": "intermediate",
  "goal": "hypertrophy",
  "availableEquipment": ["barbell", "dumbbell", "cable"]
}
```

| Поле | Обязателен | Описание |
|------|-----------|----------|
| `availableDays` | Да | Дни недели, в которые можно тренироваться |
| `trainingCountPerWeek` | Да | Количество тренировок (2–6) |
| `sessionDurationMin` | Да | Длительность одной тренировки (20–120 мин) |
| `experienceLevel` | Нет | Определяет сплит и объём (default: `intermediate`) |
| `goal` | Нет | Цель (default: `general_health`) |
| `availableEquipment` | Нет | Оборудование; берётся из профиля если не указано |
| `equipmentPresetId` | Нет | ID пресета оборудования — переопределяет `availableEquipment` |
| `phase` | Нет | Фаза периодизации |

**Response**:
```json
{
  "blockId": "abc123",
  "splitName": "ppl",
  "sessions": [
    {
      "dayOfWeek": "monday",
      "sessionType": "push",
      "exercises": [
        { "exerciseSlug": "barbell-bench-press", "sets": 4, "repsPerSet": 10, "order": 1 }
      ],
      "loadByMuscle": { "chest": 12 },
      "totalTimeSec": 3000,
      "repsPerSet": 10
    }
  ],
  "totalWeeklyLoad": 150,
  "weeklyVolumeByMuscle": { "chest": 8, "back": 6 },
  "usedFallback": false
}
```

**Автоподбор сплита** (по `trainingCountPerWeek` + `experienceLevel`):

| Count | Beginner | Intermediate | Advanced |
|-------|----------|-------------|----------|
| 2 | Full Body ×2 | Upper / Lower | Upper / Lower |
| 3 | Full Body ×3 | Push / Pull / Legs | Push / Pull / Legs |
| 4 | Upper/Lower + FB×2 | Upper / Lower ×2 | PPL + Full Body |
| 5 | — | PPL + Upper / Lower | PPL + Push / Pull |
| 6 | — | PPL ×2 | PPL ×2 |

**Модификаторы по цели**: `weight_loss`, `endurance`, `rehab`, `mobility` заменяют часть сессий на Full Body.

## Workout Dialog

Диалоговая система для поштогового сбора параметров генерации тренировки. Сервер хранит состояние диалога, вопросы пропускаются если ответ есть в профиле пользователя.

### POST /workout-dialog/start

Начать новый диалог. Возвращает первый вопрос.

**Response**:
```json
{
  "dialogId": "abc123",
  "step": "plan_type",
  "question": "Что вы хотите получить?",
  "description": null,
  "inputType": "single_choice",
  "options": [
    { "value": "generate", "label": "Одну тренировку" },
    { "value": "weekly", "label": "План на неделю" }
  ],
  "canSkip": false,
  "collectedSoFar": {}
}
```

### POST /workout-dialog/:dialogId/answer

Отправить ответ на текущий шаг. Возвращает следующий вопрос или финальный результат.

**Body**: `{ "answer": "weekly" }`

**Ответ (следующий вопрос)**:
```json
{
  "dialogId": "abc123",
  "step": "goal",
  "question": "Какова ваша основная цель?",
  "description": "Это определит диапазон повторений и отдых между подходами",
  "inputType": "single_choice",
  "options": [
    { "value": "strength", "label": "Сила" },
    { "value": "hypertrophy", "label": "Рост мышц (гипертрофия)" },
    { "value": "endurance", "label": "Выносливость" },
    { "value": "weight_loss", "label": "Похудение" },
    { "value": "general_health", "label": "Общее здоровье" },
    { "value": "rehab", "label": "Реабилитация" },
    { "value": "mobility", "label": "Мобильность и растяжка" }
  ],
  "canSkip": false,
  "collectedSoFar": { "planType": "weekly" }
}
```

Для `multi_choice` шагов (`focus_muscles`, `equipment`, `days`) — ответ содержит выбранные значения через запятую: `"chest,back,legs"`. Повторная отправка значения toggle'ит выбор.

**Ответ (диалог завершён)**:
```json
{
  "dialogId": "abc123",
  "step": "complete",
  "planType": "weekly",
  "weeklyParams": {
    "availableDays": ["monday", "wednesday", "friday"],
    "trainingCountPerWeek": 3,
    "sessionDurationMin": 60,
    "experienceLevel": "intermediate",
    "goal": "hypertrophy",
    "availableEquipment": ["barbell", "dumbbell"]
  }
}
```

Если `planType` = `"generate"`, возвращается поле `generateParams` вместо `weeklyParams`.

### DELETE /workout-dialog/:dialogId

Удалить диалог. Возвращает 204 если успешно, 404 если не найден.

### GET /workout-dialog/:dialogId

Получить текущее состояние диалога (для возобновления после перезапуска приложения). Возвращает тот же формат что и answer.

**Последовательность шагов**:

| # | Шаг | Вопрос | Тип | Условие |
|---|-----|--------|-----|----------|
| 1 | `plan_type` | Что вы хотите получить? | single | — |
| 2 | `goal` | Какова ваша основная цель? | single | Пропускается если `user.metadata.goal` |
| 3 | `experience` | Ваш уровень подготовки? | single | Пропускается если `user.metadata.experienceLevel` |
| 4 | `focus_muscles` | На какие мышцы сделать акцент? | multi | Только для `plan_type=generate` |
| 5 | `equipment_preset` | Выберите оборудование или пресет | single | Пропускается если `availableEquipment` уже задан; если выбран пресет → шаг `equipment` пропускается |
| 6 | `equipment` | Какое оборудование доступно? | multi | Пропускается если выбран пресет; Пропускается если `user.metadata.availableEquipment` |
| 7 | `frequency` | Сколько тренировок в неделю? | single | Только для `plan_type=weekly` |
| 8 | `days` | В какие дни удобно тренироваться? | multi | Только для `plan_type=weekly` |
| 9 | `duration` | Сколько минут длится тренировка? | single | — |

## Home

Составной endpoint для главной страницы мобильного приложения. Требует JWT.

### GET /home/data

Возвращает активный тренировочный блок, сессии на запрошенную неделю и статус текущей тренировки.

**Query params**:

| Параметр | Обязателен | Описание |
|---|---|---|
| `weekStart` | Нет | Дата начала недели (ISO 8601, YYYY-MM-DD). По умолчанию — понедельник текущей недели |

**Response**:
```json
{
  "activeBlock": {
    "id": "block-123",
    "name": "Push Pull Legs",
    "type": "base",
    "durationWeeks": 4,
    "goal": "hypertrophy",
    "splitName": "ppl",
    "currentWeek": 2
  },
  "weekSessions": [
    {
      "id": "session-1",
      "dayOfWeek": "monday",
      "date": "2026-05-18",
      "status": "planned",
      "sessionType": "push",
      "description": "Грудь + плечи + трицепс",
      "exerciseCount": 6,
      "time": "18:00"
    }
  ],
  "weekStart": "2026-05-18",
  "weekEnd": "2026-05-24",
  "todaySession": {
    "id": "session-1",
    "sessionType": "push",
    "description": "Грудь + плечи + трицепс",
    "time": "18:00",
    "exerciseCount": 6
  }
}
```

- `activeBlock` — последний созданный `TrainingBlock` пользователя. `null` если блоков нет
- `weekSessions` — сессии блока на запрошенную неделю (вычисление даты из `dayOfWeek` + `weekStart`)
- `todaySession` — сессия на сегодняшний день недели. `null` если сегодня нет тренировки
- `currentWeek` — вычисляется из ID блока (ID содержит `Date.now()` timestamp)
- `description` — маппинг `sessionType` на русский: `push` → "Грудь + плечи + трицепс", `pull` → "Спина + бицепс", `legs` → "Ноги", `upper` → "Верх тела", `lower` → "Низ тела", `full_body` → "Все тело"

## Static Files

| Route | Description |
|---|---|
| `/media/<filename>.gif` | GIF-файлы упражнений (public) |

## Response Format

Пагинированный ответ:
```json
{
  "data": [...],
  "total": 1250,
  "page": 1,
  "limit": 20,
  "totalPages": 63
}
```
