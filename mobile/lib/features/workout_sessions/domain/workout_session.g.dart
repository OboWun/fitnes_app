// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutSessionImpl _$$WorkoutSessionImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutSessionImpl(
      id: json['id'] as String,
      planSessionId: json['planSessionId'] as String,
      userId: json['userId'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      time: json['time'] as String?,
      status: json['status'] as String?,
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map((e) => SessionExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$WorkoutSessionImplToJson(
  _$WorkoutSessionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'planSessionId': instance.planSessionId,
  'userId': instance.userId,
  'dayOfWeek': instance.dayOfWeek,
  'time': instance.time,
  'status': instance.status,
  'exercises': instance.exercises.map((e) => e.toJson()).toList(),
  'metadata': instance.metadata,
};
