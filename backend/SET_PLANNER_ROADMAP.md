# SET_PLANNER_ROADMAP.md — Интеграция ML-модели для предсказания рабочих весов

## Current State (MVP)

SetPlanner (`src/workout-sessions/set-planner.service.ts`) использует простую эвристику:

1. **e1RM оценка**: `weight × (1 + reps/30)` из лучшего сета последних 5 completed
2. **Прогрессия**:
   - Все RPE ≤ 7 → +2.5 kg (upper) / +5 kg (lower)
   - Любой RPE ≥ 9 → -1.25 kg / -2.5 kg
   - Остальное → без изменений
3. **Warmup**: compound (bar × 15, 50% × 10, 75% × 8) при рабочем весе > 40 kg
4. **Дефолты**: по experienceLevel при отсутствии истории
5. **Fatigue**: `applyFatigueAdjustment()` — stub, возвращает вес без изменений

## Phase 2: Regression Model

### Входные данные (уже доступны)

| Признак | Источник | Тип |
|---------|----------|-----|
| `actual_weight_kg` | `workout_session_sets` | числовой |
| `actual_reps` | `workout_session_sets` | числовой |
| `actual_rpe` | `workout_session_sets` | числовой (1.0–10.0) |
| `e1rm` | вычисляется из weight × (1 + reps/30) | числовой |
| `days_since_last` | `completed_at` + текущая дата | числовой |
| `volume_48h` | SUM(sets) за 48ч на ту же muscle group | числовой |
| `body_weight` | `users.weight` | числовой |
| `experience_level` | `users.metadata.experienceLevel` | категориальный |
| `exercise_type` | `exercises.movement_pattern` | категориальный |
| `session_week` | номер недели в блоке | числовой |

### Модель

- **Тип**: Gradient Boosting (XGBoost/LightGBM) или простая нейросеть
- **Целевая переменная**: `predicted_weight_kg` для следующей тренировки
- **Обучение**: offline, периодический ретрейн (еженедельно/ежемесячно)
- **Inference**: REST endpoint или in-process (ONNX)

### Endpoints

```
GET /ml/predict-weight?exerciseSlug=bench-press&userId=xxx
  → { "predictedWeightKg": 62.5, "confidence": 0.85 }
```

### Интеграция

Заменить `predictWorkingWeight()` в SetPlanner:
```typescript
// Было: e1RM + простая прогрессия
// Станет: запрос к ML-модели
const prediction = await this.mlService.predict({
  userId, exerciseSlug, history, user, session
});
return prediction.weightKg;
```

## Phase 3: Wave Periodization

Для advanced-уровня (experienceLevel = 'advanced'):

### Модель

- **Недельный паттерн**: heavy (85-95% 1RM) / moderate (70-80%) / light (55-65%)
- **Объём**: high (20+ sets/week) → medium → low → deload
- **Фаза**: accumulation → intensification → realization → deload (4-6 week cycles)

### Входные данные

- Training age (месяцы)
- Recovery capacity (user.metadata.recoveryCapacity)
- Block type (base/build/taper/recovery)
- Current week in block
- Historical performance trend (линейная регрессия e1RM за 4-8 недель)

### Реализация

```typescript
// В SetPlanner.predictWorkingWeight()
if (experienceLevel === 'advanced') {
  return this.wavePeriodization(history, block, currentWeek);
}
```

## Roadmap

| Фаза | Описание | Срок | Зависимости |
|------|----------|------|-------------|
| MVP | e1RM + линейная прогрессия | ✅ Done | — |
| Phase 2 | ML regression model | ~2-3 недели | 50+ completed sessions per user |
| Phase 3 | Wave periodization | ~1-2 недели | Phase 2 + training age data |

## Data Requirements

Минимум данных для обучения ML-модели:
- 50+ completed `workout_session_sets` для данного упражнения и юзера
- Или агрегированные данные: 1000+ completed sets от 10+ юзеров

Пока данных недостаточно — MVP-эвристика работает хорошо.
