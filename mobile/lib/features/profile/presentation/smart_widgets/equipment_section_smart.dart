import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../profile_provider.dart';
import '../widgets/equipment_section.dart';

class EquipmentSectionSmart extends ConsumerWidget {
  const EquipmentSectionSmart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(userEquipmentPresetsProvider);

    return presetsAsync.when(
      data: (presets) => EquipmentSection(
        presets: presets,
        onPresetTap: (preset) =>
            context.push('/equipment/presets/${preset.id}'),
        onAddEquipment: () => context.push('/equipment'),
      ),
      loading: () => const EquipmentSection.loading(),
      error: (_, __) => EquipmentSection(
        presets: [],
        onAddEquipment: () => context.push('/equipment'),
      ),
    );
  }
}
