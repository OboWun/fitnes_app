// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutExerciseImpl _$$WorkoutExerciseImplFromJson(
  Map<String, dynamic> json,
) => _$WorkoutExerciseImpl(
  exerciseSlug: json['exerciseSlug'] as String,
  sets: (json['sets'] as num).toInt(),
  reps: (json['reps'] as num?)?.toInt(),
  restBetweenSets: (json['restBetweenSets'] as num?)?.toInt(),
  restAfterExercise: (json['restAfterExercise'] as num?)?.toInt(),
  order: (json['order'] as num).toInt(),
);

Map<String, dynamic> _$$WorkoutExerciseImplToJson(
  _$WorkoutExerciseImpl instance,
) => <String, dynamic>{
  'exerciseSlug': instance.exerciseSlug,
  'sets': instance.sets,
  'reps': instance.reps,
  'restBetweenSets': instance.restBetweenSets,
  'restAfterExercise': instance.restAfterExercise,
  'order': instance.order,
};
