import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../data/exercise_repository.dart';
import '../../domain/equipment_ref.dart';
import '../../domain/exercise_filter.dart';
import '../../../profile/domain/equipment_preset.dart';

class ExerciseFilterSheet extends StatefulWidget {
  final ExerciseFilter currentFilter;
  final List<EquipmentRef> availableEquipments;
  final List<MuscleItem> availableMuscles;
  final List<EquipmentPreset> availablePresets;
  final ValueChanged<ExerciseFilter>? onApply;

  const ExerciseFilterSheet({
    super.key,
    required this.currentFilter,
    required this.availableEquipments,
    required this.availableMuscles,
    required this.availablePresets,
    this.onApply,
  });

  @override
  State<ExerciseFilterSheet> createState() => _ExerciseFilterSheetState();
}

class _ExerciseFilterSheetState extends State<ExerciseFilterSheet> {
  late List<String> _selectedEquipments;
  late List<String> _selectedMuscles;
  late bool _isPersonal;

  @override
  void initState() {
    super.initState();
    _selectedEquipments = List.from(widget.currentFilter.equipments);
    _selectedMuscles = List.from(widget.currentFilter.targetMuscles);
    _isPersonal = widget.currentFilter.isPersonal;
  }

  bool _isPresetSelected(EquipmentPreset preset) {
    final presetSlugs = preset.equipmentSlugs.toSet();
    final selectedSet = _selectedEquipments.toSet();
    return presetSlugs.length == selectedSet.length &&
        presetSlugs.containsAll(selectedSet);
  }

  @override
  Widget build(BuildContext context) {
    final systemPresets =
        widget.availablePresets.where((p) => p.isSystem).toList();
    final userPresets =
        widget.availablePresets.where((p) => !p.isSystem).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Фильтры',
              style: AppTypography.h4SemiBold
                  .copyWith(color: AppColors.blackColor),
            ),
            const SizedBox(height: 16),
            _PersonalSwitch(
              value: _isPersonal,
              onChanged: (v) => setState(() => _isPersonal = v),
            ),
            const SizedBox(height: 16),
            if (systemPresets.isNotEmpty) ...[
              _SectionTitle(title: 'Системные пресеты'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: systemPresets.map((preset) {
                  final isSelected = _isPresetSelected(preset);
                  return _FilterChip(
                    label: preset.name,
                    isSelected: isSelected,
                    gradient: AppGradients.blueLinear,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedEquipments.clear();
                        } else {
                          _selectedEquipments =
                              List.from(preset.equipmentSlugs);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (userPresets.isNotEmpty) ...[
              _SectionTitle(title: 'Мои пресеты'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: userPresets.map((preset) {
                  final isSelected = _isPresetSelected(preset);
                  return _FilterChip(
                    label: preset.name,
                    isSelected: isSelected,
                    gradient: AppGradients.progressBarLinear,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedEquipments.clear();
                        } else {
                          _selectedEquipments =
                              List.from(preset.equipmentSlugs);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.availableEquipments.isNotEmpty) ...[
              _SectionTitle(title: 'Инвентарь'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.availableEquipments.map((eq) {
                  final isSelected =
                      _selectedEquipments.contains(eq.slug);
                  return _FilterChip(
                    label: eq.name,
                    isSelected: isSelected,
                    gradient: AppGradients.blueLinear,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedEquipments.remove(eq.slug);
                        } else {
                          _selectedEquipments.add(eq.slug);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.availableMuscles.isNotEmpty) ...[
              _SectionTitle(title: 'Целевые мышцы'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.availableMuscles.map((muscle) {
                  final isSelected =
                      _selectedMuscles.contains(muscle.slug);
                  return _FilterChip(
                    label: muscle.name,
                    isSelected: isSelected,
                    gradient: AppGradients.purpleLinear,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedMuscles.remove(muscle.slug);
                        } else {
                          _selectedMuscles.add(muscle.slug);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: _apply,
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
                      'Применить',
                      style: AppTypography.largeTextSemiBold
                          .copyWith(color: AppColors.whiteColor),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _apply() {
    String? presetId;
    String? presetName;
    final matchedPreset = widget.availablePresets.where((p) {
      final presetSlugs = p.equipmentSlugs.toList()..sort();
      final selected = _selectedEquipments.toList()..sort();
      return presetSlugs.length == selected.length &&
          presetSlugs.asMap().entries.every(
              (e) => e.value == selected[e.key]);
    }).firstOrNull;
    if (matchedPreset != null) {
      presetId = matchedPreset.id;
      presetName = matchedPreset.name;
    }

    widget.onApply?.call(
      widget.currentFilter.copyWith(
        equipments: _selectedEquipments,
        targetMuscles: _selectedMuscles,
        isPersonal: _isPersonal,
        presetId: presetId,
        presetName: presetName,
        page: 1,
      ),
    );
    Navigator.of(context).pop();
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.mediumTextSemiBold
          .copyWith(color: AppColors.blackColor),
    );
  }
}

class _PersonalSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _PersonalSwitch({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged?.call(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value
              ? AppColors.whiteColor
              : AppColors.borderColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? const Color(0xFF92A3FD).withValues(alpha: 0.5)
                : AppColors.gray3,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.shield : Icons.shield_outlined,
              size: 20,
              color: value
                  ? const Color(0xFF92A3FD)
                  : AppColors.gray2,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Учитывать противопоказания',
                    style: AppTypography.mediumTextMedium.copyWith(
                      color: AppColors.blackColor,
                    ),
                  ),
                  Text(
                    value
                        ? 'Безопасные упражнения первыми'
                        : 'Без сортировки по доступности',
                    style: AppTypography.smallTextRegular.copyWith(
                      color: AppColors.gray2,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF92A3FD),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? null : AppColors.borderColor,
          gradient: isSelected ? gradient : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.smallTextMedium.copyWith(
            color:
                isSelected ? AppColors.whiteColor : AppColors.gray1,
          ),
        ),
      ),
    );
  }
}
