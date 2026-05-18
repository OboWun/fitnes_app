import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/retry.dart';
import '../domain/exercise_detail.dart';
import '../domain/exercise_short.dart';
import '../domain/paginated_result.dart';
import 'exercise_api.dart';

part 'exercise_repository.g.dart';

@riverpod
ExerciseRepository exerciseRepository(ExerciseRepositoryRef ref) {
  return ExerciseRepository(ref.watch(exerciseApiProvider));
}

class MuscleItem {
  final String slug;
  final String name;

  const MuscleItem({required this.slug, required this.name});
}

class ExerciseRepository {
  final ExerciseApi _api;

  ExerciseRepository(this._api);

  Future<PaginatedResult<ExerciseShort>> getExercises({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? equipments,
    List<String>? targetMuscles,
    bool isPersonal = true,
  }) async {
    final data = await withRetry(() => _api.getExercises(
          page: page,
          limit: limit,
          search: search,
          equipments: equipments,
          targetMuscles: targetMuscles,
          isPersonal: isPersonal,
        ));
    final list = (data['data'] as List<dynamic>)
        .map((e) => ExerciseShort.fromJson(e as Map<String, dynamic>))
        .toList();
    return PaginatedResult(
      data: list,
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
      totalPages: data['totalPages'] as int? ?? 0,
    );
  }

  Future<ExerciseDetail> getExerciseDetail(String slug) async {
    final data =
        await withRetry(() => _api.getExerciseDetail(slug));
    return ExerciseDetail.fromJson(data);
  }

  Future<List<MuscleItem>> getMuscles() async {
    final data = await withRetry(() => _api.getMuscles());
    return data
        .map((e) => MuscleItem(
              slug: e['slug'] as String,
              name: e['name'] as String,
            ))
        .toList();
  }
}
