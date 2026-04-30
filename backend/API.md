# API Reference

Base URL: `http://localhost:3000`  
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
{ "name": "string", "weight": 70, "height": 175, "age": 25, "contraindications": ["slug1"] }
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
