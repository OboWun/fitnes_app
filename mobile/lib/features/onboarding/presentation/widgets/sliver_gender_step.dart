import 'package:flutter/material.dart';

import '../../../../core/widgets/sliver_adapter.dart';
import '../../../../core/widgets/sliver_decorated_box.dart';
import '../../../../design_system/design_system.dart';

class SliverGenderStep extends StatelessWidget {
  final String? value;
  final ValueChanged<String>? onChanged;

  const SliverGenderStep({
    super.key,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverDecoratedBox(
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
      child: SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        sliver: SliverAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Выбери свой пол',
                style:
                    AppTypography.h2Bold.copyWith(color: AppColors.blackColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Это поможет подобрать подходящие упражнения',
                style: AppTypography.smallTextRegular
                    .copyWith(color: AppColors.gray1),
              ),
              const SizedBox(height: 30),
              _GenderOption(
                label: 'Мужской',
                icon: Icons.male,
                isSelected: value == 'male',
                gradient: AppGradients.blueLinear,
                onTap: () => onChanged?.call('male'),
              ),
              const SizedBox(height: 16),
              _GenderOption(
                label: 'Женский',
                icon: Icons.female,
                isSelected: value == 'female',
                gradient: AppGradients.purpleLinear,
                onTap: () => onChanged?.call('female'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
              style: AppTypography.largeTextSemiBold.copyWith(
                color:
                    isSelected ? AppColors.whiteColor : AppColors.blackColor,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.whiteColor, size: 24),
          ],
        ),
      ),
    );
  }
}
