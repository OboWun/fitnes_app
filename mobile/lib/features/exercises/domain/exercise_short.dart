import 'package:freezed_annotation/freezed_annotation.dart';

import 'equipment_ref.dart';

part 'exercise_short.freezed.dart';
part 'exercise_short.g.dart';

@Freezed(fromJson: true, toJson: true)
class ExerciseShort with _$ExerciseShort {
  const factory ExerciseShort({
    required String slug,
    required String name,
    String? imageUrl,
    String? description,
    @Default([]) List<EquipmentRef> equipments,
    String? contraindication,
  }) = _ExerciseShort;

  factory ExerciseShort.fromJson(Map<String, dynamic> json) =>
      _$ExerciseShortFromJson(json);
}
