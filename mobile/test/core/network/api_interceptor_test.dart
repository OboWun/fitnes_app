import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mobile/core/network/api_interceptor.dart';
import 'package:mobile/core/network/exceptions.dart';
import 'package:mobile/core/storage/auth_storage.dart';

class MockAuthStorage extends Mock implements AuthStorage {}

RequestOptions _baseRequestOptions(String path) {
  return RequestOptions(path: path);
}

DioException dioException({
  required DioExceptionType type,
  int? statusCode,
  String path = '/test',
}) {
  return DioException(
    requestOptions: _baseRequestOptions(path),
    type: type,
    response: statusCode != null
        ? Response(
            requestOptions: _baseRequestOptions(path),
            statusCode: statusCode,
          )
        : null,
  );
}

void main() {
  late MockAuthStorage mockStorage;
  late ApiInterceptor interceptor;

  setUp(() {
    mockStorage = MockAuthStorage();
    interceptor = ApiInterceptor(mockStorage);
    registerFallbackValue(_baseRequestOptions('/fallback'));
  });

  group('onRequest', () {
    test('adds Authorization header when token exists', () async {
      when(() => mockStorage.accessToken).thenReturn('jwt-token-123');

      final options = RequestOptions(path: '/test');
      final handler = _TestRequestHandler();

      interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer jwt-token-123');
    });

    test('does not add Authorization header when token is null', () async {
      when(() => mockStorage.accessToken).thenReturn(null);

      final options = RequestOptions(path: '/test');
      final handler = _TestRequestHandler();

      interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('onError', () {
    test('maps connectionTimeout to TimeoutException', () {
      final err = dioException(type: DioExceptionType.connectionTimeout);
      final handler = _TestErrorHandler();

      interceptor.onError(err, handler);

      expect(handler.error!.error, isA<TimeoutException>());
    });

    test('maps sendTimeout to TimeoutException', () {
      final err = dioException(type: DioExceptionType.sendTimeout);
      final handler = _TestErrorHandler();

      interceptor.onError(err, handler);

      expect(handler.error!.error, isA<TimeoutException>());
    });

    test('maps receiveTimeout to TimeoutException', () {
      final err = dioException(type: DioExceptionType.receiveTimeout);
      final handler = _TestErrorHandler();

      interceptor.onError(err, handler);

      expect(handler.error!.error, isA<TimeoutException>());
    });

    test('maps connectionError to NetworkException', () {
      final err = dioException(type: DioExceptionType.connectionError);
      final handler = _TestErrorHandler();

      interceptor.onError(err, handler);

      final appException = handler.error!.error as AppException;
      expect(appException, isA<NetworkException>());
      expect(appException.message, 'Нет подключения к серверу');
    });

    test('maps 401 to AuthException and clears token', () {
      when(() => mockStorage.clear()).thenAnswer((_) async {});

      final err = dioException(
        type: DioExceptionType.badResponse,
        statusCode: 401,
      );
      final handler = _TestErrorHandler();

      interceptor.onError(err, handler);

      final appException = handler.error!.error as AppException;
      expect(appException, isA<AuthException>());
      expect(appException.message, 'Сессия истекла');
      verify(() => mockStorage.clear()).called(1);
    });

    test('maps 403 to AuthException', () {
      final err = dioException(
        type: DioExceptionType.badResponse,
        statusCode: 403,
      );
      final handler = _TestErrorHandler();

      interceptor.onError(err, handler);

      final appException = handler.error!.error as AppException;
      expect(appException, isA<AuthException>());
      expect(appException.message, 'Доступ запрещён');
    });

    test('maps 404 to NetworkException', () {
      final err = dioException(
        type: DioExceptionType.badResponse,
        statusCode: 404,
      );
      final handler = _TestErrorHandler();

      interceptor.onError(err, handler);

      final appException = handler.error!.error as AppException;
      expect(appException, isA<NetworkException>());
      expect(appException.message, 'Ресурс не найден');
    });

    test('maps 500 to ServerException', () {
      final err = dioException(
        type: DioExceptionType.badResponse,
        statusCode: 500,
      );
      final handler = _TestErrorHandler();

      interceptor.onError(err, handler);

      final appException = handler.error!.error as AppException;
      expect(appException, isA<ServerException>());
      expect(appException.message, 'Ошибка сервера');
    });

    test('maps 502 to ServerException', () {
      final err = dioException(
        type: DioExceptionType.badResponse,
        statusCode: 502,
      );
      final handler = _TestErrorHandler();

      interceptor.onError(err, handler);

      expect(handler.error!.error, isA<ServerException>());
    });

    test('maps 422 to NetworkException', () {
      final err = dioException(
        type: DioExceptionType.badResponse,
        statusCode: 422,
      );
      final handler = _TestErrorHandler();

      interceptor.onError(err, handler);

      final appException = handler.error!.error as AppException;
      expect(appException, isA<NetworkException>());
      expect(appException.message, 'Ошибка сети');
    });

    test('maps cancel to NetworkException', () {
      final err = dioException(type: DioExceptionType.cancel);
      final handler = _TestErrorHandler();

      interceptor.onError(err, handler);

      final appException = handler.error!.error as AppException;
      expect(appException, isA<NetworkException>());
      expect(appException.message, 'Запрос отменён');
    });

    test('maps unknown type to UnknownException', () {
      final err = dioException(type: DioExceptionType.unknown);
      final handler = _TestErrorHandler();

      interceptor.onError(err, handler);

      expect(handler.error!.error, isA<UnknownException>());
    });
  });
}

class _TestRequestHandler extends RequestInterceptorHandler {
  _TestRequestHandler() : super();
}

class _TestErrorHandler extends ErrorInterceptorHandler {
  DioException? error;

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) {
    error = err;
  }
}
