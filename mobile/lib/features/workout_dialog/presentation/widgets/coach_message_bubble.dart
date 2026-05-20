import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class CoachMessageBubble extends StatelessWidget {
  final String message;
  final String? description;

  const CoachMessageBubble({
    super.key,
    required this.message,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: AppGradients.blueLinear,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: AppColors.whiteColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTypography.mediumTextSemiBold.copyWith(
                    color: AppColors.blackColor,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    description!,
                    style: AppTypography.smallTextRegular.copyWith(
                      color: AppColors.gray1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
