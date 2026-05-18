// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EquipmentItemImpl _$$EquipmentItemImplFromJson(Map<String, dynamic> json) =>
    _$EquipmentItemImpl(
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$EquipmentItemImplToJson(_$EquipmentItemImpl instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
    };
