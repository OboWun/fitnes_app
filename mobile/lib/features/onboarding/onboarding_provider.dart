import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';

/// Состояние онбординга
class OnboardingState {
  final int currentStep;
  final int totalSteps;
  final String name;
  final String gender;
  final int? age;
  final int? weight;
  final int? height;
  final List<String> contraindications;
  final bool isSubmitting;
  final String? error;

  const OnboardingState({
    this.currentStep = 0,
    this.totalSteps = 5,
    this.name = '',
    this.gender = '',
    this.age,
    this.weight,
    this.height,
    this.contraindications = const [],
    this.isSubmitting = false,
    this.error,
  });

  OnboardingState copyWith({
    int? currentStep,
    String? name,
    String? gender,
    int? age,
    int? weight,
    int? height,
    List<String>? contraindications,
    bool? isSubmitting,
    String? error,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      contraindications: contraindications ?? this.contraindications,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  /// Можно ли перейти к следующему шагу (обязательные поля заполнены)
  bool get canProceed {
    switch (currentStep) {
      case 0: // Имя — обязательно
        return name.trim().isNotEmpty;
      case 1: // Пол — обязательно
        return gender.isNotEmpty;
      case 2: // Возраст — необязательно
        return true;
      case 3: // Вес/Рост — необязательно
        return true;
      case 4: // Противопоказания — необязательно
        return true;
      default:
        return true;
    }
  }

  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == totalSteps - 1;
  double get progress => (currentStep + 1) / totalSteps;
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(const OnboardingState()) {
    _initFromExistingUser();
  }

  /// Если пользователь уже частично заполнен — подставляем данные
  void _initFromExistingUser() {
    final authState = _ref.read(authProvider);
    final user = authState.user;
    if (user != null) {
      state = state.copyWith(
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
      final authNotifier = _ref.read(authProvider.notifier);

      await authNotifier.updateProfile(
        name: state.name,
        gender: state.gender,
        age: state.age,
        weight: state.weight,
        height: state.height,
        contraindications: state.contraindications.isEmpty ? null : state.contraindications,
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
