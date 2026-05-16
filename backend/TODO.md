# TODO: Backend endpoints for mobile app

## GET /home/data

Составной endpoint для главной страницы мобильного приложения.
Требует JWT.

### Описание

Возвращает данные для отображения на главной: активный тренировочный блок,
сессии на запрошенную неделю, статус текущей тренировки.

### Query params

| Параметр | Обязателен | Описание |
|---|---|---|
| `weekStart` | Нет | Дата начала недели (ISO 8601, YYYY-MM-DD). По умолчанию — понедельник текущей недели |

### Response

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
    },
    {
      "id": "session-2",
      "dayOfWeek": "wednesday",
      "date": "2026-05-20",
      "status": "planned",
      "sessionType": "pull",
      "description": "Спина + бицепс",
      "exerciseCount": 5,
      "time": "18:00"
    },
    {
      "id": "session-3",
      "dayOfWeek": "friday",
      "date": "2026-05-22",
      "status": "planned",
      "sessionType": "legs",
      "description": "Ноги",
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

### Логика

1. Найти последний созданный `TrainingBlock` пользователя (по `created_at` DESC, LIMIT 1)
2. Если блок не найден → `activeBlock: null`, `weekSessions: []`, `todaySession: null`
3. Если блок найден — загрузить все `WorkoutSession` этого блока
4. Отфильтровать сессии по дате недели (`weekStart` .. `weekStart + 6 дней`)
5. Определить `todaySession` — сессия на сегодняшний день недели
6. `currentWeek` — вычислить из `block.createdAt` и текущей даты
7. `description` — брать из `metadata.sessionType`, маппить на русский:
   - `push` → "Грудь + плечи + трицепс"
   - `pull` → "Спина + бицепс"
   - `legs` → "Ноги"
   - `upper` → "Верх тела"
   - `lower` → "Низ тела"
   - `full_body` → "Все тело"
   - Если несколько мышц — перечислить основные через "+"

### Ограничения навигации

Мобильное приложение ограничивает навигацию по неделям:
- Назад: не раньше текущей недели (прошлые недели не просматриваются)
- Вперёд: максимум +1 месяц от текущей недели

Эти ограничения реализуются на клиенте. Сервер должен корректно возвращать данные
для любой запрошенной недели в пределах активного блока.

### Future improvements

- Добавить `completedExercises` count для `todaySession` (прогресс текущей тренировки)
- Добавить `streakDays` — количество дней подряд с тренировками
