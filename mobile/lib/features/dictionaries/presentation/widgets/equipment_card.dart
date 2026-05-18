import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/equipment_item.dart';

class EquipmentCard extends StatelessWidget {
  final EquipmentItem? _item;
  final VoidCallback? _onTap;

  const EquipmentCard({
    super.key,
    required EquipmentItem item,
    VoidCallback? onTap,
  })  : _item = item,
        _onTap = onTap;

  const EquipmentCard.loading({super.key})
      : _item = null,
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_item == null) return const _EquipmentCardLoading();
    return _EquipmentCardData(item: _item, onTap: _onTap);
  }
}

class _EquipmentCardData extends StatelessWidget {
  final EquipmentItem item;
  final VoidCallback? onTap;

  const _EquipmentCardData({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.blueLinear,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                ),
                child: item.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const _ImagePlaceholder(),
                        ),
                      )
                    : const _ImagePlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.mediumTextSemiBold
                        .copyWith(color: AppColors.blackColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: AppTypography.smallTextRegular
                          .copyWith(color: AppColors.gray1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.fitness_center,
        size: 40,
        color: AppColors.whiteColor.withValues(alpha: 0.6),
      ),
    );
  }
}

class _EquipmentCardLoading extends StatelessWidget {
  const _EquipmentCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Expanded(child: ShimmerCard(borderRadius: BorderRadius.zero)),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerCard(height: 14, borderRadius: BorderRadius.zero),
                SizedBox(height: 4),
                ShimmerCard(height: 12, borderRadius: BorderRadius.zero),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
