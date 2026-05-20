import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../home/domain/week_session.dart';

class DayAssignmentTile extends StatelessWidget {
  final DayOfWeek day;
  final String? templateName;
  final VoidCallback? onTap;
  final VoidCallback? onAssign;
  final VoidCallback? onRemove;

  const DayAssignmentTile({
    super.key,
    required this.day,
    this.templateName,
    this.onTap,
    this.onAssign,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: templateName != null ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                day.shortName,
                style: AppTypography.mediumTextSemiBold.copyWith(
                  color: AppColors.blackColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: templateName != null
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            templateName!,
                            style: AppTypography.mediumTextMedium.copyWith(
                              color: AppColors.blackColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onRemove != null)
                          InkWell(
                            onTap: onRemove,
                            borderRadius: BorderRadius.circular(8),
                            child: Icon(Icons.close,
                                size: 18, color: AppColors.gray2),
                          ),
                        if (onTap != null) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right,
                              size: 18, color: AppColors.gray2),
                        ],
                      ],
                    )
                  : InkWell(
                      onTap: onAssign,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 18, color: AppColors.gray1),
                          const SizedBox(width: 4),
                          Text(
                            'Назначить шаблон',
                            style: AppTypography.smallTextMedium.copyWith(
                              color: AppColors.gray1,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
