import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/retry.dart';
import '../domain/complete_set_entry.dart';
import '../domain/workout_session.dart';
import 'workout_session_api.dart';

part 'workout_session_repository.g.dart';

@riverpod
WorkoutSessionRepository workoutSessionRepository(
    WorkoutSessionRepositoryRef ref) {
  return WorkoutSessionRepository(ref.watch(workoutSessionApiProvider));
}

class WorkoutSessionRepository {
  final WorkoutSessionApi _api;

  WorkoutSessionRepository(this._api);

  Future<List<WorkoutSession>> getByPlanSessionId(String planSessionId) async {
    final data = await withRetry(() => _api.getByPlanSessionId(planSessionId));
    return data.map((e) => WorkoutSession.fromJson(e)).toList();
  }

  Future<List<WorkoutSession>> getAll({
    String? status,
    int? limit,
    String? sort,
  }) async {
    final data =
        await withRetry(() => _api.getAll(status: status, limit: limit, sort: sort));
    return data.map((e) => WorkoutSession.fromJson(e)).toList();
  }

  Future<WorkoutSession> getById(String id) async {
    final data = await withRetry(() => _api.getById(id));
    return WorkoutSession.fromJson(data);
  }

  Future<WorkoutSession> create({
    required String planSessionId,
    required String dayOfWeek,
    String? time,
    String? status,
    List<Map<String, dynamic>>? exercises,
    Map<String, dynamic>? metadata,
  }) async {
    final body = <String, dynamic>{
      'planSessionId': planSessionId,
      'dayOfWeek': dayOfWeek,
      if (time != null) 'time': time,
      if (status != null) 'status': status,
      if (exercises != null) 'exercises': exercises,
      if (metadata != null) 'metadata': metadata,
    };
    final data = await withRetry(() => _api.create(body));
    return WorkoutSession.fromJson(data);
  }

  Future<WorkoutSession> complete(
      String id, List<CompleteSetEntry> sets) async {
    final body = <String, dynamic>{
      'sets': sets
          .map((s) => <String, dynamic>{
                'exerciseSlug': s.exerciseSlug,
                'setNumber': s.setNumber,
                if (s.actualWeightKg != null) 'actualWeightKg': s.actualWeightKg,
                if (s.actualReps != null) 'actualReps': s.actualReps,
                if (s.actualDurationSec != null)
                  'actualDurationSec': s.actualDurationSec,
                if (s.actualDistanceM != null)
                  'actualDistanceM': s.actualDistanceM,
                if (s.actualRpe != null) 'actualRpe': s.actualRpe,
              })
          .toList(),
    };
    final data = await withRetry(() => _api.complete(id, body));
    return WorkoutSession.fromJson(data);
  }

  Future<WorkoutSession> skip(String id, {bool reschedule = false}) async {
    final data =
        await withRetry(() => _api.skip(id, reschedule: reschedule));
    return WorkoutSession.fromJson(data);
  }

  Future<void> delete(String id) async {
    await withRetry(() => _api.delete(id));
  }
}
