import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/features/auth/auth_provider.dart';
import 'package:mobile/features/auth/domain/auth_state.dart';
import 'package:mobile/features/splash/splash_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpSplashPage(
    WidgetTester tester, {
    AuthState? authState,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (authState != null)
            authProvider.overrideWith(() => _TestAuthNotifier(authState)),
        ],
        child: const MaterialApp(
          home: SplashPage(),
        ),
      ),
    );
  }

  testWidgets('shows FitnessX title', (tester) async {
    await pumpSplashPage(tester);

    expect(find.text('FitnessX'), findsOneWidget);
  });

  testWidgets('shows subtitle', (tester) async {
    await pumpSplashPage(tester);

    expect(find.text('Everybody Can Train'), findsOneWidget);
  });

  testWidgets('shows loading indicator when status is loading',
      (tester) async {
    await pumpSplashPage(
      tester,
      authState: const AuthState(status: AuthStatus.loading),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message when status is error', (tester) async {
    await pumpSplashPage(
      tester,
      authState: const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Connection refused',
      ),
    );

    expect(find.text('Не удалось подключиться к серверу'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });

  testWidgets('shows retry button when error', (tester) async {
    await pumpSplashPage(
      tester,
      authState: const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Error',
      ),
    );

    final retryButton = find.widgetWithText(ElevatedButton, 'Повторить');
    expect(retryButton, findsOneWidget);
  });

  testWidgets('does not show loading when status is initial', (tester) async {
    await pumpSplashPage(
      tester,
      authState: const AuthState(status: AuthStatus.initial),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('does not show error when status is loading', (tester) async {
    await pumpSplashPage(
      tester,
      authState: const AuthState(status: AuthStatus.loading),
    );

    expect(find.text('Не удалось подключиться к серверу'), findsNothing);
  });

  testWidgets('shows fitness icon', (tester) async {
    await pumpSplashPage(tester);

    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
  });
}

class _TestAuthNotifier extends Auth {
  final AuthState _state;

  _TestAuthNotifier(this._state);

  @override
  AuthState build() => _state;
}
