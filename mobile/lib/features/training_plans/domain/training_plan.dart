import 'package:freezed_annotation/freezed_annotation.dart';

import 'plan_schedule_item.dart';

part 'training_plan.freezed.dart';
part 'training_plan.g.dart';

@Freezed(fromJson: true, toJson: true)
class TrainingPlan with _$TrainingPlan {
  const factory TrainingPlan({
    required String id,
    required String userId,
    required String name,
    @Default(false) bool isActive,
    String? source,
    @Default([]) List<PlanScheduleItem> schedule,
    String? createdAt,
  }) = _TrainingPlan;

  factory TrainingPlan.fromJson(Map<String, dynamic> json) =>
      _$TrainingPlanFromJson(json);
}
