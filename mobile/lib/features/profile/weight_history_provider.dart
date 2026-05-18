import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/profile_repository.dart';
import 'domain/weight_record.dart';

part 'weight_history_provider.g.dart';

@riverpod
Future<List<WeightRecord>> weightHistory(WeightHistoryRef ref,
    [WeightPeriod period = WeightPeriod.month]) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getWeightHistory(period);
}
