import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class ProgramActionGrid extends StatelessWidget {
  final VoidCallback? _onCoachTap;
  final VoidCallback? _onManualTap;

  const ProgramActionGrid({
    super.key,
    VoidCallback? onCoachTap,
    VoidCallback? onManualTap,
  })  : _onCoachTap = onCoachTap,
        _onManualTap = onManualTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.chat_bubble_outline,
            title: 'С тренером',
            subtitle: 'Подберу план за минуту',
            gradient: AppGradients.purpleLinear,
            onTap: _onCoachTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.edit_note,
            title: 'Собрать вручную',
            subtitle: 'Шаблоны и планы',
            gradient: AppGradients.caloriesLinear,
            onTap: _onManualTap,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.blue,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: -4,
              top: -8,
              bottom: -8,
              child: Icon(
                icon,
                size: 72,
                color: AppColors.whiteColor.withValues(alpha: 0.15),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: AppTypography.largeTextSemiBold.copyWith(
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: AppTypography.smallTextRegular.copyWith(
                      color: AppColors.whiteColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
