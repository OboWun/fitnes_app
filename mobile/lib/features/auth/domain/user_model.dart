import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@Freezed(fromJson: true, toJson: true)
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String deviceId,
    String? name,
    int? weight,
    int? height,
    int? age,
    String? gender,
    List<String>? contraindications,
    required String createdAt,
    UserMetadata? metadata,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  bool get isProfileComplete =>
      name != null && name!.isNotEmpty && gender != null && gender!.isNotEmpty;
}

@Freezed(fromJson: true, toJson: true)
class UserMetadata with _$UserMetadata {
  const factory UserMetadata({
    String? goal,
    int? trainingAgeMonths,
    String? experienceLevel,
    int? recoveryCapacity,
    List<String>? availableEquipment,
    List<String>? injuryHistory,
    List<String>? currentLimitations,
    List<String>? preferredExercises,
    List<String>? dislikedExercises,
    List<String>? preferredMovementPatterns,
    String? defaultEquipmentPresetId,
  }) = _UserMetadata;

  factory UserMetadata.fromJson(Map<String, dynamic> json) =>
      _$UserMetadataFromJson(json);
}
