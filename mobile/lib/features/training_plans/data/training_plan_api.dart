import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'training_plan_api.g.dart';

@riverpod
TrainingPlanApi trainingPlanApi(TrainingPlanApiRef ref) {
  return TrainingPlanApi(ref.watch(dioProvider));
}

class TrainingPlanApi {
  final Dio _dio;

  TrainingPlanApi(this._dio);

  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _dio.get('/training-plans');
    return (response.data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/training-plans/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final response = await _dio.post('/training-plans', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> body) async {
    final response = await _dio.patch('/training-plans/$id', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/training-plans/$id');
  }

  Future<Map<String, dynamic>> activate(String id) async {
    final response = await _dio.post('/training-plans/$id/activate');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> archive(String id) async {
    final response = await _dio.post('/training-plans/$id/archive');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> assign(
      String id, Map<String, dynamic> body) async {
    final response =
        await _dio.post('/training-plans/$id/assign', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<void> unassign(String id, String dayOfWeek) async {
    await _dio.delete('/training-plans/$id/assign/$dayOfWeek');
  }
}
