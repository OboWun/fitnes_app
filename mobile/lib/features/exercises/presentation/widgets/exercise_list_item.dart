import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/exercise_short.dart';

class ExerciseListItem extends StatelessWidget {
  final ExerciseShort _exercise;
  final VoidCallback? _onTap;
  final bool _isPickerMode;
  final bool _isSelected;
  final ValueChanged<String>? _onToggleSelect;

  const ExerciseListItem({
    super.key,
    required ExerciseShort exercise,
    VoidCallback? onTap,
    bool isPickerMode = false,
    bool isSelected = false,
    ValueChanged<String>? onToggleSelect,
  })  : _exercise = exercise,
        _onTap = onTap,
        _isPickerMode = isPickerMode,
        _isSelected = isSelected,
        _onToggleSelect = onToggleSelect;

  const ExerciseListItem.loading({super.key})
      : _exercise = const ExerciseShort(slug: '', name: ''),
        _onTap = null,
        _isPickerMode = false,
        _isSelected = false,
        _onToggleSelect = null;

  @override
  Widget build(BuildContext context) {
    if (_exercise.slug.isEmpty) return const _ExerciseListItemLoading();
    return _ExerciseListItemData(
      exercise: _exercise,
      onTap: _onTap,
      isPickerMode: _isPickerMode,
      isSelected: _isSelected,
      onToggleSelect: _onToggleSelect,
    );
  }
}

class _ExerciseListItemData extends StatelessWidget {
  final ExerciseShort exercise;
  final VoidCallback? onTap;
  final bool isPickerMode;
  final bool isSelected;
  final ValueChanged<String>? onToggleSelect;

  const _ExerciseListItemData({
    required this.exercise,
    this.onTap,
    this.isPickerMode = false,
    this.isSelected = false,
    this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isPickerMode
          ? () => onToggleSelect?.call(exercise.slug)
          : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppGradients.blueLinear.colors.first.withValues(alpha: 0.08)
              : AppColors.borderColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (isPickerMode)
              _CheckboxIcon(isSelected: isSelected)
            else
              _ExerciseImage(imageUrl: exercise.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: AppTypography.mediumTextSemiBold.copyWith(
                      color: isSelected
                          ? AppGradients.blueLinear.colors.first
                          : AppColors.blackColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (exercise.equipments.isNotEmpty)
                    Text(
                      exercise.equipments.map((e) => e.name).join(', '),
                      style: AppTypography.smallTextRegular.copyWith(
                        color: AppColors.gray1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (!isPickerMode)
              exercise.contraindication != null
                  ? _ContraindicationBadge(
                      severity: exercise.contraindication!)
                  : Icon(Icons.chevron_right, color: AppColors.gray2),
          ],
        ),
      ),
    );
  }
}

class _CheckboxIcon extends StatelessWidget {
  final bool isSelected;

  const _CheckboxIcon({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected
            ? AppGradients.blueLinear.colors.first.withValues(alpha: 0.15)
            : AppColors.borderColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected
            ? AppGradients.blueLinear.colors.first
            : AppColors.gray2,
        size: 28,
      ),
    );
  }
}

class _ExerciseImage extends StatelessWidget {
  final String? imageUrl;

  const _ExerciseImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
        ),
      );
    }
    return const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.gray3,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.fitness_center, color: AppColors.gray2, size: 24),
    );
  }
}

class _ContraindicationBadge extends StatelessWidget {
  final String severity;

  const _ContraindicationBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = switch (severity) {
      'lowWeight' => const Color(0xFFFFA726),
      'notRecommended' => const Color(0xFFFF7043),
      'forbidden' => AppColors.danger,
      _ => AppColors.gray2,
    };
    return Icon(Icons.warning_amber, color: color, size: 20);
  }
}

class _ExerciseListItemLoading extends StatelessWidget {
  const _ExerciseListItemLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ShimmerCard(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerCard(height: 14, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 4),
                ShimmerCard(
                    width: 100,
                    height: 10,
                    borderRadius: BorderRadius.circular(4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
