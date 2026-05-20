import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../home_provider.dart';
import '../widgets/week_calendar.dart';

class WeekCalendarSmart extends ConsumerStatefulWidget {
  const WeekCalendarSmart({super.key});

  @override
  ConsumerState<WeekCalendarSmart> createState() => _WeekCalendarSmartState();
}

class _WeekCalendarSmartState extends ConsumerState<WeekCalendarSmart> {
  DateTime? _displayWeekStart;

  static const int _maxWeeksForward = 4;

  DateTime get _currentWeekStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - (now.weekday - 1));
  }

  DateTime get _effectiveWeekStart =>
      _displayWeekStart ?? _currentWeekStart;

  bool get _canGoBack => _effectiveWeekStart.isAfter(_currentWeekStart);

  bool get _canGoForward {
    final maxForward =
        _currentWeekStart.add(const Duration(days: 7 * _maxWeeksForward));
    final nextWeek = _effectiveWeekStart.add(const Duration(days: 7));
    return nextWeek.isBefore(maxForward) ||
        nextWeek.isAtSameMomentAs(maxForward);
  }

  String _weekRangeLabel() {
    final start = _effectiveWeekStart;
    final end = start.add(const Duration(days: 6));
    const months = [
      '', 'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
    ];
    return '${start.day} ${months[start.month]} — ${end.day} ${months[end.month]}';
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);

    return homeAsync.when(
      loading: () => const WeekCalendar.loading(),
      error: (_, __) => const WeekCalendar.loading(),
      data: (homeData) {
        if (homeData.weekStart != null && _displayWeekStart == null) {
          _displayWeekStart = _parseDate(homeData.weekStart!);
        }

        return WeekCalendar(
          sessions: homeData.weekSessions,
          weekRangeLabel: _weekRangeLabel(),
          weekStart: _fmtDate(_effectiveWeekStart),
          canGoBack: _canGoBack,
          canGoForward: _canGoForward,
          onSessionTap: (s) => context.push('/workout-session/${s.id}'),
          onBack: _canGoBack
              ? () {
                  setState(() {
                    _displayWeekStart =
                        _effectiveWeekStart.subtract(const Duration(days: 7));
                  });
                  ref
                      .read(homeProvider.notifier)
                      .refresh(weekStart: _fmtDate(_effectiveWeekStart));
                }
              : null,
          onForward: _canGoForward
              ? () {
                  setState(() {
                    _displayWeekStart =
                        _effectiveWeekStart.add(const Duration(days: 7));
                  });
                  ref
                      .read(homeProvider.notifier)
                      .refresh(weekStart: _fmtDate(_effectiveWeekStart));
                }
              : null,
        );
      },
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
}
