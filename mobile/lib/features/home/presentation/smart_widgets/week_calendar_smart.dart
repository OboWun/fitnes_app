import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home_provider.dart';
import '../widgets/week_calendar.dart';

class WeekCalendarSmart extends ConsumerStatefulWidget {
  const WeekCalendarSmart({super.key});

  @override
  ConsumerState<WeekCalendarSmart> createState() => _WeekCalendarSmartState();
}

class _WeekCalendarSmartState extends ConsumerState<WeekCalendarSmart> {
  late DateTime _currentWeekStart;
  late DateTime _displayWeekStart;

  static const int _maxWeeksForward = 4;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    _displayWeekStart = _currentWeekStart;
  }

  bool get _canGoBack => _displayWeekStart.isAfter(_currentWeekStart);

  bool get _canGoForward {
    final maxForward =
        _currentWeekStart.add(const Duration(days: 7 * _maxWeeksForward));
    final nextWeek = _displayWeekStart.add(const Duration(days: 7));
    return nextWeek.isBefore(maxForward) ||
        nextWeek.isAtSameMomentAs(maxForward);
  }

  String _weekRangeLabel() {
    final end = _displayWeekStart.add(const Duration(days: 6));
    const months = [
      '', 'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
    ];
    return '${_displayWeekStart.day} ${months[_displayWeekStart.month]} — ${end.day} ${months[end.month]}';
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
        final today = DateTime.now();
        final todayStr = _fmtDate(today);

        return WeekCalendar(
          sessions: homeData.weekSessions,
          weekRangeLabel: _weekRangeLabel(),
          todayStr: todayStr,
          canGoBack: _canGoBack,
          canGoForward: _canGoForward,
          onBack: _canGoBack
              ? () {
                  setState(() {
                    _displayWeekStart =
                        _displayWeekStart.subtract(const Duration(days: 7));
                  });
                  ref
                      .read(homeProvider.notifier)
                      .refresh(weekStart: _fmtDate(_displayWeekStart));
                }
              : null,
          onForward: _canGoForward
              ? () {
                  setState(() {
                    _displayWeekStart =
                        _displayWeekStart.add(const Duration(days: 7));
                  });
                  ref
                      .read(homeProvider.notifier)
                      .refresh(weekStart: _fmtDate(_displayWeekStart));
                }
              : null,
        );
      },
    );
  }
}
