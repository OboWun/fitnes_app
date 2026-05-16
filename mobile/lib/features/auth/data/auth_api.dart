import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'auth_api.g.dart';

@riverpod
AuthApi authApi(AuthApiRef ref) {
  return AuthApi(ref.watch(dioProvider));
}

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<Map<String, dynamic>> authenticateDevice(String deviceId) async {
    final response = await _dio.post(
      '/auth/device',
      data: {'deviceId': deviceId},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/users/profile');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    final response = await _dio.patch('/users/profile', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getContraindications() async {
    final response = await _dio.get('/contraindications');
    final list = response.data as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}
