import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/exercise_brief.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseBrief? _exercise;
  final VoidCallback? _onTap;

  const ExerciseCard({
    super.key,
    required ExerciseBrief exercise,
    VoidCallback? onTap,
  })  : _exercise = exercise,
        _onTap = onTap;

  const ExerciseCard.loading({super.key})
      : _exercise = null,
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_exercise == null) return const _ExerciseCardLoading();
    return _ExerciseCardData(exercise: _exercise, onTap: _onTap);
  }
}

class _ExerciseCardData extends StatelessWidget {
  final ExerciseBrief exercise;
  final VoidCallback? onTap;

  const _ExerciseCardData({required this.exercise, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppGradients.purpleLinear,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sports_gymnastics,
                color: AppColors.whiteColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                exercise.name,
                style: AppTypography.mediumTextSemiBold
                    .copyWith(color: AppColors.blackColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.gray2, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCardLoading extends StatelessWidget {
  const _ExerciseCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          ShimmerCard(width: 44, height: 44, borderRadius: BorderRadius.zero),
          SizedBox(width: 12),
          Expanded(child: ShimmerCard(height: 32)),
        ],
      ),
    );
  }
}
