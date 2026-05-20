// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_schedule_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanScheduleItemImpl _$$PlanScheduleItemImplFromJson(
  Map<String, dynamic> json,
) => _$PlanScheduleItemImpl(
  dayOfWeek: json['dayOfWeek'] as String,
  workoutTemplateId: json['workoutTemplateId'] as String,
  time: json['time'] as String?,
  name: json['name'] as String?,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$PlanScheduleItemImplToJson(
  _$PlanScheduleItemImpl instance,
) => <String, dynamic>{
  'dayOfWeek': instance.dayOfWeek,
  'workoutTemplateId': instance.workoutTemplateId,
  'time': instance.time,
  'name': instance.name,
  'sortOrder': instance.sortOrder,
};
