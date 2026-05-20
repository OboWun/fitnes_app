import 'package:freezed_annotation/freezed_annotation.dart';

part 'complete_set_entry.freezed.dart';
part 'complete_set_entry.g.dart';

@Freezed(fromJson: true, toJson: true)
class CompleteSetEntry with _$CompleteSetEntry {
  const factory CompleteSetEntry({
    required String exerciseSlug,
    required int setNumber,
    double? actualWeightKg,
    int? actualReps,
    int? actualDurationSec,
    double? actualDistanceM,
    double? actualRpe,
  }) = _CompleteSetEntry;

  factory CompleteSetEntry.fromJson(Map<String, dynamic> json) =>
      _$CompleteSetEntryFromJson(json);
}
