import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'equipment_api.g.dart';

@riverpod
EquipmentApi equipmentApi(EquipmentApiRef ref) {
  return EquipmentApi(ref.watch(dioProvider));
}

class EquipmentApi {
  final Dio _dio;

  EquipmentApi(this._dio);

  Future<List<Map<String, dynamic>>> getAllEquipment() async {
    final response = await _dio.get('/equipments');
    final list = response.data as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getSystemPresets() async {
    final response = await _dio
        .get('/equipment-presets/system?includeDetails=true');
    final list = response.data as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getUserPresets() async {
    final response = await _dio
        .get('/equipment-presets?includeDetails=true');
    final list = response.data as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getExercisesByEquipment(
      String slug, int limit) async {
    final response =
        await _dio.get('/exercises?limit=$limit&equipments=$slug');
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> createPreset({
    required String name,
    required String slug,
    required List<String> equipmentSlugs,
  }) async {
    final response = await _dio.post('/equipment-presets', data: {
      'name': name,
      'slug': slug,
      'equipmentSlugs': equipmentSlugs,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updatePreset(String id, {
    String? name,
    List<String>? equipmentSlugs,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (equipmentSlugs != null) body['equipmentSlugs'] = equipmentSlugs;
    final response =
        await _dio.patch('/equipment-presets/$id', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deletePreset(String id) async {
    await _dio.delete('/equipment-presets/$id');
  }
}
