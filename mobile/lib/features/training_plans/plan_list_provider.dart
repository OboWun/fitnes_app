import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/training_plan_repository.dart';
import 'domain/training_plan.dart';

part 'plan_list_provider.g.dart';

@riverpod
class PlanList extends _$PlanList {
  @override
  Future<List<TrainingPlan>> build() async {
    final repo = ref.watch(trainingPlanRepositoryProvider);
    return repo.getAll();
  }

  void refresh() {
    ref.invalidateSelf();
  }
}
