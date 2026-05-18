import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_session_brief.freezed.dart';
part 'workout_session_brief.g.dart';

@Freezed(fromJson: true, toJson: true)
class WorkoutSessionBrief with _$WorkoutSessionBrief {
  const factory WorkoutSessionBrief({
    required String id,
    String? sessionType,
    String? date,
    @Default(0) int exerciseCount,
    String? status,
  }) = _WorkoutSessionBrief;

  factory WorkoutSessionBrief.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionBriefFromJson(json);
}
