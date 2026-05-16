import 'package:freezed_annotation/freezed_annotation.dart';
import 'week_session.dart';

part 'home_data.freezed.dart';
part 'home_data.g.dart';

@Freezed(fromJson: true, toJson: true)
class ActiveBlock with _$ActiveBlock {
  const factory ActiveBlock({
    required String id,
    required String name,
    String? type,
    int? durationWeeks,
    String? goal,
    String? splitName,
    int? currentWeek,
  }) = _ActiveBlock;

  factory ActiveBlock.fromJson(Map<String, dynamic> json) =>
      _$ActiveBlockFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
class TodaySession with _$TodaySession {
  const factory TodaySession({
    required String id,
    String? sessionType,
    String? description,
    String? time,
    @Default(0) int exerciseCount,
  }) = _TodaySession;

  factory TodaySession.fromJson(Map<String, dynamic> json) =>
      _$TodaySessionFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
class HomeData with _$HomeData {
  const factory HomeData({
    ActiveBlock? activeBlock,
    @Default([]) List<WeekSession> weekSessions,
    String? weekStart,
    String? weekEnd,
    TodaySession? todaySession,
  }) = _HomeData;

  factory HomeData.fromJson(Map<String, dynamic> json) =>
      _$HomeDataFromJson(json);
}
