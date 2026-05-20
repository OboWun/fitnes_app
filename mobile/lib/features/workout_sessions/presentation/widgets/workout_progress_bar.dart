import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class WorkoutProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const WorkoutProgressBar({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Прогресс',
              style: AppTypography.mediumTextMedium.copyWith(
                color: AppColors.gray1,
              ),
            ),
            Text(
              '$completed/$total',
              style: AppTypography.mediumTextSemiBold.copyWith(
                color: AppColors.blackColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppGradients.progressBarLinear.colors.first,
            ),
          ),
        ),
      ],
    );
  }
}
