import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';

class MusclesPage extends StatelessWidget {
  const MusclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(title: const Text('Мышцы')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.accessibility_new,
              size: 64,
              color: AppColors.gray2,
            ),
            const SizedBox(height: 16),
            Text(
              'В разработке',
              style: AppTypography.largeTextMedium.copyWith(
                color: AppColors.gray2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
