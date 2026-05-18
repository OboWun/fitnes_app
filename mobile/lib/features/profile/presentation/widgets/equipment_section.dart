import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/equipment_preset.dart';
import 'equipment_preset_card.dart';

class EquipmentSection extends StatelessWidget {
  final List<EquipmentPreset>? _presets;
  final ValueChanged<EquipmentPreset>? _onPresetTap;
  final VoidCallback? _onAddEquipment;

  const EquipmentSection({
    super.key,
    required List<EquipmentPreset> presets,
    ValueChanged<EquipmentPreset>? onPresetTap,
    VoidCallback? onAddEquipment,
  })  : _presets = presets,
        _onPresetTap = onPresetTap,
        _onAddEquipment = onAddEquipment;

  const EquipmentSection.loading({super.key})
      : _presets = null,
        _onPresetTap = null,
        _onAddEquipment = null;

  @override
  Widget build(BuildContext context) {
    if (_presets == null) return const _EquipmentLoading();
    return _EquipmentData(
      presets: _presets!,
      onPresetTap: _onPresetTap,
      onAddEquipment: _onAddEquipment,
    );
  }
}

class _EquipmentData extends StatelessWidget {
  final List<EquipmentPreset> presets;
  final ValueChanged<EquipmentPreset>? onPresetTap;
  final VoidCallback? onAddEquipment;

  const _EquipmentData({
    required this.presets,
    this.onPresetTap,
    this.onAddEquipment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Мой инвентарь',
          style: AppTypography.largeTextSemiBold
              .copyWith(color: AppColors.blackColor),
        ),
        const SizedBox(height: 12),
        if (presets.isEmpty)
          _EmptyEquipmentCTA(onAddEquipment: onAddEquipment)
        else
          ...presets.take(3).map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: EquipmentPresetCard(
                    preset: p,
                    onTap:
                        onPresetTap != null ? () => onPresetTap!(p) : null,
                  ),
                ),
              ),
      ],
    );
  }
}

class _EmptyEquipmentCTA extends StatelessWidget {
  final VoidCallback? onAddEquipment;

  const _EmptyEquipmentCTA({this.onAddEquipment});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAddEquipment,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.gray3,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 32,
              color: AppColors.gray2,
            ),
            const SizedBox(height: 8),
            Text(
              'Добавить инвентарь',
              style: AppTypography.mediumTextSemiBold
                  .copyWith(color: AppColors.gray1),
            ),
            const SizedBox(height: 4),
            Text(
              'Выберите инвентарь для тренировок',
              style: AppTypography.smallTextRegular
                  .copyWith(color: AppColors.gray2),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentLoading extends StatelessWidget {
  const _EquipmentLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Мой инвентарь',
          style: AppTypography.largeTextSemiBold
              .copyWith(color: AppColors.blackColor),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < 2; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ShimmerCard(height: 64, borderRadius: BorderRadius.zero),
          ),
      ],
    );
  }
}
