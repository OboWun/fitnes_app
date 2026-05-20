import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class NextWorkoutCard extends StatelessWidget {
  final String? _sessionId;
  final String? _dayOfWeek;
  final String? _description;
  final int _exerciseCount;
  final VoidCallback? _onStartTap;

  const NextWorkoutCard({
    super.key,
    required String sessionId,
    required String dayOfWeek,
    String? description,
    int exerciseCount = 0,
    VoidCallback? onStartTap,
  })  : _sessionId = sessionId,
        _dayOfWeek = dayOfWeek,
        _description = description,
        _exerciseCount = exerciseCount,
        _onStartTap = onStartTap;

  const NextWorkoutCard.loading({super.key})
      : _sessionId = null,
        _dayOfWeek = null,
        _description = null,
        _exerciseCount = 0,
        _onStartTap = null;

  @override
  Widget build(BuildContext context) {
    if (_sessionId == null) return const _NextWorkoutLoading();
    return _NextWorkoutData(
      dayOfWeek: _dayOfWeek!,
      description: _description,
      exerciseCount: _exerciseCount,
      onStartTap: _onStartTap,
    );
  }
}

class _NextWorkoutData extends StatelessWidget {
  final String dayOfWeek;
  final String? description;
  final int exerciseCount;
  final VoidCallback? onStartTap;

  const _NextWorkoutData({
    required this.dayOfWeek,
    this.description,
    this.exerciseCount = 0,
    this.onStartTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel = _dayOfWeekLabel(dayOfWeek);
    final title = description != null ? '$dayLabel · $description' : dayLabel;

    return InkWell(
      onTap: onStartTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppGradients.blueLinear,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.whiteColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.largeTextSemiBold.copyWith(
                          color: AppColors.whiteColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Следующая тренировка',
                        style: AppTypography.smallTextMedium.copyWith(
                          color: AppColors.whiteColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(
                  icon: Icons.fitness_center,
                  label: '$exerciseCount упр.',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Начать',
                  style: AppTypography.largeTextSemiBold.copyWith(
                    color: AppGradients.blueLinear.colors.first,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.whiteColor, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.smallTextMedium.copyWith(
              color: AppColors.whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextWorkoutLoading extends StatelessWidget {
  const _NextWorkoutLoading();

  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      height: 180,
      borderRadius: BorderRadius.circular(16),
    );
  }
}

String _dayOfWeekLabel(String day) {
  return switch (day.toLowerCase()) {
    'monday' => 'Понедельник',
    'tuesday' => 'Вторник',
    'wednesday' => 'Среда',
    'thursday' => 'Четверг',
    'friday' => 'Пятница',
    'saturday' => 'Суббота',
    'sunday' => 'Воскресенье',
    _ => day,
  };
}
