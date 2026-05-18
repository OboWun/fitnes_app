import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../profile/domain/equipment_preset.dart';
import '../../domain/equipment_item.dart';
import 'add_equipment_sheet.dart';

class EditPresetContent extends StatelessWidget {
  final EquipmentPreset preset;
  final TextEditingController nameController;
  final ValueNotifier<List<String>> equipmentSlugs;
  final List<EquipmentItem> allEquipment;
  final ValueChanged<EquipmentPreset>? onSaved;
  final VoidCallback? onDelete;

  const EditPresetContent({
    super.key,
    required this.preset,
    required this.nameController,
    required this.equipmentSlugs,
    required this.allEquipment,
    this.onSaved,
    this.onDelete,
  });

  String _preFillName(EquipmentPreset preset) {
    if (preset.isSystem) {
      final words = preset.name.split(' ');
      final lastWord = words.last.toLowerCase();
      final prefix =
          lastWord.endsWith('а') || lastWord.endsWith('я') ? 'Моя' : 'Мой';
      return '$prefix ${preset.name}';
    }
    return preset.name;
  }

  @override
  Widget build(BuildContext context) {
    final initialName = _preFillName(preset);
    if (nameController.text.isEmpty) {
      nameController.text = initialName;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: nameController,
            style: AppTypography.largeTextSemiBold
                .copyWith(color: AppColors.blackColor),
            decoration: InputDecoration(
              labelText: 'Название пресета',
              labelStyle: AppTypography.mediumTextRegular
                  .copyWith(color: AppColors.gray2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gray3),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gray3),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF92A3FD)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Оборудование',
                  style: AppTypography.largeTextSemiBold
                      .copyWith(color: AppColors.blackColor),
                ),
              ),
              ValueListenableBuilder<List<String>>(
                valueListenable: equipmentSlugs,
                builder: (_, slugs, __) => Text(
                  '${slugs.length} поз.',
                  style: AppTypography.mediumTextRegular
                      .copyWith(color: AppColors.gray1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<String>>(
          valueListenable: equipmentSlugs,
          builder: (_, slugs, __) {
            final equipmentMap = <String, EquipmentItem>{};
            for (final e in allEquipment) {
              equipmentMap[e.slug] = e;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  for (int i = 0; i < slugs.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _EditableEquipmentItem(
                      name: equipmentMap[slugs[i]]?.name ?? slugs[i],
                      onRemove: () {
                        final list = List<String>.from(slugs);
                        list.removeAt(i);
                        equipmentSlugs.value = list;
                      },
                    ),
                  ],
                  if (slugs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Инвентарь не добавлен',
                        style: AppTypography.mediumTextRegular
                            .copyWith(color: AppColors.gray2),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () {
                final currentSlugs = equipmentSlugs.value;
                final available = allEquipment
                    .where((e) => !currentSlugs.contains(e.slug))
                    .toList();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.whiteColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => AddEquipmentSheet(
                    availableEquipment: available,
                    onAdd: (selected) {
                      final list = List<String>.from(equipmentSlugs.value);
                      list.addAll(selected.map((e) => e.slug));
                      equipmentSlugs.value = list;
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppGradients.blueLinear,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.blue,
                ),
                child: Center(
                  child: Text(
                    'Добавить инвентарь',
                    style: AppTypography.largeTextSemiBold
                        .copyWith(color: AppColors.whiteColor),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (onDelete != null) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Удалить пресет',
                      style: AppTypography.largeTextSemiBold
                          .copyWith(color: AppColors.danger),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EditableEquipmentItem extends StatelessWidget {
  final String name;
  final VoidCallback? onRemove;

  const _EditableEquipmentItem({
    required this.name,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppGradients.blueLinear,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.whiteColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: AppTypography.mediumTextSemiBold
                  .copyWith(color: AppColors.blackColor),
            ),
          ),
          if (onRemove != null)
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(16),
              child: const Icon(
                Icons.close,
                color: AppColors.gray2,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
