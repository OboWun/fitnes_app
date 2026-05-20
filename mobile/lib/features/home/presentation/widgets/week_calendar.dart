import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/week_session.dart';
import 'day_card.dart';

class WeekCalendar extends StatelessWidget {
  final List<WeekSession>? _sessions;
  final String? _weekRangeLabel;
  final String? _weekStart;
  final bool _canGoBack;
  final bool _canGoForward;
  final VoidCallback? _onBack;
  final VoidCallback? _onForward;
  final ValueChanged<WeekSession>? _onSessionTap;

  const WeekCalendar({
    super.key,
    required List<WeekSession> sessions,
    required String weekRangeLabel,
    required String weekStart,
    bool canGoBack = false,
    bool canGoForward = true,
    VoidCallback? onBack,
    VoidCallback? onForward,
    ValueChanged<WeekSession>? onSessionTap,
  })  : _sessions = sessions,
        _weekRangeLabel = weekRangeLabel,
        _weekStart = weekStart,
        _canGoBack = canGoBack,
        _canGoForward = canGoForward,
        _onBack = onBack,
        _onForward = onForward,
        _onSessionTap = onSessionTap;

  const WeekCalendar.loading({super.key})
      : _sessions = null,
        _weekRangeLabel = null,
        _weekStart = null,
        _canGoBack = false,
        _canGoForward = false,
        _onBack = null,
        _onForward = null,
        _onSessionTap = null;

  @override
  Widget build(BuildContext context) {
    if (_weekRangeLabel == null || _weekStart == null) {
      return const _WeekCalendarLoading();
    }
    return _WeekCalendarData(
      sessions: _sessions ?? [],
      weekRangeLabel: _weekRangeLabel,
      weekStart: _weekStart,
      canGoBack: _canGoBack,
      canGoForward: _canGoForward,
      onBack: _onBack,
      onForward: _onForward,
      onSessionTap: _onSessionTap,
    );
  }
}

class _WeekCalendarData extends StatelessWidget {
  final List<WeekSession> sessions;
  final String weekRangeLabel;
  final String weekStart;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final ValueChanged<WeekSession>? onSessionTap;

  const _WeekCalendarData({
    required this.sessions,
    required this.weekRangeLabel,
    required this.weekStart,
    this.canGoBack = false,
    this.canGoForward = true,
    this.onBack,
    this.onForward,
    this.onSessionTap,
  });

  @override
  Widget build(BuildContext context) {
    final sessionsMap = <int, WeekSession>{};
    for (final s in sessions) {
      sessionsMap[s.dayOfWeek.weekIndex] = s;
    }

    final baseDate = _parseDate(weekStart);
    final today = DateTime.now();
    final todayStr = _fmtDate(today);

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
            final dayDate = baseDate.add(Duration(days: i));
            final dayStr = _fmtDate(dayDate);
            final label = session?.description != null
                ? (session!.description!.length > 6
                    ? '${session.description!.substring(0, 6)}.'
                    : session.description)
                : null;

            final isPastDay = dayStr.compareTo(todayStr) < 0;
            final isNotStartable = isPastDay || (session != null && session.status != 'planned');

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
                child: DayCard(
                  dayName: day.shortName,
                  date: '${dayDate.day}.${dayDate.month}',
                  workoutLabel: label,
                  isToday: dayStr == todayStr,
                  status: session?.status ?? 'planned',
                  onTap: session != null && onSessionTap != null && !isNotStartable
                      ? () => onSessionTap!(session)
                      : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  DateTime _parseDate(String s) {
    final parts = s.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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
