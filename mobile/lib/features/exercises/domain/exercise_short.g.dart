// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_short.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseShortImpl _$$ExerciseShortImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseShortImpl(
      slug: json['slug'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      equipments:
          (json['equipments'] as List<dynamic>?)
              ?.map((e) => EquipmentRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      contraindication: json['contraindication'] as String?,
    );

Map<String, dynamic> _$$ExerciseShortImplToJson(_$ExerciseShortImpl instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'equipments': instance.equipments.map((e) => e.toJson()).toList(),
      'contraindication': instance.contraindication,
    };
