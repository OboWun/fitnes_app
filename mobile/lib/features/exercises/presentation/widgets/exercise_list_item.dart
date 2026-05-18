import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/contraindication_severity.dart';
import '../../domain/exercise_short.dart';

class ExerciseListItem extends StatelessWidget {
  final ExerciseShort? _exercise;
  final VoidCallback? _onTap;

  const ExerciseListItem({
    super.key,
    required ExerciseShort exercise,
    VoidCallback? onTap,
  })  : _exercise = exercise,
        _onTap = onTap;

  const ExerciseListItem.loading({super.key})
      : _exercise = null,
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_exercise == null) return const _ExerciseListItemLoading();
    return _ExerciseListItemData(exercise: _exercise!, onTap: _onTap);
  }
}

class _ExerciseListItemData extends StatelessWidget {
  final ExerciseShort exercise;
  final VoidCallback? onTap;

  const _ExerciseListItemData({required this.exercise, this.onTap});

  @override
  Widget build(BuildContext context) {
    final severity =
        ContraindicationSeverity.fromString(exercise.contraindication);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: exercise.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: exercise.imageUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 112,
                        memCacheHeight: 112,
                        filterQuality: FilterQuality.low,
                        placeholder: (_, __) => Container(
                          color: AppColors.gray3,
                          child: const Icon(
                            Icons.fitness_center,
                            color: AppColors.gray2,
                            size: 24,
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.gray3,
                          child: const Icon(
                            Icons.fitness_center,
                            color: AppColors.gray2,
                            size: 24,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.gray3,
                        child: const Icon(
                          Icons.fitness_center,
                          color: AppColors.gray2,
                          size: 24,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: AppTypography.mediumTextSemiBold
                        .copyWith(color: AppColors.blackColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (exercise.equipments.isNotEmpty)
                    Text(
                      exercise.equipments.map((e) => e.name).join(', '),
                      style: AppTypography.smallTextRegular
                          .copyWith(color: AppColors.gray1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (severity != null)
              _ContraindicationBadge(severity: severity)
            else
              const Icon(
                Icons.chevron_right,
                color: AppColors.gray2,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _ContraindicationBadge extends StatelessWidget {
  final ContraindicationSeverity severity;

  const _ContraindicationBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (severity) {
      ContraindicationSeverity.lowWeight => (
          const Color(0xFFFFA726),
          Icons.warning_amber_rounded
        ),
      ContraindicationSeverity.notRecommended => (
          const Color(0xFFFF7043),
          Icons.warning_rounded
        ),
      ContraindicationSeverity.forbidden => (
          const Color(0xFFE53935),
          Icons.block
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    );
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
      child: const Row(
        children: [
          ShimmerCard(width: 56, height: 56, borderRadius: BorderRadius.zero),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerCard(height: 16),
                SizedBox(height: 4),
                ShimmerCard(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
