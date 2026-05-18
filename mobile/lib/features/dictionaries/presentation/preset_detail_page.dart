import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/sliver_adapter.dart';
import '../../../../core/widgets/sliver_gap.dart';
import '../../../../design_system/design_system.dart';
import '../../profile/domain/equipment_preset.dart';
import '../equipment_provider.dart';
import 'widgets/preset_equipment_item.dart';

class PresetDetailPage extends ConsumerWidget {
  final String presetId;

  const PresetDetailPage({super.key, required this.presetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(allPresetsProvider);
    final preset = presetsAsync.whenOrNull(
      data: (presets) =>
          presets.where((p) => p.id == presetId).firstOrNull,
    );

    final expandedHeight = MediaQuery.sizeOf(context).height * 0.25;
    final isSystem = preset?.isSystem ?? true;
    final gradient =
        isSystem ? AppGradients.blueLinear : AppGradients.progressBarLinear;
    final icon = isSystem
        ? Icons.inventory_2_outlined
        : Icons.edit_outlined;

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
              gradient: gradient,
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
                      child: Icon(icon, size: 40,
                          color: AppColors.whiteColor),
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        preset?.name ?? 'Пресет',
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
                    Icon(icon, size: 24, color: AppColors.whiteColor),
                    const SizedBox(width: 8),
                    Text(
                      preset?.name ?? 'Пресет',
                      style: AppTypography.mediumTextSemiBold
                          .copyWith(color: AppColors.whiteColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (preset != null) ...[
            SliverAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: () {
                      if (isSystem) {
                        context.push('/equipment/presets/new',
                            extra: preset);
                      } else {
                        context.push(
                            '/equipment/presets/${preset.id}/edit',
                            extra: preset);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.blue,
                      ),
                      child: Center(
                        child: Text(
                          isSystem
                              ? 'Использовать шаблон'
                              : 'Редактировать',
                          style: AppTypography.largeTextSemiBold
                              .copyWith(color: AppColors.whiteColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverGap(vertical: 16),
            SliverAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Оборудование (${preset.equipmentSlugs.length})',
                      style: AppTypography.largeTextSemiBold
                          .copyWith(color: AppColors.blackColor),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    for (int i = 0;
                        i < preset.equipmentSlugs.length;
                        i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      PresetEquipmentItem(
                        name: i < preset.equipmentDetails.length
                            ? preset.equipmentDetails[i].name
                            : preset.equipmentSlugs[i],
                        onTap: () => context.push(
                            '/equipment/${preset.equipmentSlugs[i]}'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (preset.equipmentSlugs.isEmpty)
              SliverAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Пустой пресет',
                        style: AppTypography.mediumTextRegular
                            .copyWith(color: AppColors.gray2),
                      ),
                    ),
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
