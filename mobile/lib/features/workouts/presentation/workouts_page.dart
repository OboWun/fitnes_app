import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../training_plans/plan_list_provider.dart';
import '../../training_plans/presentation/widgets/plan_card.dart';
import '../../workout_templates/presentation/widgets/template_card.dart';
import '../../workout_templates/template_list_provider.dart';
import 'widgets/add_workout_fab.dart';

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(title: const Text('Тренировки')),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: AppGradients.blueLinear,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: AppColors.whiteColor,
                unselectedLabelColor: AppColors.gray1,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Шаблоны'),
                  Tab(text: 'Планы'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  TabBarView(
                    children: [
                      _TemplatesTab(),
                      _PlansTab(),
                    ],
                  ),
                  AddWorkoutFab(
                    onCoachTap: () => context.push('/workout-dialog'),
                    onTemplateTap: () => context.push('/workouts/new'),
                    onPlanTap: () => context.push('/training-plans/new'),
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

class _TemplatesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(templateListProvider);
    return listAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return Center(
            child: Text(
              'Нет шаблонов',
              style: AppTypography.mediumTextMedium
                  .copyWith(color: AppColors.gray2),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          itemCount: templates.length,
          addAutomaticKeepAlives: false,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final t = templates[index];
            return TemplateCard(
              template: t,
              onTap: () => context.push('/workouts/${t.id}'),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.blackColor),
      ),
      error: (e, _) => Center(
        child: Text('Ошибка: $e',
            style:
                AppTypography.mediumTextMedium.copyWith(color: AppColors.danger)),
      ),
    );
  }
}

class _PlansTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(planListProvider);
    return listAsync.when(
      data: (plans) {
        if (plans.isEmpty) {
          return Center(
            child: Text(
              'Нет планов',
              style: AppTypography.mediumTextMedium
                  .copyWith(color: AppColors.gray2),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          itemCount: plans.length,
          addAutomaticKeepAlives: false,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final p = plans[index];
            return PlanCard(
              plan: p,
              onTap: () => context.push('/training-plans/${p.id}'),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.blackColor),
      ),
      error: (e, _) => Center(
        child: Text('Ошибка: $e',
            style:
                AppTypography.mediumTextMedium.copyWith(color: AppColors.danger)),
      ),
    );
  }
}
