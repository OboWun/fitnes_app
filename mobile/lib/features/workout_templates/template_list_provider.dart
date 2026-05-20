import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/workout_template_repository.dart';
import 'domain/workout_template.dart';

part 'template_list_provider.g.dart';

@riverpod
class TemplateList extends _$TemplateList {
  @override
  Future<List<WorkoutTemplate>> build() async {
    final repo = ref.watch(workoutTemplateRepositoryProvider);
    return repo.getAll();
  }

  void refresh() {
    ref.invalidateSelf();
  }
}
