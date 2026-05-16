import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const OnboardingState._();

  const factory OnboardingState({
    @Default(0) int currentStep,
    @Default(5) int totalSteps,
    @Default('') String name,
    @Default('') String gender,
    int? age,
    int? weight,
    int? height,
    @Default([]) List<String> contraindications,
    @Default(false) bool isSubmitting,
    String? error,
  }) = _OnboardingState;

  bool get canProceed {
    switch (currentStep) {
      case 0:
        return name.trim().isNotEmpty;
      case 1:
        return gender.isNotEmpty;
      case 2:
      case 3:
      case 4:
        return true;
      default:
        return true;
    }
  }

  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == totalSteps - 1;
  double get progress => (currentStep + 1) / totalSteps;
}
