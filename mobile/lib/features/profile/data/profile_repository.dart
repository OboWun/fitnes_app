import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/retry.dart';
import '../domain/equipment_preset.dart';
import '../domain/weight_record.dart';
import '../domain/workout_session_brief.dart';
import 'profile_api.dart';

part 'profile_repository.g.dart';

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository(ref.watch(profileApiProvider));
}

class ProfileRepository {
  final ProfileApi _api;

  ProfileRepository(this._api);

  Future<List<WeightRecord>> getWeightHistory(WeightPeriod period) async {
    final periodStr = switch (period) {
      WeightPeriod.week => 'week',
      WeightPeriod.month => 'month',
      WeightPeriod.all => 'all',
    };
    final data = await withRetry(() => _api.getWeightHistory(periodStr));
    return data.map((e) => WeightRecord(
          date: DateTime.parse(e['date'] as String),
          weight: (e['weight'] as num).toDouble(),
        )).toList();
  }

  Future<List<WorkoutSessionBrief>> getRecentSessions({int limit = 3}) async {
    final data =
        await withRetry(() => _api.getRecentSessions(limit: limit));
    return data
        .map((e) => WorkoutSessionBrief.fromJson(e))
        .toList();
  }

  Future<List<EquipmentPreset>> getUserPresets() async {
    final data = await withRetry(() => _api.getUserEquipmentPresets());
    return data.map((e) => EquipmentPreset.fromJson(e)).toList();
  }

  Future<List<EquipmentPreset>> getSystemPresets() async {
    final data = await withRetry(() => _api.getSystemEquipmentPresets());
    return data.map((e) => EquipmentPreset.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> updateWeight(int weight) async {
    return withRetry(() => _api.updateWeight(weight));
  }

  Future<Map<String, dynamic>> updateContraindications(
      List<String> contraindications) async {
    return withRetry(
        () => _api.updateContraindications(contraindications));
  }
}
