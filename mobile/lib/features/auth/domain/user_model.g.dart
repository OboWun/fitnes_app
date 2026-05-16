// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      name: json['name'] as String?,
      weight: (json['weight'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      contraindications: (json['contraindications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] as String,
      metadata: json['metadata'] == null
          ? null
          : UserMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceId': instance.deviceId,
      'name': instance.name,
      'weight': instance.weight,
      'height': instance.height,
      'age': instance.age,
      'gender': instance.gender,
      'contraindications': instance.contraindications,
      'createdAt': instance.createdAt,
      'metadata': instance.metadata?.toJson(),
    };

_$UserMetadataImpl _$$UserMetadataImplFromJson(Map<String, dynamic> json) =>
    _$UserMetadataImpl(
      goal: json['goal'] as String?,
      trainingAgeMonths: (json['trainingAgeMonths'] as num?)?.toInt(),
      experienceLevel: json['experienceLevel'] as String?,
      recoveryCapacity: (json['recoveryCapacity'] as num?)?.toInt(),
      availableEquipment: (json['availableEquipment'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      injuryHistory: (json['injuryHistory'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      currentLimitations: (json['currentLimitations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      preferredExercises: (json['preferredExercises'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dislikedExercises: (json['dislikedExercises'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      preferredMovementPatterns:
          (json['preferredMovementPatterns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      defaultEquipmentPresetId: json['defaultEquipmentPresetId'] as String?,
    );

Map<String, dynamic> _$$UserMetadataImplToJson(_$UserMetadataImpl instance) =>
    <String, dynamic>{
      'goal': instance.goal,
      'trainingAgeMonths': instance.trainingAgeMonths,
      'experienceLevel': instance.experienceLevel,
      'recoveryCapacity': instance.recoveryCapacity,
      'availableEquipment': instance.availableEquipment,
      'injuryHistory': instance.injuryHistory,
      'currentLimitations': instance.currentLimitations,
      'preferredExercises': instance.preferredExercises,
      'dislikedExercises': instance.dislikedExercises,
      'preferredMovementPatterns': instance.preferredMovementPatterns,
      'defaultEquipmentPresetId': instance.defaultEquipmentPresetId,
    };
