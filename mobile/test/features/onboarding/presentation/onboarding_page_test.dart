import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/features/auth/auth_provider.dart';
import 'package:mobile/features/auth/domain/auth_state.dart';
import 'package:mobile/features/onboarding/onboarding_provider.dart';
import 'package:mobile/features/onboarding/domain/onboarding_state.dart';
import 'package:mobile/features/onboarding/presentation/onboarding_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OnboardingPage', () {
    testWidgets('renders without errors', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
                () => _TestAuthNotifier(const AuthState())),
            contraindicationsProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: OnboardingPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(OnboardingPage), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('shows Далее button', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
                () => _TestAuthNotifier(const AuthState())),
            contraindicationsProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: OnboardingPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Далее'), findsOneWidget);
    });

    testWidgets('shows Завершить on last step', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
                () => _TestAuthNotifier(const AuthState())),
            onboardingProvider.overrideWith(
              () => _TestOnboardingNotifier(
                const OnboardingState(
                    currentStep: 4, name: 'Иван', gender: 'male'),
              ),
            ),
            contraindicationsProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: OnboardingPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Завершить'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when submitting',
        (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
                () => _TestAuthNotifier(const AuthState())),
            onboardingProvider.overrideWith(
              () => _TestOnboardingNotifier(
                const OnboardingState(
                  currentStep: 4,
                  name: 'Иван',
                  gender: 'male',
                  isSubmitting: true,
                ),
              ),
            ),
            contraindicationsProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: OnboardingPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

class _TestOnboardingNotifier extends Onboarding {
  final OnboardingState _state;

  _TestOnboardingNotifier(this._state);

  @override
  OnboardingState build() => _state;
}

class _TestAuthNotifier extends Auth {
  final AuthState _state;

  _TestAuthNotifier(this._state);

  @override
  AuthState build() => _state;
}
