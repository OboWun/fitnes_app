import 'package:freezed_annotation/freezed_annotation.dart';

import 'workout_exercise.dart';

part 'workout_template.freezed.dart';
part 'workout_template.g.dart';

@Freezed(fromJson: true, toJson: true)
class WorkoutTemplate with _$WorkoutTemplate {
  const factory WorkoutTemplate({
    required String id,
    required String userId,
    required String name,
    String? description,
    @Default([]) List<WorkoutExercise> exercises,
    String? createdAt,
    String? updatedAt,
  }) = _WorkoutTemplate;

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) =>
      _$WorkoutTemplateFromJson(json);
}
