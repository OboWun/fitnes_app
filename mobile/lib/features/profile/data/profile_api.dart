import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'profile_api.g.dart';

@riverpod
ProfileApi profileApi(ProfileApiRef ref) {
  return ProfileApi(ref.watch(dioProvider));
}

class ProfileApi {
  final Dio _dio;

  ProfileApi(this._dio);

  Future<List<Map<String, dynamic>>> getWeightHistory(String period) async {
    final response =
        await _dio.get('/users/weight-history', queryParameters: {'period': period});
    final list = response.data as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getRecentSessions({int limit = 3}) async {
    final response = await _dio.get(
        '/workout-sessions',
        queryParameters: {'limit': limit, 'status': 'completed'});
    final raw = response.data;
    final List<dynamic> list;
    if (raw is List<dynamic>) {
      list = raw;
    } else if (raw is Map<String, dynamic>) {
      list = (raw['data'] ?? raw['items'] ?? []) as List<dynamic>;
    } else {
      list = [];
    }
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getUserEquipmentPresets() async {
    final response = await _dio
        .get('/equipment-presets?includeDetails=true');
    final list = response.data as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getSystemEquipmentPresets() async {
    final response = await _dio
        .get('/equipment-presets/system?includeDetails=true');
    final list = response.data as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> updateWeight(int weight) async {
    final response = await _dio.patch('/users/profile', data: {'weight': weight});
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateContraindications(
      List<String> contraindications) async {
    final response = await _dio.patch(
        '/users/profile',
        data: {'contraindications': contraindications});
    return response.data as Map<String, dynamic>;
  }
}
