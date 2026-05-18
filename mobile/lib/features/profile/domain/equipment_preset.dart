import 'package:freezed_annotation/freezed_annotation.dart';

part 'equipment_preset.freezed.dart';
part 'equipment_preset.g.dart';

@Freezed(fromJson: true, toJson: true)
class EquipmentDetail with _$EquipmentDetail {
  const factory EquipmentDetail({
    required String slug,
    required String name,
  }) = _EquipmentDetail;

  factory EquipmentDetail.fromJson(Map<String, dynamic> json) =>
      _$EquipmentDetailFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
class EquipmentPreset with _$EquipmentPreset {
  const factory EquipmentPreset({
    required String id,
    required String name,
    required String slug,
    @Default(false) bool isSystem,
    @Default([]) List<String> equipmentSlugs,
    @Default([]) List<EquipmentDetail> equipmentDetails,
    String? createdAt,
    String? updatedAt,
  }) = _EquipmentPreset;

  factory EquipmentPreset.fromJson(Map<String, dynamic> json) =>
      _$EquipmentPresetFromJson(json);
}
