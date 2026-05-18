import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_brief.freezed.dart';
part 'exercise_brief.g.dart';

@Freezed(fromJson: true, toJson: true)
class ExerciseBrief with _$ExerciseBrief {
  const factory ExerciseBrief({
    required String slug,
    required String name,
    String? gifUrl,
    String? difficulty,
  }) = _ExerciseBrief;

  factory ExerciseBrief.fromJson(Map<String, dynamic> json) =>
      _$ExerciseBriefFromJson(json);
}
