// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActiveBlockImpl _$$ActiveBlockImplFromJson(Map<String, dynamic> json) =>
    _$ActiveBlockImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String?,
      durationWeeks: (json['durationWeeks'] as num?)?.toInt(),
      goal: json['goal'] as String?,
      splitName: json['splitName'] as String?,
      currentWeek: (json['currentWeek'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ActiveBlockImplToJson(_$ActiveBlockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'durationWeeks': instance.durationWeeks,
      'goal': instance.goal,
      'splitName': instance.splitName,
      'currentWeek': instance.currentWeek,
    };

_$TodaySessionImpl _$$TodaySessionImplFromJson(Map<String, dynamic> json) =>
    _$TodaySessionImpl(
      id: json['id'] as String,
      sessionType: json['sessionType'] as String?,
      description: json['description'] as String?,
      time: json['time'] as String?,
      exerciseCount: (json['exerciseCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TodaySessionImplToJson(_$TodaySessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionType': instance.sessionType,
      'description': instance.description,
      'time': instance.time,
      'exerciseCount': instance.exerciseCount,
    };

_$HomeDataImpl _$$HomeDataImplFromJson(Map<String, dynamic> json) =>
    _$HomeDataImpl(
      activeBlock: json['activeBlock'] == null
          ? null
          : ActiveBlock.fromJson(json['activeBlock'] as Map<String, dynamic>),
      weekSessions:
          (json['weekSessions'] as List<dynamic>?)
              ?.map((e) => WeekSession.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      weekStart: json['weekStart'] as String?,
      weekEnd: json['weekEnd'] as String?,
      todaySession: json['todaySession'] == null
          ? null
          : TodaySession.fromJson(json['todaySession'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$HomeDataImplToJson(_$HomeDataImpl instance) =>
    <String, dynamic>{
      'activeBlock': instance.activeBlock?.toJson(),
      'weekSessions': instance.weekSessions.map((e) => e.toJson()).toList(),
      'weekStart': instance.weekStart,
      'weekEnd': instance.weekEnd,
      'todaySession': instance.todaySession?.toJson(),
    };
