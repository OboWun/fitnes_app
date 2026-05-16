import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/home_data.dart';

class WorkoutReminder extends StatelessWidget {
  final TodaySession? _session;
  final VoidCallback? _onTap;

  const WorkoutReminder({
    super.key,
    required TodaySession session,
    VoidCallback? onTap,
  })  : _session = session,
        _onTap = onTap;

  const WorkoutReminder.loading({super.key})
      : _session = null,
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_session == null) return const _WorkoutReminderLoading();
    return _WorkoutReminderData(session: _session, onTap: _onTap);
  }
}

class _WorkoutReminderData extends StatelessWidget {
  final TodaySession session;
  final VoidCallback? onTap;

  const _WorkoutReminderData({required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppGradients.blueLinear,
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
                Icons.fitness_center,
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
                    'Сегодня: ${session.description ?? session.sessionType ?? 'Тренировка'}',
                    style: AppTypography.mediumTextSemiBold.copyWith(
                      color: AppColors.whiteColor,
                    ),
                  ),
                  if (session.time != null)
                    Text(
                      'Время: ${session.time}',
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

class _WorkoutReminderLoading extends StatelessWidget {
  const _WorkoutReminderLoading();

  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      height: 88,
      borderRadius: BorderRadius.circular(16),
    );
  }
}
