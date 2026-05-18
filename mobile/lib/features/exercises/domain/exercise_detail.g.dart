// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MuscleRefImpl _$$MuscleRefImplFromJson(Map<String, dynamic> json) =>
    _$MuscleRefImpl(slug: json['slug'] as String, name: json['name'] as String);

Map<String, dynamic> _$$MuscleRefImplToJson(_$MuscleRefImpl instance) =>
    <String, dynamic>{'slug': instance.slug, 'name': instance.name};

_$BodyPartRefImpl _$$BodyPartRefImplFromJson(Map<String, dynamic> json) =>
    _$BodyPartRefImpl(
      slug: json['slug'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$BodyPartRefImplToJson(_$BodyPartRefImpl instance) =>
    <String, dynamic>{'slug': instance.slug, 'name': instance.name};

_$ContraindicationEntryImpl _$$ContraindicationEntryImplFromJson(
  Map<String, dynamic> json,
) => _$ContraindicationEntryImpl(
  slug: json['slug'] as String,
  name: json['name'] as String?,
  severity: json['severity'] as String,
);

Map<String, dynamic> _$$ContraindicationEntryImplToJson(
  _$ContraindicationEntryImpl instance,
) => <String, dynamic>{
  'slug': instance.slug,
  'name': instance.name,
  'severity': instance.severity,
};

_$ExerciseDetailImpl _$$ExerciseDetailImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseDetailImpl(
      slug: json['slug'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      exerciseType: json['exerciseType'] as String?,
      difficulty: json['difficulty'] as String?,
      movementPattern: json['movementPattern'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      instructions:
          (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      targetMuscles:
          (json['targetMuscles'] as List<dynamic>?)
              ?.map((e) => MuscleRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      secondaryMuscles:
          (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => MuscleRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      bodyParts:
          (json['bodyParts'] as List<dynamic>?)
              ?.map((e) => BodyPartRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      equipments:
          (json['equipments'] as List<dynamic>?)
              ?.map((e) => EquipmentRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      variations:
          (json['variations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      alias:
          (json['alias'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      userContraindications:
          (json['userContraindications'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ContraindicationEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      similarExercises:
          (json['similarExercises'] as List<dynamic>?)
              ?.map((e) => ExerciseShort.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ExerciseDetailImplToJson(
  _$ExerciseDetailImpl instance,
) => <String, dynamic>{
  'slug': instance.slug,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'description': instance.description,
  'exerciseType': instance.exerciseType,
  'difficulty': instance.difficulty,
  'movementPattern': instance.movementPattern,
  'confidence': instance.confidence,
  'instructions': instance.instructions,
  'targetMuscles': instance.targetMuscles.map((e) => e.toJson()).toList(),
  'secondaryMuscles': instance.secondaryMuscles.map((e) => e.toJson()).toList(),
  'bodyParts': instance.bodyParts.map((e) => e.toJson()).toList(),
  'equipments': instance.equipments.map((e) => e.toJson()).toList(),
  'variations': instance.variations,
  'alias': instance.alias,
  'userContraindications': instance.userContraindications
      .map((e) => e.toJson())
      .toList(),
  'similarExercises': instance.similarExercises.map((e) => e.toJson()).toList(),
};
