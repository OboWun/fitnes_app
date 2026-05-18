import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/retry.dart';
import '../domain/home_data.dart';
import 'home_api.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepository(ref.watch(homeApiProvider));
}

class HomeRepository {
  final HomeApi _api;

  HomeRepository(this._api);

  Future<HomeData> getHomeData({String? weekStart}) async {
    final data = await withRetry(() => _api.getHomeData(weekStart: weekStart));
    return HomeData.fromJson(data);
  }
}
