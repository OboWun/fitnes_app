import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/sliver_adapter.dart';
import '../../../../core/widgets/sliver_gap.dart';
import '../../../../design_system/design_system.dart';
import '../equipment_provider.dart';
import 'widgets/exercise_section.dart';
import 'widgets/preset_card.dart';

class EquipmentDetailPage extends ConsumerWidget {
  final String slug;

  const EquipmentDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentAsync = ref.watch(allEquipmentProvider);
    final exercisesAsync = ref.watch(equipmentExercisesProvider(slug));
    final presetsAsync = ref.watch(allPresetsProvider);

    final item = equipmentAsync.whenOrNull(
      data: (items) => items.where((e) => e.slug == slug).firstOrNull,
    );

    final filteredPresets = presetsAsync.whenOrNull(
      data: (presets) =>
          presets.where((p) => p.equipmentSlugs.contains(slug)).toList(),
    );

    final hasExercises = exercisesAsync.whenOrNull(
      data: (exercises) => exercises.isNotEmpty,
    );

    final expandedHeight = MediaQuery.sizeOf(context).height * 0.28;

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
              icon: const Icon(Icons.arrow_back_ios, size: 20,
                  color: AppColors.whiteColor),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: GradientFlexibleSpace(
              expandedHeight: expandedHeight,
              borderRadius: BorderRadius.zero,
              expandedChild: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor
                            .withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: item?.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.network(
                                item!.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(
                                  Icons.fitness_center,
                                  size: 40,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.fitness_center,
                              size: 40,
                              color: AppColors.whiteColor,
                            ),
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item?.name ?? 'Инвентарь',
                        style: AppTypography.h3Bold.copyWith(
                            color: AppColors.whiteColor),
                      ),
                    ),
                  ],
                ),
              ),
              collapsedChild: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      size: 24,
                      color: AppColors.whiteColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item?.name ?? 'Инвентарь',
                      style: AppTypography.mediumTextSemiBold
                          .copyWith(color: AppColors.whiteColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item?.description ?? 'Описание недоступно',
                    style: AppTypography.mediumTextRegular
                        .copyWith(color: AppColors.gray1),
                  ),
                ],
              ),
            ),
          ),
          if (filteredPresets != null && filteredPresets.isNotEmpty) ...[
            const SliverGap(vertical: 24),
            SliverAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Пресеты',
                  style: AppTypography.largeTextSemiBold
                      .copyWith(color: AppColors.blackColor),
                ),
              ),
            ),
            const SliverGap(vertical: 12),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredPresets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) => PresetCard(
                      preset: filteredPresets[index],
                      onTap: () => context.push(
                          '/equipment/presets/${filteredPresets[index].id}'),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (hasExercises == true) ...[
            const SliverGap(vertical: 24),
            SliverAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: exercisesAsync.when(
                  data: (exercises) => ExerciseSection(
                    exercises: exercises,
                    onExerciseTap: (e) =>
                        context.push('/exercises/${e.slug}'),
                    onViewAll: () =>
                        context.push('/exercises?equipment=$slug'),
                  ),
                  loading: () => const ExerciseSection.loading(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),
          ],
          const SliverGap(vertical: 24),
        ],
      ),
    );
  }
}
