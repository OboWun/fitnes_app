import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/workout_set.dart';
import 'set_row.dart';

class ExerciseBlock extends StatelessWidget {
  final String exerciseName;
  final List<WorkoutSet> sets;
  final ValueChanged<WorkoutSet>? onSetChanged;

  const ExerciseBlock({
    super.key,
    required this.exerciseName,
    required this.sets,
    this.onSetChanged,
  });

  const ExerciseBlock.loading({super.key})
      : exerciseName = '',
        sets = const [],
        onSetChanged = null;

  @override
  Widget build(BuildContext context) {
    if (exerciseName.isEmpty) return const _ExerciseBlockLoading();
    return _ExerciseBlockData(
      exerciseName: exerciseName,
      sets: sets,
      onSetChanged: onSetChanged,
    );
  }
}

class _ExerciseBlockData extends StatelessWidget {
  final String exerciseName;
  final List<WorkoutSet> sets;
  final ValueChanged<WorkoutSet>? onSetChanged;

  const _ExerciseBlockData({
    required this.exerciseName,
    required this.sets,
    this.onSetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppGradients.blueLinear,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppColors.whiteColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  exerciseName,
                  style: AppTypography.largeTextSemiBold.copyWith(
                    color: AppColors.blackColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${sets.length}',
                style: AppTypography.mediumTextMedium.copyWith(
                  color: AppColors.gray2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            spacing: 8,
            children: [
              for (final s in sets)
                SetRow(value: s, onChanged: onSetChanged),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseBlockLoading extends StatelessWidget {
  const _ExerciseBlockLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerCard(
                width: 36,
                height: 36,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 10),
              const ShimmerCard(width: 120, height: 16),
            ],
          ),
          const SizedBox(height: 12),
          const ShimmerCard(height: 48),
          const SizedBox(height: 8),
          const ShimmerCard(height: 48),
        ],
      ),
    );
  }
}
