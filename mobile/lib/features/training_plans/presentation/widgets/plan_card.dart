import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/training_plan.dart';

class PlanCard extends StatelessWidget {
  final TrainingPlan plan;
  final VoidCallback? onTap;

  const PlanCard({super.key, required this.plan, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: plan.isActive ? AppGradients.purpleLinear : null,
          color: plan.isActive ? null : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: plan.isActive ? AppShadows.purple : AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.whiteColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today,
                color:
                    plan.isActive ? AppColors.whiteColor : AppColors.gray2,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: AppTypography.mediumTextSemiBold.copyWith(
                      color: plan.isActive
                          ? AppColors.whiteColor
                          : AppColors.blackColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.isActive
                        ? 'Активный'
                        : '${plan.schedule.length} тренировок в неделю',
                    style: AppTypography.smallTextRegular.copyWith(
                      color: plan.isActive
                          ? AppColors.whiteColor.withValues(alpha: 0.8)
                          : AppColors.gray1,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: plan.isActive
                  ? AppColors.whiteColor.withValues(alpha: 0.7)
                  : AppColors.gray2,
            ),
          ],
        ),
      ),
    );
  }
}
