import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/exercise_brief.dart';
import 'exercise_card.dart';

class ExerciseSection extends StatelessWidget {
  final List<ExerciseBrief>? _exercises;
  final VoidCallback? _onViewAll;
  final ValueChanged<ExerciseBrief>? _onExerciseTap;

  const ExerciseSection({
    super.key,
    required List<ExerciseBrief> exercises,
    VoidCallback? onViewAll,
    ValueChanged<ExerciseBrief>? onExerciseTap,
  })  : _exercises = exercises,
        _onViewAll = onViewAll,
        _onExerciseTap = onExerciseTap;

  const ExerciseSection.loading({super.key})
      : _exercises = null,
        _onViewAll = null,
        _onExerciseTap = null;

  @override
  Widget build(BuildContext context) {
    if (_exercises == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Используется в упражнениях',
            style: AppTypography.largeTextSemiBold
                .copyWith(color: AppColors.blackColor),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < 3; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: ExerciseCard.loading(),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Используется в упражнениях',
                style: AppTypography.largeTextSemiBold
                    .copyWith(color: AppColors.blackColor),
              ),
            ),
            if (_onViewAll != null)
              InkWell(
                onTap: _onViewAll,
                borderRadius: BorderRadius.circular(8),
                child: Text(
                  'Посмотреть все',
                  style: AppTypography.mediumTextMedium.copyWith(
                    color: const Color(0xFF92A3FD),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_exercises.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Упражнений пока нет',
                style: AppTypography.mediumTextRegular
                    .copyWith(color: AppColors.gray2),
              ),
            ),
          )
        else
          ..._exercises.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ExerciseCard(
                exercise: e,
                onTap: _onExerciseTap != null
                    ? () => _onExerciseTap(e)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
