import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/equipment_preset.dart';

class EquipmentPresetCard extends StatelessWidget {
  final EquipmentPreset preset;
  final VoidCallback? onTap;

  const EquipmentPresetCard({
    super.key,
    required this.preset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: preset.isSystem
                    ? AppGradients.blueLinear
                    : AppGradients.progressBarLinear,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                preset.isSystem ? Icons.inventory_2_outlined : Icons.edit_outlined,
                color: AppColors.whiteColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.name,
                    style: AppTypography.mediumTextSemiBold
                        .copyWith(color: AppColors.blackColor),
                  ),
                  Text(
                    '${preset.equipmentSlugs.length} поз.',
                    style: AppTypography.smallTextRegular
                        .copyWith(color: AppColors.gray1),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.gray2,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
