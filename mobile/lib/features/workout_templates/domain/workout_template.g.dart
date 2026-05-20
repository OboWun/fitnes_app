// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutTemplateImpl _$$WorkoutTemplateImplFromJson(
  Map<String, dynamic> json,
) => _$WorkoutTemplateImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  exercises:
      (json['exercises'] as List<dynamic>?)
          ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$$WorkoutTemplateImplToJson(
  _$WorkoutTemplateImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'description': instance.description,
  'exercises': instance.exercises.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
