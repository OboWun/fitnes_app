import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/workout_session_brief.dart';
import 'workout_session_card.dart';

class WorkoutHistorySection extends StatelessWidget {
  final List<WorkoutSessionBrief>? _sessions;
  final ValueChanged<String>? _onSessionTap;
  final VoidCallback? _onViewAll;

  const WorkoutHistorySection({
    super.key,
    required List<WorkoutSessionBrief> sessions,
    ValueChanged<String>? onSessionTap,
    VoidCallback? onViewAll,
  })  : _sessions = sessions,
        _onSessionTap = onSessionTap,
        _onViewAll = onViewAll;

  const WorkoutHistorySection.loading({super.key})
      : _sessions = null,
        _onSessionTap = null,
        _onViewAll = null;

  @override
  Widget build(BuildContext context) {
    if (_sessions == null) return const _WorkoutHistoryLoading();
    return _WorkoutHistoryData(
      sessions: _sessions,
      onSessionTap: _onSessionTap,
      onViewAll: _onViewAll,
    );
  }
}

class _WorkoutHistoryData extends StatelessWidget {
  final List<WorkoutSessionBrief> sessions;
  final ValueChanged<String>? onSessionTap;
  final VoidCallback? onViewAll;

  const _WorkoutHistoryData({
    required this.sessions,
    this.onSessionTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Последние тренировки',
                style: AppTypography.largeTextSemiBold
                    .copyWith(color: AppColors.blackColor),
              ),
            ),
            if (onViewAll != null)
              InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(8),
                child: Text(
                  'Посмотреть все',
                  style: AppTypography.mediumTextMedium.copyWith(
                    color: const Color(0xFF92A3FD),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Тренировок пока нет',
                style: AppTypography.mediumTextRegular
                    .copyWith(color: AppColors.gray2),
              ),
            ),
          )
        else
          ...sessions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: WorkoutSessionCard(
                session: s,
                onTap: onSessionTap != null
                    ? () => onSessionTap!(s.id)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _WorkoutHistoryLoading extends StatelessWidget {
  const _WorkoutHistoryLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Последние тренировки',
          style: AppTypography.largeTextSemiBold
              .copyWith(color: AppColors.blackColor),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < 3; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ShimmerCard(height: 64, borderRadius: BorderRadius.zero),
          ),
      ],
    );
  }
}
