import 'package:dio/dio.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  /// POST /auth/device — Регистрация/вход по deviceId
  Future<Map<String, dynamic>> authenticateDevice(String deviceId) async {
    final response = await _dio.post(
      '/auth/device',
      data: {'deviceId': deviceId},
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /users/profile — Получение профиля
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/users/profile');
    return response.data as Map<String, dynamic>;
  }

  /// PATCH /users/profile — Обновление профиля
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch('/users/profile', data: data);
    return response.data as Map<String, dynamic>;
  }
}
