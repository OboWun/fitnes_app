import 'package:dio/dio.dart';

import '../storage/auth_storage.dart';
import 'exceptions.dart';

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
    final exception = _mapDioException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }

  AppException _mapDioException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(originalError: err);
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Нет подключения к серверу',
          originalError: err,
        );
      case DioExceptionType.badResponse:
        return _mapStatusCode(err);
      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Запрос отменён',
          originalError: err,
        );
      default:
        return UnknownException(originalError: err);
    }
  }

  AppException _mapStatusCode(DioException err) {
    final statusCode = err.response?.statusCode;
    switch (statusCode) {
      case 401:
        _authStorage.clear();
        return const AuthException(message: 'Сессия истекла');
      case 403:
        return AuthException(
          message: 'Доступ запрещён',
          originalError: err,
        );
      case 404:
        return NetworkException(
          message: 'Ресурс не найден',
          statusCode: statusCode!,
          originalError: err,
        );
      default:
        if (statusCode != null && statusCode >= 500) {
          return ServerException(
            message: 'Ошибка сервера',
            statusCode: statusCode,
            originalError: err,
          );
        }
        return NetworkException(
          message: 'Ошибка сети',
          statusCode: statusCode,
          originalError: err,
        );
    }
  }
}
