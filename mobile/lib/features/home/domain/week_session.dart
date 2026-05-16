import 'package:freezed_annotation/freezed_annotation.dart';

part 'week_session.freezed.dart';
part 'week_session.g.dart';

enum DayOfWeek {
  @JsonValue('monday')
  monday,
  @JsonValue('tuesday')
  tuesday,
  @JsonValue('wednesday')
  wednesday,
  @JsonValue('thursday')
  thursday,
  @JsonValue('friday')
  friday,
  @JsonValue('saturday')
  saturday,
  @JsonValue('sunday')
  sunday;

  String get shortName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Пн';
      case DayOfWeek.tuesday:
        return 'Вт';
      case DayOfWeek.wednesday:
        return 'Ср';
      case DayOfWeek.thursday:
        return 'Чт';
      case DayOfWeek.friday:
        return 'Пт';
      case DayOfWeek.saturday:
        return 'Сб';
      case DayOfWeek.sunday:
        return 'Вс';
    }
  }

  int get weekIndex => DayOfWeek.values.indexOf(this);
}

@Freezed(fromJson: true, toJson: true)
class WeekSession with _$WeekSession {
  const factory WeekSession({
    required String id,
    required DayOfWeek dayOfWeek,
    String? date,
    @Default('planned') String status,
    String? sessionType,
    String? description,
    @Default(0) int exerciseCount,
    String? time,
  }) = _WeekSession;

  factory WeekSession.fromJson(Map<String, dynamic> json) =>
      _$WeekSessionFromJson(json);
}
