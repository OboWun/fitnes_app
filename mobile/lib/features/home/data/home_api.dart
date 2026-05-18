import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'home_api.g.dart';

@riverpod
HomeApi homeApi(HomeApiRef ref) {
  return HomeApi(ref.watch(dioProvider));
}

class HomeApi {
  final Dio _dio;

  HomeApi(this._dio);

  Future<Map<String, dynamic>> getHomeData({String? weekStart}) async {
    final response = await _dio.get(
      '/home/data',
      queryParameters: weekStart != null ? {'weekStart': weekStart} : null,
    );
    return response.data as Map<String, dynamic>;
  }
}
