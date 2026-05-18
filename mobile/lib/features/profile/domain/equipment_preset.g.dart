// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EquipmentDetailImpl _$$EquipmentDetailImplFromJson(
  Map<String, dynamic> json,
) => _$EquipmentDetailImpl(
  slug: json['slug'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$$EquipmentDetailImplToJson(
  _$EquipmentDetailImpl instance,
) => <String, dynamic>{'slug': instance.slug, 'name': instance.name};

_$EquipmentPresetImpl _$$EquipmentPresetImplFromJson(
  Map<String, dynamic> json,
) => _$EquipmentPresetImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String,
  isSystem: json['isSystem'] as bool? ?? false,
  equipmentSlugs:
      (json['equipmentSlugs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  equipmentDetails:
      (json['equipmentDetails'] as List<dynamic>?)
          ?.map((e) => EquipmentDetail.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$$EquipmentPresetImplToJson(
  _$EquipmentPresetImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'isSystem': instance.isSystem,
  'equipmentSlugs': instance.equipmentSlugs,
  'equipmentDetails': instance.equipmentDetails.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
