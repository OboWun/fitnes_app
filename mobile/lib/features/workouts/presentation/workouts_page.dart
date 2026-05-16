import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(title: const Text('Тренировки')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
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
