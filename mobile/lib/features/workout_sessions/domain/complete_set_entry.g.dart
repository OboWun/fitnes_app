// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_set_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompleteSetEntryImpl _$$CompleteSetEntryImplFromJson(
  Map<String, dynamic> json,
) => _$CompleteSetEntryImpl(
  exerciseSlug: json['exerciseSlug'] as String,
  setNumber: (json['setNumber'] as num).toInt(),
  actualWeightKg: (json['actualWeightKg'] as num?)?.toDouble(),
  actualReps: (json['actualReps'] as num?)?.toInt(),
  actualDurationSec: (json['actualDurationSec'] as num?)?.toInt(),
  actualDistanceM: (json['actualDistanceM'] as num?)?.toDouble(),
  actualRpe: (json['actualRpe'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$CompleteSetEntryImplToJson(
  _$CompleteSetEntryImpl instance,
) => <String, dynamic>{
  'exerciseSlug': instance.exerciseSlug,
  'setNumber': instance.setNumber,
  'actualWeightKg': instance.actualWeightKg,
  'actualReps': instance.actualReps,
  'actualDurationSec': instance.actualDurationSec,
  'actualDistanceM': instance.actualDistanceM,
  'actualRpe': instance.actualRpe,
};
