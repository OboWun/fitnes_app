import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_exercise.freezed.dart';
part 'workout_exercise.g.dart';

@Freezed(fromJson: true, toJson: true)
class WorkoutExercise with _$WorkoutExercise {
  const factory WorkoutExercise({
    required String exerciseSlug,
    required int sets,
    int? reps,
    int? restBetweenSets,
    int? restAfterExercise,
    required int order,
  }) = _WorkoutExercise;

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseFromJson(json);
}
