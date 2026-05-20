import 'package:freezed_annotation/freezed_annotation.dart';

import 'session_exercise.dart';

part 'workout_session.freezed.dart';
part 'workout_session.g.dart';

@Freezed(fromJson: true, toJson: true)
class WorkoutSession with _$WorkoutSession {
  const WorkoutSession._();

  const factory WorkoutSession({
    required String id,
    required String planSessionId,
    required String userId,
    required String dayOfWeek,
    String? time,
    String? status,
    @Default([]) List<SessionExercise> exercises,
    Map<String, dynamic>? metadata,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);

  String? get sessionDescription {
    final type = metadata?['sessionType'] as String?;
    if (type == null) return null;
    return const {
      'push': 'Грудь + плечи + трицепс',
      'pull': 'Спина + бицепс',
      'legs': 'Ноги',
      'upper': 'Верх тела',
      'lower': 'Низ тела',
      'full_body': 'Все тело',
    }[type] ?? type;
  }
}
