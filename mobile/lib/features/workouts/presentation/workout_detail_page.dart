import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';

class WorkoutDetailPage extends StatelessWidget {
  final String workoutId;

  const WorkoutDetailPage({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(title: const Text('Тренировка')),
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
