import 'package:flutter/material.dart';

import '../../../../core/widgets/sliver_adapter.dart';
import '../../../../core/widgets/sliver_decorated_box.dart';
import '../../../../design_system/design_system.dart';

class SliverContraindicationsStep extends StatelessWidget {
  final List<Map<String, dynamic>>? _items;
  final List<String>? _selected;
  final ValueChanged<String>? _onToggle;

  const SliverContraindicationsStep({
    super.key,
    required List<Map<String, dynamic>> items,
    required List<String> selected,
    ValueChanged<String>? onToggle,
  })  : _items = items,
        _selected = selected,
        _onToggle = onToggle;

  const SliverContraindicationsStep.loading({super.key})
      : _items = null,
        _selected = null,
        _onToggle = null;

  @override
  Widget build(BuildContext context) {
    if (_items == null || _selected == null) {
      return const _SliverContraindicationsLoading();
    }
    return _SliverContraindicationsData(
      items: _items,
      selected: _selected,
      onToggle: _onToggle,
    );
  }
}

class _SliverContraindicationsData extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final List<String> selected;
  final ValueChanged<String>? onToggle;

  const _SliverContraindicationsData({
    required this.items,
    required this.selected,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverDecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        sliver: SliverAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Противопоказания',
                style: AppTypography.h2Bold
                    .copyWith(color: AppColors.blackColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Необязательно. Мы исключим неподходящие упражнения',
                style: AppTypography.smallTextRegular
                    .copyWith(color: AppColors.gray1),
              ),
              const SizedBox(height: 24),
              if (items.isEmpty)
                Center(
                  child: Text(
                    'Нет противопоказаний',
                    style: AppTypography.mediumTextRegular
                        .copyWith(color: AppColors.gray2),
                  ),
                )
              else
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _ContraindicationItem(
                    name: items[i]['name'] as String,
                    isSelected:
                        selected.contains(items[i]['slug'] as String),
                    onTap: () =>
                        onToggle?.call(items[i]['slug'] as String),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContraindicationItem extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ContraindicationItem({
    required this.name,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? null : AppColors.borderColor,
          gradient: isSelected ? AppGradients.purpleLinear : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: isSelected ? AppColors.whiteColor : AppColors.gray2,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: AppTypography.mediumTextMedium.copyWith(
                  color: isSelected
                      ? AppColors.whiteColor
                      : AppColors.blackColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverContraindicationsLoading extends StatelessWidget {
  const _SliverContraindicationsLoading();

  @override
  Widget build(BuildContext context) {
    return SliverDecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        sliver: SliverAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Противопоказания',
                style: AppTypography.h2Bold
                    .copyWith(color: AppColors.blackColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Необязательно. Мы исключим неподходящие упражнения',
                style: AppTypography.smallTextRegular
                    .copyWith(color: AppColors.gray1),
              ),
              const SizedBox(height: 24),
              for (int i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                ShimmerCard(
                  height: 52,
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
