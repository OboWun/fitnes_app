import 'package:flutter/material.dart';

import '../../../profile/domain/equipment_preset.dart';
import 'preset_card.dart';

class PresetCarousel extends StatelessWidget {
  final List<EquipmentPreset>? _presets;
  final ValueChanged<EquipmentPreset>? _onTap;

  const PresetCarousel({
    super.key,
    required List<EquipmentPreset> presets,
    ValueChanged<EquipmentPreset>? onTap,
  })  : _presets = presets,
        _onTap = onTap;

  const PresetCarousel.loading({super.key})
      : _presets = null,
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_presets == null) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_presets.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 160,
      child: CarouselView(
        itemExtent: 180,
        shrinkExtent: 40,
        children: _presets
            .map((preset) => PresetCard(
                  preset: preset,
                  onTap: _onTap != null
                      ? () => _onTap(preset)
                      : null,
                ))
            .toList(),
      ),
    );
  }
}
