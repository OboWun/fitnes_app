import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../storage/auth_storage.dart';
import 'api_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final authStorage = ref.watch(authStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(ApiInterceptor(authStorage));

  return dio;
});
