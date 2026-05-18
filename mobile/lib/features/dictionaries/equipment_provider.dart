import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/retry.dart';
import 'data/equipment_api.dart';
import 'domain/equipment_item.dart';
import 'domain/exercise_brief.dart';
import '../profile/domain/equipment_preset.dart';

part 'equipment_provider.g.dart';

@riverpod
Future<List<EquipmentItem>> allEquipment(AllEquipmentRef ref) async {
  final api = ref.watch(equipmentApiProvider);
  final data = await withRetry(() => api.getAllEquipment());
  return data.map((e) => EquipmentItem.fromJson(e)).toList();
}

@riverpod
Future<List<EquipmentPreset>> allPresets(AllPresetsRef ref) async {
  final api = ref.watch(equipmentApiProvider);
  final systemData = await withRetry(() => api.getSystemPresets());
  final system =
      systemData.map((e) => EquipmentPreset.fromJson(e)).toList();
  try {
    final userData = await withRetry(() => api.getUserPresets());
    final user =
        userData.map((e) => EquipmentPreset.fromJson(e)).toList();
    return [...system, ...user];
  } catch (_) {
    return system;
  }
}

@riverpod
Future<List<ExerciseBrief>> equipmentExercises(
    EquipmentExercisesRef ref, String slug) async {
  final api = ref.watch(equipmentApiProvider);
  final data =
      await withRetry(() => api.getExercisesByEquipment(slug, 3));
  return data
      .map((e) => ExerciseBrief(
            slug: e['slug'] as String? ?? '',
            name: e['name'] as String? ?? '',
            gifUrl: e['gifUrl'] as String?,
            difficulty: e['difficulty'] as String?,
          ))
      .toList();
}

@riverpod
EquipmentPresetService equipmentPresetService(
    EquipmentPresetServiceRef ref) {
  return EquipmentPresetService(ref.watch(equipmentApiProvider));
}

class EquipmentPresetService {
  final EquipmentApi _api;

  EquipmentPresetService(this._api);

  Future<EquipmentPreset> create({
    required String name,
    required List<String> equipmentSlugs,
  }) async {
    final slug =
        'my-preset-${DateTime.now().millisecondsSinceEpoch}';
    final data = await withRetry(() => _api.createPreset(
          name: name,
          slug: slug,
          equipmentSlugs: equipmentSlugs,
        ));
    return EquipmentPreset.fromJson(data);
  }

  Future<EquipmentPreset> update(String id, {
    String? name,
    List<String>? equipmentSlugs,
  }) async {
    final data = await withRetry(
        () => _api.updatePreset(id, name: name, equipmentSlugs: equipmentSlugs));
    return EquipmentPreset.fromJson(data);
  }

  Future<void> delete(String id) async {
    await withRetry(() => _api.deletePreset(id));
  }
}
