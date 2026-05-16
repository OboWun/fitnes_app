import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mobile/core/storage/auth_storage.dart';
import 'package:mobile/features/auth/data/auth_api.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';

class MockAuthStorage extends Mock implements AuthStorage {}

class MockAuthApi extends Mock implements AuthApi {}

class MockAuthRepository extends Mock implements AuthRepository {}

RequestOptions _baseRequestOptions(String path) {
  return RequestOptions(path: path);
}

DioException dioException({
  required DioExceptionType type,
  int? statusCode,
  String path = '/test',
  Response? response,
}) {
  return DioException(
    requestOptions: _baseRequestOptions(path),
    type: type,
    response: response ??
        (statusCode != null
            ? Response(
                requestOptions: _baseRequestOptions(path),
                statusCode: statusCode,
              )
            : null),
  );
}

void registerFallbackValues() {
  registerFallbackValue(_baseRequestOptions('/fallback'));
}
