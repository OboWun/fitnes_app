import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/profile_repository.dart';
import 'domain/equipment_preset.dart';
import 'domain/workout_session_brief.dart';

part 'profile_provider.g.dart';

@riverpod
Future<List<WorkoutSessionBrief>> recentSessions(RecentSessionsRef ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getRecentSessions();
}

@riverpod
Future<List<EquipmentPreset>> allEquipmentPresets(
    AllEquipmentPresetsRef ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  final systemPresets = await repo.getSystemPresets();
  try {
    final userPresets = await repo.getUserPresets();
    return [...systemPresets, ...userPresets];
  } catch (_) {
    return systemPresets;
  }
}

@riverpod
Future<List<EquipmentPreset>> userEquipmentPresets(
    UserEquipmentPresetsRef ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getUserPresets();
}
