import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/sliver_adapter.dart';
import '../../../core/widgets/sliver_gap.dart';
import '../../auth/public.dart';
import '../../../design_system/design_system.dart';
import 'smart_widgets/contraindications_section_smart.dart';
import 'smart_widgets/equipment_section_smart.dart';
import 'smart_widgets/weight_card_smart.dart';
import 'smart_widgets/weight_chart_smart.dart';
import 'smart_widgets/workout_history_section_smart.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.select((s) => s.user));
    final expandedHeight = MediaQuery.sizeOf(context).height * 0.3;

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
              expandedChild: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                            AppColors.whiteColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        user?.name ?? 'Атлет',
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
                      Icons.person_outline,
                      size: 24,
                      color: AppColors.whiteColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user?.name ?? 'Атлет',
                      style: AppTypography.mediumTextSemiBold
                          .copyWith(color: AppColors.whiteColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverGap(vertical: 16),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverAdapter(child: WeightChartSmart()),
          ),
          const SliverGap(vertical: 12),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverAdapter(child: WeightCardSmart()),
          ),
          const SliverGap(vertical: 24),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverAdapter(child: ContraindicationsSectionSmart()),
          ),
          const SliverGap(vertical: 24),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverAdapter(child: WorkoutHistorySectionSmart()),
          ),
          const SliverGap(vertical: 24),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverAdapter(child: EquipmentSectionSmart()),
          ),
          const SliverGap(vertical: 24),
        ],
      ),
    );
  }
}
