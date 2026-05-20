// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingPlanImpl _$$TrainingPlanImplFromJson(Map<String, dynamic> json) =>
    _$TrainingPlanImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? false,
      source: json['source'] as String?,
      schedule:
          (json['schedule'] as List<dynamic>?)
              ?.map((e) => PlanScheduleItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$$TrainingPlanImplToJson(_$TrainingPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'isActive': instance.isActive,
      'source': instance.source,
      'schedule': instance.schedule.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt,
    };
