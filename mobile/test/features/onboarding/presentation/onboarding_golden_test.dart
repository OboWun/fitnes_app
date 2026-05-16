import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/features/auth/auth_provider.dart';
import 'package:mobile/features/auth/domain/auth_state.dart';
import 'package:mobile/features/onboarding/onboarding_provider.dart';
import 'package:mobile/features/onboarding/domain/onboarding_state.dart';
import 'package:mobile/features/onboarding/presentation/onboarding_page.dart';

const _goldensDir = 'test/features/onboarding/presentation/goldens';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
  });

  Future<void> capture(
    WidgetTester tester, {
    required String name,
    required OnboardingState onboardingState,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(
            () => _TestAuthNotifier(const AuthState())),
        onboardingProvider.overrideWith(
          () => _TestOnboardingNotifier(onboardingState),
        ),
        contraindicationsProvider.overrideWith((ref) async => []),
      ],
    );

    final key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: TickerMode(
          enabled: false,
          child: UncontrolledProviderScope(
            container: container,
            child: RepaintBoundary(
              key: key,
              child: const OnboardingPage(),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    final dir = Directory(_goldensDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final file = File('$_goldensDir/$name.png');
    await file.writeAsBytes(byteData!.buffer.asUint8List());
  }

  testWidgets('step_0_name', (tester) async {
    await capture(
      tester,
      name: 'step_0_name',
      onboardingState: const OnboardingState(),
    );
  });

  testWidgets('step_1_gender', (tester) async {
    await capture(
      tester,
      name: 'step_1_gender',
      onboardingState: const OnboardingState(
          currentStep: 1, name: 'Иван'),
    );
  });

  testWidgets('step_2_age', (tester) async {
    await capture(
      tester,
      name: 'step_2_age',
      onboardingState: const OnboardingState(
          currentStep: 2, name: 'Иван', gender: 'male'),
    );
  });

  testWidgets('step_3_body_params', (tester) async {
    await capture(
      tester,
      name: 'step_3_body_params',
      onboardingState: const OnboardingState(
          currentStep: 3, name: 'Иван', gender: 'male', age: 25),
    );
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
