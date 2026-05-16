import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/sliver_gap.dart';
import '../../../design_system/design_system.dart';
import '../domain/onboarding_state.dart';
import '../onboarding_provider.dart';
import 'smart_widgets/sliver_age_step_smart.dart';
import 'smart_widgets/sliver_body_params_step_smart.dart';
import 'smart_widgets/sliver_contraindications_step_smart.dart';
import 'smart_widgets/sliver_gender_step_smart.dart';
import 'smart_widgets/sliver_name_step_smart.dart';

part '_progress_dots.dart';
part '_navigation_buttons.dart';
part '_gradient_button.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  double get _expandedHeight => MediaQuery.sizeOf(context).height * 0.38;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    ref.listen<OnboardingState>(onboardingProvider, (prev, next) {
      if (prev != null && prev.currentStep != next.currentStep) {
        PrimaryScrollController.of(context).animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _NavigationButtons(
        state: state,
        onBack: () =>
            ref.read(onboardingProvider.notifier).previousStep(),
        onNext: () =>
            ref.read(onboardingProvider.notifier).nextStep(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: _expandedHeight,
            collapsedHeight: 60,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const SizedBox.shrink(),
            flexibleSpace: _StepFlexibleSpace(
              currentStep: state.currentStep,
              totalSteps: state.totalSteps,
              expandedHeight: _expandedHeight,
            ),
            
          ),
          SliverPadding(
             padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            sliver: PinnedHeaderSliver(
              child: SizedBox(
                height: 32,
                child: _ProgressDots(
                  current: state.currentStep,
                  total: state.totalSteps,
                ),
              ),
            ),
          ),
          switch (state.currentStep) {
            0 => const SliverNameStepSmart(),
            1 => const SliverGenderStepSmart(),
            2 => const SliverAgeStepSmart(),
            3 => const SliverBodyParamsStepSmart(),
            4 => const SliverContraindicationsStepSmart(),
            _ => const SliverGap(vertical: 0),
          },
        ],
      ),
    );
  }
}

class _StepFlexibleSpace extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double expandedHeight;

  const _StepFlexibleSpace({
    required this.currentStep,
    required this.totalSteps,
    required this.expandedHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final t = ((constraints.maxHeight - 60) /
                (expandedHeight - 60))
            .clamp(0.0, 1.0);

        final isSmall = t < 0.6;
        return Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.blueLinear,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32), )
          ),
          child:  AnimatedSwitcher(
           
            duration: Durations.short3, child: Builder( key: ValueKey('$isSmall$currentStep'), builder: (_) {
            if(isSmall) {
              return Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _iconForStep(currentStep),
                          size: 28,
                          color: AppColors.whiteColor,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Шаг ${currentStep + 1} из $totalSteps',
                          style: AppTypography.mediumTextSemiBold
                              .copyWith(color: AppColors.whiteColor),
                        ),
                      ],
                    ),
                  );
            }
            return  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Image.asset(
                      _imageForStep(currentStep),
                      key: ValueKey(currentStep),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          _StepFallbackIcon(step: currentStep),
                    ),
                  );
          },),),
          
        
        );
      },
    );
  }

  String _imageForStep(int step) {
    final imageStep = (step % 5) + 1;
    return 'assets/images/profile_$imageStep.png';
  }

  IconData _iconForStep(int step) {
    return switch (step) {
      0 => Icons.person_outline,
      1 => Icons.wc_outlined,
      2 => Icons.cake_outlined,
      3 => Icons.straighten_outlined,
      4 => Icons.health_and_safety_outlined,
      _ => Icons.fitness_center,
    };
  }
}

class _StepFallbackIcon extends StatelessWidget {
  final int step;

  const _StepFallbackIcon({required this.step});

  @override
  Widget build(BuildContext context) {
    final icon = switch (step) {
      0 => Icons.person_outline,
      1 => Icons.wc_outlined,
      2 => Icons.cake_outlined,
      3 => Icons.straighten_outlined,
      4 => Icons.health_and_safety_outlined,
      _ => Icons.fitness_center,
    };

    return Container(
      margin: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 80,
          color: AppColors.whiteColor.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
