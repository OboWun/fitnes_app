import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'domain/home_data.dart';
import 'domain/week_session.dart';

part 'home_provider.g.dart';

@Riverpod(keepAlive: true)
class Home extends _$Home {
  @override
  HomeData build() {
    return _mockHomeData();
  }

  void setWeekOffset(int offset) {
    state = state.copyWith();
  }
}

HomeData _mockHomeData() {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final sunday = monday.add(const Duration(days: 6));

  return HomeData(
    activeBlock: const ActiveBlock(
      id: 'block-1',
      name: 'Push Pull Legs',
      type: 'base',
      durationWeeks: 4,
      goal: 'hypertrophy',
      splitName: 'ppl',
      currentWeek: 2,
    ),
    weekSessions: [
      WeekSession(
        id: 's-1',
        dayOfWeek: DayOfWeek.monday,
        date: _fmt(monday),
        sessionType: 'push',
        description: 'Грудь + плечи + трицепс',
        exerciseCount: 6,
        time: '18:00',
      ),
      WeekSession(
        id: 's-2',
        dayOfWeek: DayOfWeek.wednesday,
        date: _fmt(monday.add(const Duration(days: 2))),
        sessionType: 'pull',
        description: 'Спина + бицепс',
        exerciseCount: 5,
        time: '18:00',
      ),
      WeekSession(
        id: 's-3',
        dayOfWeek: DayOfWeek.friday,
        date: _fmt(monday.add(const Duration(days: 4))),
        sessionType: 'legs',
        description: 'Ноги',
        exerciseCount: 6,
        time: '18:00',
      ),
    ],
    weekStart: _fmt(monday),
    weekEnd: _fmt(sunday),
    todaySession: TodaySession(
      id: 's-1',
      sessionType: 'push',
      description: 'Грудь + плечи + трицепс',
      time: '18:00',
      exerciseCount: 6,
    ),
  );
}

String _fmt(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
