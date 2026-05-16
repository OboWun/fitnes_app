import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class ViewAllLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const ViewAllLink({
    super.key,
    this.label = 'Посмотреть все',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: AppTypography.mediumTextMedium.copyWith(
                color: AppGradients.blueLinear.colors.first,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: AppGradients.blueLinear.colors.first,
            ),
          ],
        ),
      ),
    );
  }
}
