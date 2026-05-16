import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/public.dart';
import 'domain/onboarding_state.dart';

part 'onboarding_provider.g.dart';

@riverpod
class Onboarding extends _$Onboarding {
  @override
  OnboardingState build() {
    _initFromExistingUser();
    return const OnboardingState();
  }

  void _initFromExistingUser() {
    final authState = ref.read(authProvider);
    final user = authState.user;
    if (user != null) {
      state = OnboardingState(
        name: user.name ?? '',
        gender: user.gender ?? '',
        age: user.age,
        weight: user.weight,
        height: user.height,
        contraindications: user.contraindications ?? [],
      );
    }
  }

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setGender(String value) {
    state = state.copyWith(gender: value);
  }

  void setAge(int? value) {
    state = state.copyWith(age: value);
  }

  void setWeight(int? value) {
    state = state.copyWith(weight: value);
  }

  void setHeight(int? value) {
    state = state.copyWith(height: value);
  }

  void setContraindications(List<String> value) {
    state = state.copyWith(contraindications: value);
  }

  void toggleContraindication(String slug) {
    final list = List<String>.from(state.contraindications);
    if (list.contains(slug)) {
      list.remove(slug);
    } else {
      list.add(slug);
    }
    state = state.copyWith(contraindications: list);
  }

  void nextStep() {
    if (!state.canProceed) return;
    if (state.isLastStep) {
      _submit();
      return;
    }
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.isFirstStep) return;
    state = state.copyWith(currentStep: state.currentStep - 1);
  }

  void goToStep(int step) {
    if (step >= 0 && step < state.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  Future<void> _submit() async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final authNotifier = ref.read(authProvider.notifier);

      await authNotifier.updateProfile(
        name: state.name,
        gender: state.gender,
        age: state.age,
        weight: state.weight,
        height: state.height,
        contraindications:
            state.contraindications.isEmpty ? null : state.contraindications,
      );

      authNotifier.completeOnboarding();
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }
}
