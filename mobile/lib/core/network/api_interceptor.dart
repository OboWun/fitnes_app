import 'package:dio/dio.dart';

import '../storage/auth_storage.dart';

class ApiInterceptor extends Interceptor {
  final AuthStorage _authStorage;

  ApiInterceptor(this._authStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _authStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO: handle 401 — clear token, redirect to auth
    super.onError(err, handler);
  }
}
