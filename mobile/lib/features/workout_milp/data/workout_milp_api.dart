import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'workout_milp_api.g.dart';

@riverpod
WorkoutMilpApi workoutMilpApi(WorkoutMilpApiRef ref) {
  return WorkoutMilpApi(ref.watch(dioProvider));
}

class WorkoutMilpApi {
  final Dio _dio;

  WorkoutMilpApi(this._dio);

  Future<Map<String, dynamic>> generate(Map<String, dynamic> params) async {
    final response = await _dio.post('/workout-milp/generate', data: params);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> weeklyPlan(Map<String, dynamic> params) async {
    final response =
        await _dio.post('/workout-milp/weekly-plan', data: params);
    return response.data as Map<String, dynamic>;
  }
}
