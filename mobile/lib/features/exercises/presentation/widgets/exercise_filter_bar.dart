import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/exercise_filter.dart';

class ExerciseFilterBar extends StatelessWidget {
  final ExerciseFilter value;
  final ValueChanged<ExerciseFilter>? onChanged;
  final VoidCallback? onFilterTap;
  final Map<String, String> equipmentNames;
  final Map<String, String> muscleNames;

  const ExerciseFilterBar({
    super.key,
    required this.value,
    this.onChanged,
    this.onFilterTap,
    this.equipmentNames = const {},
    this.muscleNames = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChip(
          label: 'Фильтры',
          icon: Icons.tune,
          isSelected: value.hasActiveFilters,
          onTap: onFilterTap,
        ),
        if (value.presetName != null)
          _RemovableChip(
            label: value.presetName!,
            onRemove: () {
              onChanged?.call(
                value.copyWith(equipments: []).copyWithClearPreset(),
              );
            },
          ),
        ...value.equipments.where((slug) {
          if (value.presetId != null) return false;
          return true;
        }).map(
          (slug) => _RemovableChip(
            label: equipmentNames[slug] ?? slug,
            onRemove: () {
              onChanged?.call(value.copyWith(
                equipments: value.equipments
                    .where((e) => e != slug)
                    .toList(),
              ));
            },
          ),
        ),
        ...value.targetMuscles.map(
          (slug) => _RemovableChip(
            label: muscleNames[slug] ?? slug,
            onRemove: () {
              onChanged?.call(value.copyWith(
                targetMuscles: value.targetMuscles
                    .where((e) => e != slug)
                    .toList(),
              ));
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.blueLinear : null,
          color: isSelected ? null : AppColors.borderColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? AppColors.whiteColor : AppColors.gray1),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.smallTextMedium.copyWith(
                color: isSelected ? AppColors.whiteColor : AppColors.gray1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;

  const _RemovableChip({required this.label, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.smallTextMedium
                .copyWith(color: AppColors.gray1),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child:
                const Icon(Icons.close, size: 14, color: AppColors.gray2),
          ),
        ],
      ),
    );
  }
}
