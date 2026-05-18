import 'package:freezed_annotation/freezed_annotation.dart';

part 'equipment_item.freezed.dart';
part 'equipment_item.g.dart';

@Freezed(fromJson: true, toJson: true)
class EquipmentItem with _$EquipmentItem {
  const factory EquipmentItem({
    required String slug,
    required String name,
    String? description,
    String? imageUrl,
  }) = _EquipmentItem;

  factory EquipmentItem.fromJson(Map<String, dynamic> json) =>
      _$EquipmentItemFromJson(json);
}
