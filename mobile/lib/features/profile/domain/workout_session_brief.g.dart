// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session_brief.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutSessionBriefImpl _$$WorkoutSessionBriefImplFromJson(
  Map<String, dynamic> json,
) => _$WorkoutSessionBriefImpl(
  id: json['id'] as String,
  sessionType: json['sessionType'] as String?,
  date: json['date'] as String?,
  exerciseCount: (json['exerciseCount'] as num?)?.toInt() ?? 0,
  status: json['status'] as String?,
);

Map<String, dynamic> _$$WorkoutSessionBriefImplToJson(
  _$WorkoutSessionBriefImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionType': instance.sessionType,
  'date': instance.date,
  'exerciseCount': instance.exerciseCount,
  'status': instance.status,
};
