import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/retry.dart';
import '../domain/workout_exercise.dart';
import '../domain/workout_template.dart';
import 'workout_template_api.dart';

part 'workout_template_repository.g.dart';

@riverpod
WorkoutTemplateRepository workoutTemplateRepository(
    WorkoutTemplateRepositoryRef ref) {
  return WorkoutTemplateRepository(ref.watch(workoutTemplateApiProvider));
}

class WorkoutTemplateRepository {
  final WorkoutTemplateApi _api;

  WorkoutTemplateRepository(this._api);

  Future<List<WorkoutTemplate>> getAll() async {
    final data = await withRetry(() => _api.getAll());
    return data
        .map((e) => WorkoutTemplate.fromJson(e))
        .toList();
  }

  Future<WorkoutTemplate> getById(String id) async {
    final data = await withRetry(() => _api.getById(id));
    return WorkoutTemplate.fromJson(data);
  }

  Future<WorkoutTemplate> create({
    required String name,
    String? description,
    required List<WorkoutExercise> exercises,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      if (description != null) 'description': description,
      'exercises': exercises
          .map((e) => {
                'exerciseSlug': e.exerciseSlug,
                'sets': e.sets,
                if (e.reps != null) 'reps': e.reps,
                if (e.restBetweenSets != null)
                  'restBetweenSets': e.restBetweenSets,
                if (e.restAfterExercise != null)
                  'restAfterExercise': e.restAfterExercise,
                'order': e.order,
              })
          .toList(),
    };
    final data = await withRetry(() => _api.create(body));
    return WorkoutTemplate.fromJson(data);
  }

  Future<WorkoutTemplate> update(
    String id, {
    String? name,
    String? description,
    List<WorkoutExercise>? exercises,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (exercises != null) {
      body['exercises'] = exercises
          .map((e) => {
                'exerciseSlug': e.exerciseSlug,
                'sets': e.sets,
                if (e.reps != null) 'reps': e.reps,
                if (e.restBetweenSets != null)
                  'restBetweenSets': e.restBetweenSets,
                if (e.restAfterExercise != null)
                  'restAfterExercise': e.restAfterExercise,
                'order': e.order,
              })
          .toList();
    }
    final data = await withRetry(() => _api.update(id, body));
    return WorkoutTemplate.fromJson(data);
  }

  Future<void> delete(String id) async {
    await withRetry(() => _api.delete(id));
  }
}
