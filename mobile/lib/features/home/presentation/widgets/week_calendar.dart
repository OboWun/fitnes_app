import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/week_session.dart';
import 'day_card.dart';

class WeekCalendar extends StatelessWidget {
  final List<WeekSession>? _sessions;
  final String? _weekRangeLabel;
  final String? _todayStr;
  final bool _canGoBack;
  final bool _canGoForward;
  final VoidCallback? _onBack;
  final VoidCallback? _onForward;

  const WeekCalendar({
    super.key,
    required List<WeekSession> sessions,
    required String weekRangeLabel,
    required String todayStr,
    bool canGoBack = false,
    bool canGoForward = true,
    VoidCallback? onBack,
    VoidCallback? onForward,
  })  : _sessions = sessions,
        _weekRangeLabel = weekRangeLabel,
        _todayStr = todayStr,
        _canGoBack = canGoBack,
        _canGoForward = canGoForward,
        _onBack = onBack,
        _onForward = onForward;

  const WeekCalendar.loading({super.key})
      : _sessions = null,
        _weekRangeLabel = null,
        _todayStr = null,
        _canGoBack = false,
        _canGoForward = false,
        _onBack = null,
        _onForward = null;

  @override
  Widget build(BuildContext context) {
    if (_sessions == null || _weekRangeLabel == null || _todayStr == null) {
      return const _WeekCalendarLoading();
    }
    return _WeekCalendarData(
      sessions: _sessions,
      weekRangeLabel: _weekRangeLabel,
      todayStr: _todayStr,
      canGoBack: _canGoBack,
      canGoForward: _canGoForward,
      onBack: _onBack,
      onForward: _onForward,
    );
  }
}

class _WeekCalendarData extends StatelessWidget {
  final List<WeekSession> sessions;
  final String weekRangeLabel;
  final String todayStr;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback? onBack;
  final VoidCallback? onForward;

  const _WeekCalendarData({
    required this.sessions,
    required this.weekRangeLabel,
    required this.todayStr,
    this.canGoBack = false,
    this.canGoForward = true,
    this.onBack,
    this.onForward,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const _WeekCalendarPlaceholder();

    final sessionsMap = <int, WeekSession>{};
    for (final s in sessions) {
      sessionsMap[s.dayOfWeek.weekIndex] = s;
    }

    final today = DateTime.now();
    final todayDateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: canGoBack ? onBack : null,
              icon: Icon(
                Icons.chevron_left,
                color: canGoBack ? AppColors.blackColor : AppColors.gray3,
              ),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Expanded(
              child: Text(
                weekRangeLabel,
                textAlign: TextAlign.center,
                style: AppTypography.mediumTextMedium.copyWith(
                  color: AppColors.gray1,
                ),
              ),
            ),
            IconButton(
              onPressed: canGoForward ? onForward : null,
              icon: Icon(
                Icons.chevron_right,
                color: canGoForward ? AppColors.blackColor : AppColors.gray3,
              ),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(7, (i) {
            final day = DayOfWeek.values[i];
            final session = sessionsMap[i];
            final label = session?.description != null
                ? (session!.description!.length > 6
                    ? '${session.description!.substring(0, 6)}.'
                    : session.description)
                : null;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
                child: DayCard(
                  dayName: day.shortName,
                  date: _dayDate(todayDateStr, i),
                  workoutLabel: label,
                  isToday: todayDateStr == todayStr && i == today.weekday - 1,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _dayDate(String todayStr, int dayIndex) {
    final parts = todayStr.split('-');
    final base = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final date = base.add(Duration(days: dayIndex));
    return '${date.day}.${date.month}';
  }
}

class _WeekCalendarPlaceholder extends StatelessWidget {
  const _WeekCalendarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 40,
            color: AppColors.gray2,
          ),
          const SizedBox(height: 12),
          Text(
            'Программа ещё не создана',
            style: AppTypography.mediumTextMedium.copyWith(
              color: AppColors.gray2,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekCalendarLoading extends StatelessWidget {
  const _WeekCalendarLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShimmerCard(
          height: 20,
          width: 180,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            7,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
                child: const DayCard.loading(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
