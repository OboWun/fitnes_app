import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class TrainerChatCard extends StatelessWidget {
  final VoidCallback? onTap;

  const TrainerChatCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppGradients.purpleLinear,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.blue,
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
              child: const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.whiteColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Общаться с тренером',
                    style: AppTypography.mediumTextSemiBold.copyWith(
                      color: AppColors.whiteColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Подберу план или отвечу на вопросы',
                    style: AppTypography.smallTextRegular.copyWith(
                      color: AppColors.whiteColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.whiteColor.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
