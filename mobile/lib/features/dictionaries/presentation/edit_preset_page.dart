import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../profile/domain/equipment_preset.dart';
import '../equipment_provider.dart';
import 'widgets/edit_preset_content.dart';

class EditPresetPage extends ConsumerStatefulWidget {
  final EquipmentPreset preset;

  const EditPresetPage({super.key, required this.preset});

  @override
  ConsumerState<EditPresetPage> createState() => _EditPresetPageState();
}

class _EditPresetPageState extends ConsumerState<EditPresetPage> {
  late final TextEditingController _nameController;
  late final ValueNotifier<List<String>> _equipmentSlugs;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.preset.name);
    _equipmentSlugs =
        ValueNotifier(List.from(widget.preset.equipmentSlugs));
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
        title: const Text('Редактирование'),
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
            preset: widget.preset,
            nameController: _nameController,
            equipmentSlugs: _equipmentSlugs,
            allEquipment: allEquipment,
            onDelete: _delete,
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
    final nameChanged = name != widget.preset.name;
    final slugsChanged = !_listEquals(slugs, widget.preset.equipmentSlugs);

    if (!nameChanged && !slugsChanged) {
      context.pop();
      return;
    }

    final service = ref.read(equipmentPresetServiceProvider);
    service.update(
      widget.preset.id,
      name: nameChanged ? name : null,
      equipmentSlugs: slugsChanged ? slugs : null,
    ).then((_) {
      ref.invalidate(allPresetsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пресет обновлён')),
        );
        context.pop();
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка обновления')),
        );
      }
    });
  }

  void _delete() {
    final service = ref.read(equipmentPresetServiceProvider);
    service.delete(widget.preset.id).then((_) {
      ref.invalidate(allPresetsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пресет удалён')),
        );
        context.pop();
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка удаления')),
        );
      }
    });
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
