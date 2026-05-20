import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/dialog_option.dart';

class PresetOptions extends StatelessWidget {
  final List<DialogOption> options;
  final ValueChanged<String> onSelect;

  const PresetOptions({
    super.key,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        addAutomaticKeepAlives: false,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final opt = options[index];
          final isSystem = opt.value.startsWith('preset:system-') ||
              _isKnownSystemPreset(opt.value);
          final isManual = opt.value == 'manual';
          final isBodyweight = opt.value == 'bodyweight_only';

          return _PresetCard(
            label: opt.label,
            isSystem: isSystem,
            isUser: !isSystem && !isManual && !isBodyweight,
            icon: isManual
                ? Icons.tune
                : isBodyweight
                    ? Icons.accessibility_new
                    : Icons.inventory_2_outlined,
            onTap: () => onSelect(opt.value),
          );
        },
      ),
    );
  }

  bool _isKnownSystemPreset(String value) {
    if (!value.startsWith('preset:')) return false;
    const systemIds = {
      'preset-gym-full',
      'preset-gym-basic',
      'preset-home',
      'preset-bodyweight',
      'preset-outdoor',
    };
    return systemIds.contains(value.substring(7));
  }
}

class _PresetCard extends StatelessWidget {
  final String label;
  final bool isSystem;
  final bool isUser;
  final IconData icon;
  final VoidCallback onTap;

  const _PresetCard({
    required this.label,
    required this.isSystem,
    required this.isUser,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minWidth: 120, maxWidth: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppGradients.blueLinear,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.whiteColor, size: 18),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.smallTextSemiBold.copyWith(
                      color: AppColors.blackColor,
                    ),
                  ),
                  if (isSystem)
                    Text(
                      'Системный',
                      style: AppTypography.captionRegular.copyWith(
                        color: AppColors.gray2,
                      ),
                    )
                  else if (isUser)
                    Text(
                      'Мой',
                      style: AppTypography.captionRegular.copyWith(
                        color: AppColors.gray2,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
