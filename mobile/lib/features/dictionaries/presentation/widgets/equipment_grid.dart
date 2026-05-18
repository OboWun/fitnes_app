import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/equipment_item.dart';
import 'equipment_card.dart';

class EquipmentGrid extends StatelessWidget {
  final List<EquipmentItem>? _items;
  final ValueChanged<EquipmentItem>? _onTap;

  const EquipmentGrid({
    super.key,
    required List<EquipmentItem> items,
    ValueChanged<EquipmentItem>? onTap,
  })  : _items = items,
        _onTap = onTap;

  const EquipmentGrid.loading({super.key, int count = 6})
      : _items = null,
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_items == null) {
      return _buildGrid(
        List.generate(6, (_) => const EquipmentCard.loading()),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'Ничего не найдено',
            style: AppTypography.mediumTextRegular
                .copyWith(color: AppColors.gray2),
          ),
        ),
      );
    }
    return _buildGrid(
      _items
          .map((item) => EquipmentCard(
                item: item,
                onTap: _onTap != null ? () => _onTap(item) : null,
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
