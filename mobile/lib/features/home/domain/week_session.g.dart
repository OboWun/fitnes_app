// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeekSessionImpl _$$WeekSessionImplFromJson(Map<String, dynamic> json) =>
    _$WeekSessionImpl(
      id: json['id'] as String,
      dayOfWeek: $enumDecode(_$DayOfWeekEnumMap, json['dayOfWeek']),
      date: json['date'] as String?,
      status: json['status'] as String? ?? 'planned',
      sessionType: json['sessionType'] as String?,
      description: json['description'] as String?,
      exerciseCount: (json['exerciseCount'] as num?)?.toInt() ?? 0,
      time: json['time'] as String?,
    );

Map<String, dynamic> _$$WeekSessionImplToJson(_$WeekSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dayOfWeek': _$DayOfWeekEnumMap[instance.dayOfWeek]!,
      'date': instance.date,
      'status': instance.status,
      'sessionType': instance.sessionType,
      'description': instance.description,
      'exerciseCount': instance.exerciseCount,
      'time': instance.time,
    };

const _$DayOfWeekEnumMap = {
  DayOfWeek.monday: 'monday',
  DayOfWeek.tuesday: 'tuesday',
  DayOfWeek.wednesday: 'wednesday',
  DayOfWeek.thursday: 'thursday',
  DayOfWeek.friday: 'friday',
  DayOfWeek.saturday: 'saturday',
  DayOfWeek.sunday: 'sunday',
};
