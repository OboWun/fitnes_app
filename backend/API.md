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

Поля `goal`, `experienceLevel`, `availableEquipment` сохраняются в `user.metadata`. При обновлении метаданных существующие поля не затираются (merge).

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

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/exercises` | No | Список с пагинацией и фильтрами |
| GET | `/exercises/:slug/similar` | No | Похожие упражнения (те же целевые мышцы) |
| GET | `/exercises/:slug/antagonist` | No | Упражнения на антагонистические мышцы |

**Query params для GET /exercises**:
- `page` (int, default 1)
- `limit` (int, default 20)
- `search` (string) — поиск по имени/slug
- `contraindications` (CSV slugs) — исключить упражнения с этими противопоказаниями
- `equipments` (CSV slugs) — фильтр по оборудованию
- `targetMuscles` (CSV slugs) — фильтр по целевым мышцам

## Dictionaries

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/bodyparts` | No | Все части тела |
| GET | `/equipments` | No | Всё оборудование |
| GET | `/muscles` | No | Все мышцы (с антагонистами) |
| GET | `/contraindications` | No | Все противопоказания |

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
| GET | `/workout-sessions/block/:blockId` | JWT | Сессии блока |
| GET | `/workout-sessions/:id` | JWT | Сессия по ID |
| POST | `/workout-sessions` | JWT | Создать сессию |
| PATCH | `/workout-sessions/:id` | JWT | Обновить сессию |
| DELETE | `/workout-sessions/:id` | JWT | Удалить сессию |

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
