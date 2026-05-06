# Iteration Data

Этот документ описывает, какие данные нужно вставлять в каждую итерацию MILP-внедрения. Формулировки даны как практический фитнес-контекст и частично опираются на `backend/refs/hybrid_model.ipynb`.

## Итерация 1: Обогатить данные для одной тренировки

### Какие данные нужны

- `Exercise.metadata.complexityScore` - сложность упражнения для выбора уровня нагрузки.
- `Exercise.metadata.fatigueCost` - утомляемость упражнения для штрафа в objective.
- `Exercise.metadata.timeCostSec` - реальная стоимость упражнения по времени.
- `Exercise.metadata.riskLevel` - риск травмоопасности и технической ошибки.
- `Exercise.metadata.jointStress` - нагрузка на суставы и связки.
- `Exercise.metadata.primaryMuscleWeights` - основная мышечная нагрузка.
- `Exercise.metadata.secondaryMuscleWeights` - вспомогательная мышечная нагрузка.
- `Exercise.metadata.phaseAffinity` - уместность упражнения в фазе периода.
- `Exercise.metadata.variationGroup` - группа заменяемости.
- `User.metadata.goal` - цель пользователя для ранжирования упражнений.
- `User.metadata.availableEquipment` - доступное оборудование, если оно не фиксируется отдельно.
- `User.metadata.trainingAgeMonths` - стаж для адаптации сложности.
- `User.metadata.experienceLevel` - уровень подготовки для выбора упражнений.
- `User.metadata.recoveryCapacity` - скорость восстановления для штрафов усталости.
- `User.metadata.injuryHistory` - история травм для фильтрации риска.
- `User.metadata.currentLimitations` - текущие ограничения для hard/soft constraints.
- `User.metadata.preferredExercises` - предпочтения для увеличения веса упражнения.
- `User.metadata.dislikedExercises` - нежелательные упражнения для снижения веса.

### Что брать из `hybrid_model.ipynb`

- `alpha_1 = 1.5` - вес сложности.
- `alpha_2 = 0.5` - вес частоты использования.
- `alpha_3 = 2.0` - вес аффинности.
- `delta = 0.2` - вес разнообразия.
- `epsilon = 0.2` - вес штрафа усталости.
- `theta = 1.5` - порог усталости.
- `lambda = 0.345` - восстановление.
- `V_e(t) = min(1, Δt_e / 4)` - функция разнообразия.
- `P_e(t)` - функция штрафа за усталость.
- `I_{e,m}` - матрица интенсивности с базовыми весами `1.0 / 0.5 / 0.3`.

### Как это использовать в MILP

- Эти данные идут в `Workout MILP`.
- `sessionDurationMin` передается как входной параметр генерации тренировки, а не как поле `User`.
- Если `forbidden`, упражнение исключается.
- Если `not_recommended`, упражнение штрафуется.
- Если `low_weight`, упражнение остается доступным с пониженным весом.

### Ожидаемый результат

Система выбирает упражнения и число подходов с учетом цели, времени, оборудования, противопоказаний и текущего состояния пользователя.

## Итерация 2: Обогатить данные для недельного процесса

### Какие данные нужны

- `TrainingBlock.type` - тип недели или блока.
- `TrainingBlock.index` - порядковый номер блока.
- `TrainingBlock.durationWeeks` - длительность блока.
- `TrainingBlock.goal` - цель периода.
- `TrainingBlock.targetMuscles` - приоритетные мышцы периода.
- `TrainingBlock.metadata.phase` - фаза периода.
- `TrainingBlock.metadata.minRestDays` - минимальный отдых.
- `TrainingBlock.metadata.maxRestDays` - максимальный отдых.
- `TrainingBlock.metadata.weeklyLoadLimit` - лимит нагрузки на неделю.
- `TrainingBlock.metadata.consecutiveTrainingDaysLimit` - лимит тренировок подряд.
- `WorkoutSession.dayOfWeek` - день недели.
- `WorkoutSession.status` - статус планирования или выполнения.
- `WorkoutSession.metadata.sessionLoadByMuscle` - нагрузка по мышцам.

### Что брать из `hybrid_model.ipynb`

- логику экспоненциального восстановления;
- логику разнообразия через историю;
- штраф за перегрузку уставших мышц;
- прогрессию нагрузки внутри блока.

### Как это использовать в MILP

- Эти данные идут в `Weekly Process MILP`.
- Модель назначает тренировки на дни недели.
- Модель контролирует интервалы отдыха между тренировками.
- Модель поддерживает прогрессию или разгрузку внутри недели.

### Ожидаемый результат

Система строит недельный тренировочный процесс с привязкой к дням и контролем восстановления.

## Итерация 3: Обогатить данные для замены существующей тренировки

### Какие данные нужны

- `WorkoutSession.metadata.previousSessionId` - предыдущая тренировка в неделе.
- `WorkoutSession.metadata.nextSessionId` - следующая тренировка в неделе.
- `WorkoutSession.metadata.sessionLoadByMuscle` - фактическая или целевая нагрузка.
- `WorkoutSession.metadata.sessionDurationMin` - длительность текущей сессии.
- `WorkoutSession.metadata.mandatoryMuscles` - мышцы, которые нельзя потерять.
- `WorkoutSession.metadata.forbiddenExercises` - упражнения, которые нельзя ставить.
- `WorkoutSession.metadata.allowedTimeDeviationMin` - допустимое отклонение по времени.
- `WorkoutSession.metadata.allowedLoadDeviation` - допустимое отклонение по нагрузке.

### Что брать из `hybrid_model.ipynb`

- принцип recency для повторяемости;
- принцип similarity для сохранения структуры;
- принцип fatigue-aware replacement.

### Как это использовать в MILP

- Замена тренировки должна сохранять структуру недели.
- Замена не должна ломать отдых и восстановление.
- Замена не должна нарушать недельный баланс по мышцам.

### Ожидаемый результат

Система заменяет тренировку без разрушения недельного процесса.

## Итерация 4: Зафиксировать числовые коэффициенты и функции перевода

### Какие данные нужны

- `Exercise.metadata.complexityScore` как источник `f_complexity`.
- история использования упражнений как источник `f_frequency`.
- `Exercise.metadata.phaseAffinity` как источник `f_affinity`.
- `Exercise.metadata.fatigueCost` как источник штрафа усталости.
- `Exercise.metadata.timeCostSec` как источник временного ограничения.
- `User.metadata.recoveryCapacity` как источник персональной скорости восстановления.

### Что брать из `hybrid_model.ipynb`

- `lambda = 0.345`;
- `theta = 1.5`;
- `alpha_1 = 1.5`;
- `alpha_2 = 0.5`;
- `alpha_3 = 2.0`;
- `delta = 0.2`;
- `epsilon = 0.2`;
- `V_e(t) = min(1, Δt_e / 4)`;
- `P_e(t) = min(1, Σ I_{e,m} · max(0, F_m(t) - θ))`.

### Как это использовать в MILP

- Все коэффициенты должны храниться или вычисляться из `metadata`.
- `forbidden` всегда дает нулевую допустимость.
- `not_recommended` снижает приоритет.
- `low_weight` снижает приоритет мягко.

### Ожидаемый результат

Система использует единые числовые правила вместо ручных ветвлений.

## Итерация 5: Собрать адаптивный контур обновления модели

### Какие данные нужны

- история завершенных тренировок;
- `RPE`;
- `soreness`;
- `readiness`;
- `pain`;
- `technique`;
- фактический объем;
- фактическая длительность;
- результаты замены тренировок;
- изменения `metadata` после недели.

### Что брать из `hybrid_model.ipynb`

- механизм обновления усталости после каждой тренировки;
- принцип накопления и восстановления нагрузки;
- принцип recalibration weights.

### Как это использовать в MILP

- После каждой недели пересчитывать коэффициенты.
- Использовать фактический факт выполнения для корректировки priors.
- Проверять согласованность `metadata` перед новым планированием.

### Ожидаемый результат

Система становится адаптивной и начинает учитывать реальную историю выполнения.
