import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_schedule_item.freezed.dart';
part 'plan_schedule_item.g.dart';

@Freezed(fromJson: true, toJson: true)
class PlanScheduleItem with _$PlanScheduleItem {
  const factory PlanScheduleItem({
    required String dayOfWeek,
    required String workoutTemplateId,
    String? time,
    String? name,
    @Default(0) int sortOrder,
  }) = _PlanScheduleItem;

  factory PlanScheduleItem.fromJson(Map<String, dynamic> json) =>
      _$PlanScheduleItemFromJson(json);
}
