import 'package:freezed_annotation/freezed_annotation.dart';

part 'equipment_ref.freezed.dart';
part 'equipment_ref.g.dart';

@Freezed(fromJson: true, toJson: true)
class EquipmentRef with _$EquipmentRef {
  const factory EquipmentRef({
    required String slug,
    required String name,
    String? description,
    String? imageUrl,
  }) = _EquipmentRef;

  factory EquipmentRef.fromJson(Map<String, dynamic> json) =>
      _$EquipmentRefFromJson(json);
}
