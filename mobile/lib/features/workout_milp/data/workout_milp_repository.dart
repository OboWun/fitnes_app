import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/retry.dart';
import 'workout_milp_api.dart';

part 'workout_milp_repository.g.dart';

@riverpod
WorkoutMilpRepository workoutMilpRepository(WorkoutMilpRepositoryRef ref) {
  return WorkoutMilpRepository(ref.watch(workoutMilpApiProvider));
}

class WorkoutMilpRepository {
  final WorkoutMilpApi _api;

  WorkoutMilpRepository(this._api);

  Future<Map<String, dynamic>> generate(Map<String, dynamic> params) async {
    return withRetry(() => _api.generate(params));
  }

  Future<Map<String, dynamic>> weeklyPlan(Map<String, dynamic> params) async {
    return withRetry(() => _api.weeklyPlan(params));
  }
}
