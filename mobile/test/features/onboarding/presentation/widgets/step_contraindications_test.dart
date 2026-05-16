import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/features/auth/auth_provider.dart';
import 'package:mobile/features/auth/domain/auth_state.dart';
import 'package:mobile/features/onboarding/presentation/widgets/sliver_contraindications_step.dart';
import 'package:mobile/design_system/widgets/shimmer_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget testWidget({
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith(
          () => _TestAuthNotifier(const AuthState()),
        ),
        ...overrides,
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverContraindicationsStep.loading(),
            ],
          ),
        ),
      ),
    );
  }

  Widget testDataWidget({
    required List<Map<String, dynamic>> items,
    required List<String> selected,
    ValueChanged<String>? onToggle,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverContraindicationsStep(
              items: items,
              selected: selected,
              onToggle: onToggle,
            ),
          ],
        ),
      ),
    );
  }

  group('SliverContraindicationsStep', () {
    testWidgets('shows title and description in data mode', (tester) async {
      await tester.pumpWidget(testDataWidget(
        items: [],
        selected: [],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Противопоказания'), findsOneWidget);
      expect(
        find.text('Необязательно. Мы исключим неподходящие упражнения'),
        findsOneWidget,
      );
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(testWidget());
      await tester.pump();

      expect(find.byType(ShimmerCard), findsWidgets);
    });

    testWidgets('shows list of contraindications', (tester) async {
      await tester.pumpWidget(testDataWidget(
        items: [
          {'slug': 'knee_injury', 'name': 'Травма колена'},
          {'slug': 'back_pain', 'name': 'Травма спины'},
        ],
        selected: [],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Травма колена'), findsOneWidget);
      expect(find.text('Травма спины'), findsOneWidget);
    });

    testWidgets('shows empty message when no items', (tester) async {
      await tester.pumpWidget(testDataWidget(
        items: [],
        selected: [],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Нет противопоказаний'), findsOneWidget);
    });

    testWidgets('taps item to call onToggle', (tester) async {
      String? toggledSlug;

      await tester.pumpWidget(testDataWidget(
        items: [
          {'slug': 'knee_injury', 'name': 'Травма колена'},
        ],
        selected: [],
        onToggle: (slug) => toggledSlug = slug,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Травма колена'));
      await tester.pumpAndSettle();

      expect(toggledSlug, 'knee_injury');
    });

    testWidgets('shows selected state for toggled items', (tester) async {
      await tester.pumpWidget(testDataWidget(
        items: [
          {'slug': 'knee_injury', 'name': 'Травма колена'},
        ],
        selected: ['knee_injury'],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_box), findsOneWidget);
    });
  });
}

class _TestAuthNotifier extends Auth {
  final AuthState _state;
  _TestAuthNotifier(this._state);
  @override
  AuthState build() => _state;
}
