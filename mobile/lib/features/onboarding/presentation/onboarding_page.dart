import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../onboarding_provider.dart';
import 'widgets/step_age.dart';
import 'widgets/step_body_params.dart';
import 'widgets/step_contraindications.dart';
import 'widgets/step_gender.dart';
import 'widgets/step_name.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Карти��ки для каждого шага (циклически по profile_1..5)
  String _imageForStep(int step) {
    final imageStep = (step % 5) + 1;
    return 'assets/images/profile_$imageStep.png';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    ref.listen<OnboardingState>(onboardingProvider, (prev, next) {
      if (prev?.currentStep != next.currentStep) {
        _pageController.animateToPage(
          next.currentStep,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // Image section
            Expanded(
              flex: 4,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Image.asset(
                  _imageForStep(state.currentStep),
                  key: ValueKey(state.currentStep),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    // Если картинка не найдена — показываем заглушку с градиентом
                    return Container(
                      margin: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        gradient: AppGradients.blueLinear,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Icon(
                          _iconForStep(state.currentStep),
                          size: 80,
                          color: AppColors.whiteColor.withValues(alpha: 0.8),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Content section
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                decoration: const BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Progress indicator
                    _ProgressDots(
                      current: state.currentStep,
                      total: state.totalSteps,
                    ),
                    const SizedBox(height: 20),

                    // Step content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          StepName(),
                          StepGender(),
                          StepAge(),
                          StepBodyParams(),
                          StepContraindications(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Navigation buttons
                    _NavigationButtons(
                      state: state,
                      onBack: () => ref.read(onboardingProvider.notifier).previousStep(),
                      onNext: () => ref.read(onboardingProvider.notifier).nextStep(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForStep(int step) {
    switch (step) {
      case 0:
        return Icons.person_outline;
      case 1:
        return Icons.wc_outlined;
      case 2:
        return Icons.cake_outlined;
      case 3:
        return Icons.straighten_outlined;
      case 4:
        return Icons.health_and_safety_outlined;
      default:
        return Icons.fitness_center;
    }
  }
}

class _ProgressDots extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == current;
        final isPassed = index < current;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: isActive || isPassed ? AppGradients.blueLinear : null,
            color: (isActive || isPassed) ? null : AppColors.gray3,
          ),
        );
      }),
    );
  }
}

class _NavigationButtons extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _NavigationButtons({
    required this.state,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Кнопка назад
        if (!state.isFirstStep)
          Expanded(
            child: TextButton(
              onPressed: onBack,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back_ios, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Назад',
                    style: AppTypography.largeTextMedium().copyWith(
                      color: AppColors.gray1,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          const Spacer(),

        const SizedBox(width: 16),

        // Кнопка далее / завершить
        Expanded(
          flex: 2,
          child: _GradientButton(
            onPressed: state.canProceed ? onNext : null,
            isLoading: state.isSubmitting,
            label: state.isLastStep ? 'Завершить' : 'Далее',
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  const _GradientButton({
    required this.onPressed,
    required this.isLoading,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isEnabled ? AppGradients.blueLinear : null,
          color: isEnabled ? null : AppColors.gray3,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled ? AppShadows.blue : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.whiteColor,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: AppTypography.largeTextSemiBold().copyWith(
                        color: isEnabled ? AppColors.whiteColor : AppColors.gray2,
                      ),
                    ),
                    if (label != 'Завершить') ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: isEnabled ? AppColors.whiteColor : AppColors.gray2,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
