import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'exercise_api.g.dart';

@riverpod
ExerciseApi exerciseApi(ExerciseApiRef ref) {
  return ExerciseApi(ref.watch(dioProvider));
}

class ExerciseApi {
  final Dio _dio;

  ExerciseApi(this._dio);

  Future<Map<String, dynamic>> getExercises({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? equipments,
    List<String>? targetMuscles,
    bool isPersonal = true,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'isPersonal': isPersonal,
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (equipments != null && equipments.isNotEmpty) {
      queryParams['equipments'] = equipments.join(',');
    }
    if (targetMuscles != null && targetMuscles.isNotEmpty) {
      queryParams['targetMuscles'] = targetMuscles.join(',');
    }

    final response =
        await _dio.get('/exercises', queryParameters: queryParams);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getExerciseDetail(String slug) async {
    final response = await _dio.get('/exercises/$slug');
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMuscles() async {
    final response = await _dio.get('/muscles');
    final list = response.data as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}
