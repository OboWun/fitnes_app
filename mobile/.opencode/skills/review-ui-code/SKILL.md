---
name: review-ui-code
description: Ревью UI-кода по чек-листу из 10 правил. Проверка dumb/smart разделения, InkWell, Padding, строк, loading, API виджета, public.dart, retry.
---

## Что я делаю

Проверяю UI-код (виджеты, страницы, containers) на соответствие **10 правилам архитектуры** проекта.

## Когда использовать

- Ревью PR с UI-изменениями
- Проверка написанного виджета/страницы
- Рефакторинг существующего UI-кода

## Чек-лист ревью

### 1. InkWell для нажатий
- [ ] Все обработчики tap используют `InkWell` (не `GestureDetector`)
- [ ] `InkWell` имеет `borderRadius`
- [ ] `GestureDetector` используется только для свайпов/длинного нажатия

### 2. ValueNotifier для локального состояния
- [ ] Локальное состояние виджета — `ValueNotifier` + `ValueListenableBuilder`
- [ ] Нет Riverpod для локального состояния
- [ ] Нет лишних `setState` (предпочитаем ValueNotifier)

### 3. Без buildSomething методов
- [ ] Нет `buildHeader()`, `buildBody()`, `buildFooter()` и т.д.
- [ ] Каждый кандидат — отдельный виджет (`_PrivateWidget` или публичный)
- [ ] Если файл > 250 строк — используется `part`/`part of`

### 4. Без Padding между виджетами
- [ ] Отступы между виджетами: `Column(spacing:)` / `Row(spacing:)` или `SizedBox`
- [ ] `Padding` используется **только** для внутренних отступов виджета
- [ ] Нет `margin` для отступов между виджетами

### 5. Widget.loading() — union-паттерн
- [ ] Каждый виджет имеет `.loading()`-конструктор
- [ ] Loading реализован через приватный класс (`_LoadingWidget`)
- [ ] Нет freezed для виджетов — ручной union через `const factory`
- [ ] Все дочерние виджеты приватные (`_`)

### 6. API виджета — value + onChanged
- [ ] Виджет принимает данные через `<T> value`
- [ ] События через `ValueChanged<T>? onChanged` (или `onTap`, `onSubmit`)
- [ ] Контроллеры — optional параметры
- [ ] `onChanged` вызывается как факт действия (не как "собираюсь изменить")

### 7. Dumb/Smart разделение
- [ ] Dumb-виджет: нет riverpod, нет навигации, нет провайдеров
- [ ] Dumb-виджет: `const`-constructible по возможности
- [ ] Smart-виджет: оборачивает dumb, подключает riverpod
- [ ] Smart-виджет: управляет навигацией и lifecycle
- [ ] Page — это smart-виджет верхнего уровня

### 8. Riverpod — только для запросов и глобального состояния
- [ ] Riverpod: HTTP-запросы, глобальное состояние (auth, user)
- [ ] Не Riverpod: локальное состояние виджета, формы
- [ ] Retry: max 3, exponential backoff (1с, 2с, 3с) на уровне riverpod

### 9. < 250 строк
- [ ] Каждый файл верстки < 250 строк
- [ ] Если больше — `part`/`part of` или отдельный файл
- [ ] Нет "божественных" файлов

### 10. WidgetContainer для групп
- [ ] Группа однотипных виджетов → WidgetContainer
- [ ] Container принимает `List<T>` + `ValueChanged<T>? onTap`
- [ ] Container имеет `.loading()` — решает количество скелетонов
- [ ] Container не имеет error-состояния

---

## Дополнительные проверки

### Структура фичи
- [ ] `public.dart` создан и экспортирует нужное
- [ ] Dumb-виджеты в `presentation/widgets/`
- [ ] Smart-виджеты в `presentation/smart_widgets/`
- [ ] Provider'ы на уровне фичи
- [ ] Модели в `domain/`

### ErrorHandlingMixin
- [ ] Страницы используют ErrorHandlingMixin
- [ ] Ошибки показываются через toast/snackbar
- [ ] Есть кнопка перезагрузки
- [ ] При ошибке страница в loading-состоянии

### Код-стайл
- [ ] Нет комментариев (кроме запроса разработчика)
- [ ] const-конструкторы где возможно
- [ ] Нет хардкода строк (используем константы или локализацию)

---

## Результат ревью

После проверки сообщить:
1. **Список нарушений** с указанием правила и файла/строки
2. **Предложения по исправлению** — какие виджеты выделить, куда перенести
3. **Оценка** — сколько нарушений, критичные или нет

### Формат ответа:

```
## Результат ревью: <файл>

### Нарушения:
- [Правило 3] buildBody() в строке 45 → выделить в _BodyWidget
- [Правило 4] Padding(bottom: 16) в строке 67 → заменить на SizedBox
- [Правило 7] ref.watch в ExerciseCard → создать ExerciseCardSmart

### Предложения:
- ExerciseCard → dumb (убрать ref.watch)
- Создать ExerciseCardSmart в smart_widgets/
- public.dart: добавить export ExerciseCard

### Оценка: 3 нарушения (2 критичных, 1 некритичное)
```

## Ссылки

- Полные правила: `ai_tools/rules.md`
- Dumb-виджет: skill `create-dumb-widget`
- Smart-виджет: skill `create-smart-widget`
- WidgetContainer: skill `create-widget-container`
- Страница: skill `create-page`
