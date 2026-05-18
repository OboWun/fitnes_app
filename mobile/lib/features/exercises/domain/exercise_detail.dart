import 'package:freezed_annotation/freezed_annotation.dart';

import 'equipment_ref.dart';
import 'exercise_short.dart';

part 'exercise_detail.freezed.dart';
part 'exercise_detail.g.dart';

@Freezed(fromJson: true, toJson: true)
class MuscleRef with _$MuscleRef {
  const factory MuscleRef({
    required String slug,
    required String name,
  }) = _MuscleRef;

  factory MuscleRef.fromJson(Map<String, dynamic> json) =>
      _$MuscleRefFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
class BodyPartRef with _$BodyPartRef {
  const factory BodyPartRef({
    required String slug,
    required String name,
  }) = _BodyPartRef;

  factory BodyPartRef.fromJson(Map<String, dynamic> json) =>
      _$BodyPartRefFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
class ContraindicationEntry with _$ContraindicationEntry {
  const factory ContraindicationEntry({
    required String slug,
    String? name,
    required String severity,
  }) = _ContraindicationEntry;

  factory ContraindicationEntry.fromJson(Map<String, dynamic> json) =>
      _$ContraindicationEntryFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
class ExerciseDetail with _$ExerciseDetail {
  const factory ExerciseDetail({
    required String slug,
    required String name,
    String? imageUrl,
    String? description,
    String? exerciseType,
    String? difficulty,
    String? movementPattern,
    double? confidence,
    @Default([]) List<String> instructions,
    @Default([]) List<MuscleRef> targetMuscles,
    @Default([]) List<MuscleRef> secondaryMuscles,
    @Default([]) List<BodyPartRef> bodyParts,
    @Default([]) List<EquipmentRef> equipments,
    @Default([]) List<String> variations,
    @Default([]) List<String> alias,
    @Default([]) List<ContraindicationEntry> userContraindications,
    @Default([]) List<ExerciseShort> similarExercises,
  }) = _ExerciseDetail;

  factory ExerciseDetail.fromJson(Map<String, dynamic> json) =>
      _$ExerciseDetailFromJson(json);
}
