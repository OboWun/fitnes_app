import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/onboarding/domain/onboarding_state.dart';

void main() {
  group('OnboardingState', () {
    test('has correct defaults', () {
      const state = OnboardingState();

      expect(state.currentStep, 0);
      expect(state.totalSteps, 5);
      expect(state.name, '');
      expect(state.gender, '');
      expect(state.age, isNull);
      expect(state.weight, isNull);
      expect(state.height, isNull);
      expect(state.contraindications, []);
      expect(state.isSubmitting, isFalse);
      expect(state.error, isNull);
    });

    group('canProceed', () {
      test('step 0: returns false with empty name', () {
        const state = OnboardingState(currentStep: 0, name: '');
        expect(state.canProceed, isFalse);
      });

      test('step 0: returns false with whitespace-only name', () {
        const state = OnboardingState(currentStep: 0, name: '   ');
        expect(state.canProceed, isFalse);
      });

      test('step 0: returns true with valid name', () {
        const state = OnboardingState(currentStep: 0, name: 'Иван');
        expect(state.canProceed, isTrue);
      });

      test('step 1: returns false with empty gender', () {
        const state = OnboardingState(currentStep: 1, gender: '');
        expect(state.canProceed, isFalse);
      });

      test('step 1: returns true with gender set', () {
        const state = OnboardingState(currentStep: 1, gender: 'male');
        expect(state.canProceed, isTrue);
      });

      test('step 2 (age): always returns true', () {
        const state = OnboardingState(currentStep: 2);
        expect(state.canProceed, isTrue);
      });

      test('step 3 (body params): always returns true', () {
        const state = OnboardingState(currentStep: 3);
        expect(state.canProceed, isTrue);
      });

      test('step 4 (contraindications): always returns true', () {
        const state = OnboardingState(currentStep: 4);
        expect(state.canProceed, isTrue);
      });
    });

    group('step navigation', () {
      test('isFirstStep at step 0', () {
        const state = OnboardingState(currentStep: 0);
        expect(state.isFirstStep, isTrue);
      });

      test('isFirstStep at step 1', () {
        const state = OnboardingState(currentStep: 1);
        expect(state.isFirstStep, isFalse);
      });

      test('isLastStep at step 4 (totalSteps=5)', () {
        const state = OnboardingState(currentStep: 4);
        expect(state.isLastStep, isTrue);
      });

      test('isLastStep at step 3', () {
        const state = OnboardingState(currentStep: 3);
        expect(state.isLastStep, isFalse);
      });
    });

    group('progress', () {
      test('at step 0 = 0.2', () {
        const state = OnboardingState(currentStep: 0);
        expect(state.progress, closeTo(0.2, 0.001));
      });

      test('at step 2 = 0.6', () {
        const state = OnboardingState(currentStep: 2);
        expect(state.progress, closeTo(0.6, 0.001));
      });

      test('at step 4 = 1.0', () {
        const state = OnboardingState(currentStep: 4);
        expect(state.progress, closeTo(1.0, 0.001));
      });
    });

    group('copyWith', () {
      test('updates name', () {
        const state = OnboardingState();
        final updated = state.copyWith(name: 'Иван');

        expect(updated.name, 'Иван');
        expect(updated.currentStep, state.currentStep);
      });

      test('updates gender', () {
        const state = OnboardingState();
        final updated = state.copyWith(gender: 'female');

        expect(updated.gender, 'female');
      });

      test('updates step', () {
        const state = OnboardingState();
        final updated = state.copyWith(currentStep: 3);

        expect(updated.currentStep, 3);
      });

      test('updates contraindications', () {
        const state = OnboardingState();
        final updated = state.copyWith(
          contraindications: ['knee_injury', 'back_pain'],
        );

        expect(updated.contraindications, ['knee_injury', 'back_pain']);
      });

      test('error is preserved without explicit override', () {
        const state = OnboardingState(error: 'some error');
        final updated = state.copyWith(name: 'test');

        expect(updated.error, 'some error');
      });
    });
  });
}
