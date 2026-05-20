import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class SystemMessageBubble extends StatelessWidget {
  final String message;

  const SystemMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: AppTypography.captionRegular.copyWith(
            color: AppColors.gray2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
