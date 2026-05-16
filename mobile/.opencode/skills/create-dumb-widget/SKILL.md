---
name: create-dumb-widget
description: Создание глупого (dumb) виджета — StatelessWidget или StatefulWidget с loading-состоянием, без riverpod, без навигации. API: value + onChanged. InkWell для tap. < 250 строк.
---

## Что я делаю

Создаю **глупый (dumb) виджет** — чистый UI-компонент, который:
- Рисует данные
- Предоставляет API через `value` + `ValueChanged? onChanged`
- Умеет в `loading()`-состояние
- НЕ знает про riverpod, навигацию, провайдеры

## Когда использовать

- Создание нового UI-компонента (карточка, ячейка, кнопка, поле, бейдж)
- Рефакторинг `buildSomething()` методов в отдельные виджеты
- Создание виджета, который принимает данные и опционально сообщает об изменениях

## Чек-лист

### Обязательные проверки:

- [ ] **const-конструктор** — по возможности `const`
- [ ] **Нет riverpod** — ни `ref.watch`, ни `ref.read`, ни провайдеров
- [ ] **Нет навигации** — ни `context.go()`, ни `Navigator.push()`, ни `GoRouter`
- [ ] **API виджета:** `<T> value` + `ValueChanged<T>? onChanged` (или `onTap`, `onSubmit` и т.д.)
- [ ] **Tap:** `InkWell` с `borderRadius` и визуальной обратной связью
- [ ] **Нет Padding между виджетами** — только внутренний padding (для размещения своего контента)
- [ ] **Loading:** `const factory Widget.loading()` — приватный класс
- [ ] **Контроллеры:** optional параметры + `onChanged` как альтернатива
- [ ] **< 250 строк** — если больше → `part`/`part of` или отдельный файл
- [ ] **Нет `buildSomething()` методов** → каждый кандидат в отдельный `_PrivateWidget`

## Шаблон: StatelessWidget с loading

```dart
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final UserModel? _user;
  final ValueChanged<UserModel>? _onTap;

  const UserCard({
    super.key,
    required UserModel user,
    ValueChanged<UserModel>? onTap,
  })  : _user = user,
        _onTap = onTap;

  const UserCard.loading({super.key})
      : _user = null,
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const _UserCardLoading();
    return _UserCardData(user: _user!, onTap: _onTap);
  }
}

class _UserCardData extends StatelessWidget {
  final UserModel user;
  final ValueChanged<UserModel>? onTap;

  const _UserCardData({required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(user),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(user.email, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _UserCardLoading extends StatelessWidget {
  const _UserCardLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 120, height: 16),
          SizedBox(height: 4),
          ShimmerBox(width: 180, height: 12),
        ],
      ),
    );
  }
}
```

## Шаблон: StatefulWidget абстрактный с loading

```dart
import 'package:flutter/material.dart';

abstract class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  const factory AuthForm.data({
    required UserModel user,
    ValueChanged<UserModel>? onSubmit,
    TextEditingController? loginController,
    TextEditingController? passwordController,
  }) = _DataAuthForm;

  const factory AuthForm.loading() = _LoadingAuthForm;
}

class _DataAuthForm extends AuthForm {
  final UserModel user;
  final ValueChanged<UserModel>? onSubmit;
  final TextEditingController? loginController;
  final TextEditingController? passwordController;

  const _DataAuthForm({
    required this.user,
    this.onSubmit,
    this.loginController,
    this.passwordController,
  });

  @override
  State<_DataAuthForm> createState() => _DataAuthFormState();
}

class _DataAuthFormState extends State<_DataAuthForm> {
  late final TextEditingController _loginCtrl;
  late final TextEditingController _passwordCtrl;

  @override
  void initState() {
    super.initState();
    _loginCtrl = widget.loginController ?? TextEditingController(text: widget.user.email);
    _passwordCtrl = widget.passwordController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.loginController == null) _loginCtrl.dispose();
    if (widget.passwordController == null) _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _loginCtrl,
          decoration: const InputDecoration(labelText: 'Логин'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordCtrl,
          decoration: const InputDecoration(labelText: 'Пароль'),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => widget.onSubmit?.call(widget.user),
          child: const Text('Войти'),
        ),
      ],
    );
  }
}

class _LoadingAuthForm extends StatelessWidget implements AuthForm {
  const _LoadingAuthForm();

  @override
  State<StatefulWidget> createState() => StatefulElement(this).state;

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ShimmerField(),
        SizedBox(height: 16),
        ShimmerField(),
        SizedBox(height: 24),
        ShimmerBox(width: double.infinity, height: 48),
      ],
    );
  }
}
```

## Шаблон: ValueNotifier для локального состояния

```dart
class WeekCalendar extends StatelessWidget {
  final List<WeekSession> sessions;
  final ValueChanged<WeekSession>? onSessionTap;

  const WeekCalendar({
    super.key,
    required this.sessions,
    this.onSessionTap,
  });

  const WeekCalendar.loading({super.key})
      : sessions = const [],
        onSessionTap = null;

  @override
  Widget build(BuildContext context) {
    final selectedDay = ValueNotifier<DateTime>(DateTime.now());

    return ValueListenableBuilder<DateTime>(
      valueListenable: selectedDay,
      builder: (context, day, _) {
        return Row(
          spacing: 8,
          children: sessions.map((session) {
            return _DayCard(
              session: session,
              isSelected: session.date == day,
              onTap: onSessionTap,
            );
          }).toList(),
        );
      },
    );
  }
}
```

## Критерии готовности

- [ ] Виджет компилируется без ошибок
- [ ] Есть data-конструктор и `.loading()`-конструктор
- [ ] Нет riverpod-зависимостей
- [ ] Нет навигации
- [ ] InkWell для tap-обработки
- [ ] API: value + onChanged/onTap
- [ ] < 250 строк
- [ ] Все дочерние виджеты приватные (`_`)

## Ссылки

- Полные правила: `ai_tools/rules.md`
- Smart-обёртка для этого виджета: skill `create-smart-widget`
- Контейнер для группы таких виджетов: skill `create-widget-container`
