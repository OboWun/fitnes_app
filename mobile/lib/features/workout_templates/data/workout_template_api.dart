import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'workout_template_api.g.dart';

@riverpod
WorkoutTemplateApi workoutTemplateApi(WorkoutTemplateApiRef ref) {
  return WorkoutTemplateApi(ref.watch(dioProvider));
}

class WorkoutTemplateApi {
  final Dio _dio;

  WorkoutTemplateApi(this._dio);

  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _dio.get('/workout-templates');
    return (response.data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/workout-templates/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final response = await _dio.post('/workout-templates', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> body) async {
    final response = await _dio.patch('/workout-templates/$id', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/workout-templates/$id');
  }
}
