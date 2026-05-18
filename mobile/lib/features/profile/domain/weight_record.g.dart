// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeightRecordImpl _$$WeightRecordImplFromJson(Map<String, dynamic> json) =>
    _$WeightRecordImpl(
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num).toDouble(),
    );

Map<String, dynamic> _$$WeightRecordImplToJson(_$WeightRecordImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'weight': instance.weight,
    };
