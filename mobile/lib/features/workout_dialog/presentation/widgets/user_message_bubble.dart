import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class UserMessageBubble extends StatelessWidget {
  final String message;

  const UserMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppGradients.progressBarLinear,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Text(
          message,
          style: AppTypography.mediumTextSemiBold.copyWith(
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}
