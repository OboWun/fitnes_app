class AppConstants {
  AppConstants._();

  static const String baseUrl = 'http://localhost:3001';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String deviceIdKey = 'device_id';
}
