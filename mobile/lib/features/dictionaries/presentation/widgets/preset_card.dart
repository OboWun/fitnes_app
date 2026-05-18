import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../profile/domain/equipment_preset.dart';

class PresetCard extends StatelessWidget {
  final EquipmentPreset preset;
  final VoidCallback? onTap;

  const PresetCard({
    super.key,
    required this.preset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: preset.isSystem
              ? AppGradients.blueLinear
              : AppGradients.progressBarLinear,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.blue,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              preset.isSystem
                  ? Icons.inventory_2_outlined
                  : Icons.edit_outlined,
              color: AppColors.whiteColor,
              size: 28,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preset.name,
                  style: AppTypography.mediumTextSemiBold
                      .copyWith(color: AppColors.whiteColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${preset.equipmentSlugs.length} поз.',
                  style: AppTypography.smallTextRegular
                      .copyWith(color: AppColors.whiteColor.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
