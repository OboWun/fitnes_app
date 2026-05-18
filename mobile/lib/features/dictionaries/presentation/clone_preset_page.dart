import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../profile/domain/equipment_preset.dart';
import '../equipment_provider.dart';
import 'widgets/edit_preset_content.dart';

class ClonePresetPage extends ConsumerStatefulWidget {
  final EquipmentPreset sourcePreset;

  const ClonePresetPage({super.key, required this.sourcePreset});

  @override
  ConsumerState<ClonePresetPage> createState() => _ClonePresetPageState();
}

class _ClonePresetPageState extends ConsumerState<ClonePresetPage> {
  late final TextEditingController _nameController;
  late final ValueNotifier<List<String>> _equipmentSlugs;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _equipmentSlugs =
        ValueNotifier(List.from(widget.sourcePreset.equipmentSlugs));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _equipmentSlugs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equipmentAsync = ref.watch(allEquipmentProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: const Text('Новый пресет'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Сохранить',
                style: AppTypography.mediumTextSemiBold
                    .copyWith(color: const Color(0xFF92A3FD))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
        child: equipmentAsync.when(
          data: (allEquipment) => EditPresetContent(
            preset: widget.sourcePreset,
            nameController: _nameController,
            equipmentSlugs: _equipmentSlugs,
            allEquipment: allEquipment,
            onSaved: null,
            onDelete: null,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Ошибка загрузки')),
        ),
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final slugs = _equipmentSlugs.value;
    final service = ref.read(equipmentPresetServiceProvider);

    service.create(name: name, equipmentSlugs: slugs).then((_) {
      ref.invalidate(allPresetsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пресет успешно создан')),
        );
        context.pop();
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка создания пресета')),
        );
      }
    });
  }
}
