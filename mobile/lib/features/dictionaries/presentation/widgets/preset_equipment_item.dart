import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class PresetEquipmentItem extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;

  const PresetEquipmentItem({
    super.key,
    required this.name,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            Icon(Icons.chevron_right, color: AppColors.gray2, size: 20),
          ],
        ),
      ),
    );
  }
}
