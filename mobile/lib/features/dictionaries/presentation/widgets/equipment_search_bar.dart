import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class EquipmentSearchBar extends StatelessWidget {
  final String value;
  final ValueChanged<String>? onChanged;

  const EquipmentSearchBar({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppTypography.mediumTextRegular,
      decoration: InputDecoration(
        hintText: 'Поиск инвентаря...',
        prefixIcon: const Icon(Icons.search, color: AppColors.gray2),
        suffixIcon: value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.gray2),
                onPressed: () => onChanged?.call(''),
              )
            : null,
      ),
    );
  }
}
