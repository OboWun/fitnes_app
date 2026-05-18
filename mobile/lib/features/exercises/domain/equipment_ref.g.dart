// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EquipmentRefImpl _$$EquipmentRefImplFromJson(Map<String, dynamic> json) =>
    _$EquipmentRefImpl(
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$EquipmentRefImplToJson(_$EquipmentRefImpl instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
    };
