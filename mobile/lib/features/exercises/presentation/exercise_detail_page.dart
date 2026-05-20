import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/sliver_adapter.dart';
import '../../../core/widgets/sliver_gap.dart';
import '../../../design_system/design_system.dart';
import '../domain/exercise_short.dart';
import '../exercise_provider.dart';
import 'widgets/exercise_detail_content.dart';

class ExerciseDetailPage extends ConsumerWidget {
  final String slug;
  final bool isPickerMode;
  final bool isSelected;
  final ValueChanged<String>? onToggleSelect;

  const ExerciseDetailPage({
    super.key,
    required this.slug,
    this.isPickerMode = false,
    this.isSelected = false,
    this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(exerciseDetailProvider(slug));
    final expandedHeight = MediaQuery.sizeOf(context).height * 0.25;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: expandedHeight,
            collapsedHeight: 60,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  size: 20, color: AppColors.whiteColor),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (isPickerMode)
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Готово',
                    style: AppTypography.mediumTextSemiBold.copyWith(
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
            ],
            flexibleSpace: GradientFlexibleSpace(
              expandedHeight: expandedHeight,
              expandedChild: _buildExpandedChild(detailAsync),
              collapsedChild: _buildCollapsedChild(detailAsync),
            ),
          ),
          const SliverGap(vertical: 16),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverAdapter(
              child: detailAsync.when(
                data: (detail) => ExerciseDetailContent(
                  detail: detail,
                  onSimilarTap: (ExerciseShort e) =>
                      context.push('/exercises/${e.slug}'),
                ),
                loading: () =>
                    const ExerciseDetailContent.loading(),
                error: (e, __) => Center(
                  child: Text(
                    'Ошибка загрузки: $e',
                    style: AppTypography.mediumTextRegular
                        .copyWith(color: AppColors.gray2),
                  ),
                ),
              ),
            ),
          ),
          if (isPickerMode) const SliverGap(vertical: 80),
          if (!isPickerMode) const SliverGap(vertical: 24),
        ],
      ),
      bottomNavigationBar: isPickerMode
          ? _PickerBottomBar(
              isSelected: isSelected,
              onToggle: () => onToggleSelect?.call(slug),
            )
          : null,
    );
  }

  Widget _buildExpandedChild(AsyncValue detailAsync) {
    return detailAsync.whenOrNull(
          data: (detail) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    detail.name as String,
                    style: AppTypography.h3Bold
                        .copyWith(color: AppColors.whiteColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ) ??
        const SizedBox.shrink();
  }

  Widget _buildCollapsedChild(AsyncValue detailAsync) {
    return detailAsync.whenOrNull(
          data: (detail) => Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fitness_center,
                    size: 20, color: AppColors.whiteColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    detail.name as String,
                    style: AppTypography.mediumTextSemiBold
                        .copyWith(color: AppColors.whiteColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ) ??
        const Center(
          child: Icon(Icons.fitness_center,
              size: 24, color: AppColors.whiteColor),
        );
  }
}

class _PickerBottomBar extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onToggle;

  const _PickerBottomBar({required this.isSelected, this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: AppShadows.card,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: isSelected ? AppGradients.blueLinear : null,
              color: isSelected ? null : AppColors.gray3,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.add,
                  color: isSelected
                      ? AppColors.whiteColor
                      : AppColors.gray1,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isSelected ? 'Выбрано' : 'Выбрать',
                  style: AppTypography.largeTextSemiBold.copyWith(
                    color: isSelected
                        ? AppColors.whiteColor
                        : AppColors.gray1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
