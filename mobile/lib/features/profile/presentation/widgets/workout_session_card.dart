import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/workout_session_brief.dart';

class WorkoutSessionCard extends StatelessWidget {
  final WorkoutSessionBrief session;
  final VoidCallback? onTap;

  const WorkoutSessionCard({
    super.key,
    required this.session,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sessionLabel = _sessionTypeLabel(session.sessionType);

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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppGradients.purpleLinear,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.whiteColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sessionLabel,
                    style: AppTypography.mediumTextSemiBold
                        .copyWith(color: AppColors.blackColor),
                  ),
                  if (session.date != null)
                    Text(
                      session.date!,
                      style: AppTypography.smallTextRegular
                          .copyWith(color: AppColors.gray1),
                    ),
                ],
              ),
            ),
            Text(
              '${session.exerciseCount} упр.',
              style: AppTypography.smallTextMedium
                  .copyWith(color: AppColors.gray2),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: AppColors.gray2,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _sessionTypeLabel(String? type) {
    return switch (type) {
      'push' => 'Грудь + плечи + трицепс',
      'pull' => 'Спина + бицепс',
      'legs' => 'Ноги',
      'upper' => 'Верх тела',
      'lower' => 'Низ тела',
      'full_body' => 'Все тело',
      _ => 'Тренировка',
    };
  }
}
