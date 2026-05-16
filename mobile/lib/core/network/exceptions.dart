sealed class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });
}

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class ServerException extends AppException {
  final int statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    required this.statusCode,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Превышено время ожидания',
    super.code,
    super.originalError,
  });
}

class UnknownException extends AppException {
  const UnknownException({
    super.message = 'Неизвестная ошибка',
    super.code,
    super.originalError,
  });
}
