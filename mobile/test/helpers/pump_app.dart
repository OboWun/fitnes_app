import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/router/app_router.dart';
import 'package:mobile/core/storage/auth_storage.dart';
import 'package:mobile/features/auth/auth_provider.dart';
import 'package:mobile/features/auth/domain/auth_state.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    List<Override> overrides = const [],
    AuthState? authState,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final defaultOverrides = [
      sharedPreferencesProvider.overrideWithValue(prefs),
      if (authState != null)
        authProvider.overrideWith(() => _FakeAuthNotifier(authState)),
      ...overrides,
    ];

    await pumpWidget(
      ProviderScope(
        overrides: defaultOverrides,
        child: MaterialApp(
          home: widget,
        ),
      ),
    );
  }

  Future<void> pumpAppWithRouter({
    List<Override> overrides = const [],
    AuthState? authState,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final defaultOverrides = [
      sharedPreferencesProvider.overrideWithValue(prefs),
      if (authState != null)
        authProvider.overrideWith(() => _FakeAuthNotifier(authState)),
      ...overrides,
    ];

    final container = ProviderContainer(overrides: defaultOverrides);
    final router = container.read(appRouterProvider);

    await pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
  }
}

class _FakeAuthNotifier extends Auth {
  final AuthState _state;

  _FakeAuthNotifier(this._state);

  @override
  AuthState build() => _state;
}
