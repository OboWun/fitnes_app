import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/exercise_repository.dart';
import 'domain/exercise_detail.dart';
import 'domain/exercise_filter.dart';
import 'domain/exercise_short.dart';
import 'domain/paginated_result.dart';

part 'exercise_provider.g.dart';

@riverpod
Future<PaginatedResult<ExerciseShort>> exercisesPage(
    ExercisesPageRef ref, int page, ExerciseFilter filter) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getExercises(
    page: page,
    limit: filter.limit,
    search: filter.search,
    equipments:
        filter.equipments.isNotEmpty ? filter.equipments : null,
    targetMuscles: filter.targetMuscles.isNotEmpty
        ? filter.targetMuscles
        : null,
    isPersonal: filter.isPersonal,
  );
}

@riverpod
Future<ExerciseDetail> exerciseDetail(
    ExerciseDetailRef ref, String slug) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getExerciseDetail(slug);
}

@riverpod
Future<List<MuscleItem>> allMuscles(AllMusclesRef ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getMuscles();
}
