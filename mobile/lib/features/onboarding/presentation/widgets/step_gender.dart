import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../onboarding_provider.dart';

class StepGender extends ConsumerWidget {
  const StepGender({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGender = ref.watch(onboardingProvider.select((s) => s.gender));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Выбери свой пол',
          style: AppTypography.h2Bold().copyWith(
            color: AppColors.blackColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Это поможет подобрать подходящие упражнения',
          style: AppTypography.smallTextRegular().copyWith(
            color: AppColors.gray1,
          ),
        ),
        const SizedBox(height: 30),
        _GenderOption(
          label: 'Мужской',
          icon: Icons.male,
          isSelected: selectedGender == 'male',
          gradient: AppGradients.blueLinear,
          onTap: () => ref.read(onboardingProvider.notifier).setGender('male'),
        ),
        const SizedBox(height: 16),
        _GenderOption(
          label: 'Женский',
          icon: Icons.female,
          isSelected: selectedGender == 'female',
          gradient: AppGradients.purpleLinear,
          onTap: () => ref.read(onboardingProvider.notifier).setGender('female'),
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : AppColors.borderColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? AppShadows.card : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.whiteColor : AppColors.gray2,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTypography.largeTextSemiBold().copyWith(
                color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.whiteColor, size: 24),
          ],
        ),
      ),
    );
  }
}
