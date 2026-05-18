import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/home_repository.dart';
import 'domain/home_data.dart';

part 'home_provider.g.dart';

@Riverpod(keepAlive: true)
class Home extends _$Home {
  @override
  Future<HomeData> build() async {
    final repo = ref.watch(homeRepositoryProvider);
    return repo.getHomeData();
  }

  Future<void> refresh({String? weekStart}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final repo = ref.read(homeRepositoryProvider);
      return repo.getHomeData(weekStart: weekStart);
    });
  }
}
