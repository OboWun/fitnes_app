import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class WeightCard extends StatelessWidget {
  final int? _weight;
  final VoidCallback? _onUpdate;

  const WeightCard({
    super.key,
    required int weight,
    VoidCallback? onUpdate,
  })  : _weight = weight,
        _onUpdate = onUpdate;

  const WeightCard.loading({super.key})
      : _weight = null,
        _onUpdate = null;

  @override
  Widget build(BuildContext context) {
    if (_weight == null) return const _WeightCardLoading();
    return _WeightCardData(weight: _weight, onUpdate: _onUpdate);
  }
}

class _WeightCardData extends StatelessWidget {
  final int weight;
  final VoidCallback? onUpdate;

  const _WeightCardData({required this.weight, this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppGradients.blueLinear,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.monitor_weight_outlined,
              color: AppColors.whiteColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Вес',
                  style: AppTypography.mediumTextRegular
                      .copyWith(color: AppColors.gray1),
                ),
                Text(
                  '$weight кг',
                  style: AppTypography.largeTextSemiBold
                      .copyWith(color: AppColors.blackColor),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onUpdate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppGradients.blueLinear,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppShadows.blue,
              ),
              child: Text(
                'Обновить',
                style: AppTypography.mediumTextSemiBold
                    .copyWith(color: AppColors.whiteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightCardLoading extends StatelessWidget {
  const _WeightCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          ShimmerCard(width: 40, height: 40, borderRadius: BorderRadius.zero),
          SizedBox(width: 12),
          Expanded(child: ShimmerCard(height: 40)),
        ],
      ),
    );
  }
}
