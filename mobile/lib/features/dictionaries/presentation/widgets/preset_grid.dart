import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../profile/domain/equipment_preset.dart';
import 'preset_card.dart';

class PresetGrid extends StatelessWidget {
  final List<EquipmentPreset>? _presets;
  final ValueChanged<EquipmentPreset>? _onTap;

  const PresetGrid({
    super.key,
    required List<EquipmentPreset> presets,
    ValueChanged<EquipmentPreset>? onTap,
  })  : _presets = presets,
        _onTap = onTap;

  const PresetGrid.loading({super.key, int count = 6})
      : _presets = null,
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_presets == null) {
      return _buildGrid(
        List.generate(6, (_) => const _PresetCardLoading()),
      );
    }
    if (_presets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'Нет пресетов',
            style: AppTypography.mediumTextRegular
                .copyWith(color: AppColors.gray2),
          ),
        ),
      );
    }
    return _buildGrid(
      _presets
          .map((preset) => PresetCard(
                preset: preset,
                onTap: _onTap != null ? () => _onTap(preset) : null,
              ))
          .toList(),
    );
  }

  Widget _buildGrid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.75,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class _PresetCardLoading extends StatelessWidget {
  const _PresetCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShimmerCard(width: 28, height: 28, borderRadius: BorderRadius.zero),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerCard(height: 16),
              SizedBox(height: 4),
              ShimmerCard(width: 60, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
