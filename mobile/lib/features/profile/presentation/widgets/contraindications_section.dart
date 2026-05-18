import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class ContraindicationsSection extends StatelessWidget {
  final List<String>? _items;
  final VoidCallback? _onEdit;

  const ContraindicationsSection({
    super.key,
    required List<String> items,
    VoidCallback? onEdit,
  })  : _items = items,
        _onEdit = onEdit;

  const ContraindicationsSection.loading({super.key})
      : _items = null,
        _onEdit = null;

  @override
  Widget build(BuildContext context) {
    if (_items == null) return const _ContraindicationsLoading();
    return _ContraindicationsData(items: _items, onEdit: _onEdit);
  }
}

class _ContraindicationsData extends StatelessWidget {
  final List<String> items;
  final VoidCallback? onEdit;

  const _ContraindicationsData({required this.items, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Противопоказания',
                style: AppTypography.largeTextSemiBold
                    .copyWith(color: AppColors.blackColor),
              ),
            ),
            if (onEdit != null)
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(8),
                child: Text(
                  'Редактировать',
                  style: AppTypography.mediumTextMedium.copyWith(
                    color: const Color(0xFF92A3FD),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Text(
            'Нет противопоказаний',
            style: AppTypography.mediumTextRegular
                .copyWith(color: AppColors.gray2),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((name) => _ContraindicationChip(name: name))
                .toList(),
          ),
      ],
    );
  }
}

class _ContraindicationChip extends StatelessWidget {
  final String name;

  const _ContraindicationChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppGradients.purpleLinear,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.health_and_safety_outlined,
              size: 14, color: AppColors.whiteColor),
          const SizedBox(width: 4),
          Text(
            name,
            style: AppTypography.smallTextMedium
                .copyWith(color: AppColors.whiteColor),
          ),
        ],
      ),
    );
  }
}

class _ContraindicationsLoading extends StatelessWidget {
  const _ContraindicationsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Противопоказания',
          style: AppTypography.largeTextSemiBold
              .copyWith(color: AppColors.blackColor),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            ShimmerCard(width: 80, height: 28),
            SizedBox(width: 8),
            ShimmerCard(width: 100, height: 28),
          ],
        ),
      ],
    );
  }
}
