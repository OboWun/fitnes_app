// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_brief.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseBriefImpl _$$ExerciseBriefImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseBriefImpl(
      slug: json['slug'] as String,
      name: json['name'] as String,
      gifUrl: json['gifUrl'] as String?,
      difficulty: json['difficulty'] as String?,
    );

Map<String, dynamic> _$$ExerciseBriefImplToJson(_$ExerciseBriefImpl instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'name': instance.name,
      'gifUrl': instance.gifUrl,
      'difficulty': instance.difficulty,
    };
