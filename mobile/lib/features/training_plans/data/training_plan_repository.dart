import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/retry.dart';
import '../domain/plan_schedule_item.dart';
import '../domain/training_plan.dart';
import 'training_plan_api.dart';

part 'training_plan_repository.g.dart';

@riverpod
TrainingPlanRepository trainingPlanRepository(
    TrainingPlanRepositoryRef ref) {
  return TrainingPlanRepository(ref.watch(trainingPlanApiProvider));
}

class TrainingPlanRepository {
  final TrainingPlanApi _api;

  TrainingPlanRepository(this._api);

  Future<List<TrainingPlan>> getAll() async {
    final data = await withRetry(() => _api.getAll());
    return data.map((e) => TrainingPlan.fromJson(e)).toList();
  }

  Future<TrainingPlan> getById(String id) async {
    final data = await withRetry(() => _api.getById(id));
    return TrainingPlan.fromJson(data);
  }

  Future<TrainingPlan> create({
    required String name,
    List<PlanScheduleItem>? schedule,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      if (schedule != null && schedule.isNotEmpty)
        'schedule': schedule
            .map((s) => {
                  'dayOfWeek': s.dayOfWeek,
                  'workoutTemplateId': s.workoutTemplateId,
                  if (s.time != null) 'time': s.time,
                  if (s.name != null) 'name': s.name,
                })
            .toList(),
    };
    final data = await withRetry(() => _api.create(body));
    return TrainingPlan.fromJson(data);
  }

  Future<TrainingPlan> update(
    String id, {
    String? name,
    List<PlanScheduleItem>? schedule,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (schedule != null) {
      body['schedule'] = schedule
          .map((s) => {
                'dayOfWeek': s.dayOfWeek,
                'workoutTemplateId': s.workoutTemplateId,
                if (s.time != null) 'time': s.time,
                if (s.name != null) 'name': s.name,
              })
          .toList();
    }
    final data = await withRetry(() => _api.update(id, body));
    return TrainingPlan.fromJson(data);
  }

  Future<void> delete(String id) async {
    await withRetry(() => _api.delete(id));
  }

  Future<TrainingPlan> activate(String id) async {
    final data = await withRetry(() => _api.activate(id));
    return TrainingPlan.fromJson(data);
  }

  Future<TrainingPlan> archive(String id) async {
    final data = await withRetry(() => _api.archive(id));
    return TrainingPlan.fromJson(data);
  }

  Future<TrainingPlan> assign(
    String planId,
    String dayOfWeek,
    String templateId, {
    String? time,
    String? name,
  }) async {
    final body = <String, dynamic>{
      'dayOfWeek': dayOfWeek,
      'workoutTemplateId': templateId,
      if (time != null) 'time': time,
      if (name != null) 'name': name,
    };
    final data = await withRetry(() => _api.assign(planId, body));
    return TrainingPlan.fromJson(data);
  }

  Future<void> unassign(String planId, String dayOfWeek) async {
    await withRetry(() => _api.unassign(planId, dayOfWeek));
  }
}
