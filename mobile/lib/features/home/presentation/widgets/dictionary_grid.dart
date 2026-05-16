import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class DictionaryGrid extends StatelessWidget {
  final VoidCallback? _onEquipmentTap;
  final VoidCallback? _onMusclesTap;
  final VoidCallback? _onExercisesTap;

  const DictionaryGrid({
    super.key,
    VoidCallback? onEquipmentTap,
    VoidCallback? onMusclesTap,
    VoidCallback? onExercisesTap,
  })  : _onEquipmentTap = onEquipmentTap,
        _onMusclesTap = onMusclesTap,
        _onExercisesTap = onExercisesTap;

  const DictionaryGrid.loading({super.key})
      : _onEquipmentTap = null,
        _onMusclesTap = null,
        _onExercisesTap = null;

  @override
  Widget build(BuildContext context) {
    if (_onEquipmentTap == null &&
        _onMusclesTap == null &&
        _onExercisesTap == null) {
      return const _DictionaryGridLoading();
    }
    return _DictionaryGridData(
      onEquipmentTap: _onEquipmentTap,
      onMusclesTap: _onMusclesTap,
      onExercisesTap: _onExercisesTap,
    );
  }
}

class _DictionaryGridData extends StatelessWidget {
  final VoidCallback? onEquipmentTap;
  final VoidCallback? onMusclesTap;
  final VoidCallback? onExercisesTap;

  const _DictionaryGridData({
    this.onEquipmentTap,
    this.onMusclesTap,
    this.onExercisesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DictionaryCard(
                icon: Icons.fitness_center,
                title: 'Инвентарь',
                gradient: AppGradients.blueLinear,
                onTap: onEquipmentTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DictionaryCard(
                icon: Icons.accessibility_new,
                title: 'Мышцы',
                gradient: AppGradients.purpleLinear,
                onTap: onMusclesTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _DictionaryCard(
            icon: Icons.sports_gymnastics,
            title: 'Упражнения',
            gradient: AppGradients.progressBarLinear,
            onTap: onExercisesTap,
          ),
        ),
      ],
    );
  }
}

class _DictionaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const _DictionaryCard({
    required this.icon,
    required this.title,
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
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: AppTypography.largeTextSemiBold.copyWith(
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.whiteColor.withValues(alpha: 0.7),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DictionaryGridLoading extends StatelessWidget {
  const _DictionaryGridLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ShimmerCard(
                height: 80,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ShimmerCard(
                height: 80,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ShimmerCard(
          height: 80,
          borderRadius: BorderRadius.circular(16),
        ),
      ],
    );
  }
}
