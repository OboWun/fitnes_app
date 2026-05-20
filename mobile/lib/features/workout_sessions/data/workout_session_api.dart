import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'workout_session_api.g.dart';

@riverpod
WorkoutSessionApi workoutSessionApi(WorkoutSessionApiRef ref) {
  return WorkoutSessionApi(ref.watch(dioProvider));
}

class WorkoutSessionApi {
  final Dio _dio;

  WorkoutSessionApi(this._dio);

  Future<List<Map<String, dynamic>>> getByPlanSessionId(
      String planSessionId) async {
    final response =
        await _dio.get('/workout-sessions/plan-session/$planSessionId');
    return (response.data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAll({
    String? status,
    int? limit,
    String? sort,
  }) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    if (limit != null) query['limit'] = limit;
    if (sort != null) query['sort'] = sort;
    final response = await _dio.get('/workout-sessions',
        queryParameters: query.isNotEmpty ? query : null);
    return (response.data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/workout-sessions/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final response = await _dio.post('/workout-sessions', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> complete(
      String id, Map<String, dynamic> body) async {
    final response =
        await _dio.post('/workout-sessions/$id/complete', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> skip(String id,
      {bool? reschedule}) async {
    final body = <String, dynamic>{};
    if (reschedule != null) body['reschedule'] = reschedule;
    final response = await _dio.post('/workout-sessions/$id/skip', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/workout-sessions/$id');
  }
}
