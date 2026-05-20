import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../home/domain/week_session.dart';
import '../../home/home_provider.dart';
import '../../workout_templates/data/workout_template_repository.dart';
import '../data/training_plan_repository.dart';
import '../domain/plan_schedule_item.dart';
import '../domain/training_plan.dart';
import '../plan_list_provider.dart';
import '../presentation/widgets/day_assignment_tile.dart';

class PlanDetailPage extends ConsumerStatefulWidget {
  final String planId;

  const PlanDetailPage({super.key, required this.planId});

  @override
  ConsumerState<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends ConsumerState<PlanDetailPage> {
  TrainingPlan? _plan;
  Map<String, String> _templateNames = {};
  bool _isLoading = true;

  static const _days = DayOfWeek.values;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(trainingPlanRepositoryProvider);
      final plan = await repo.getById(widget.planId);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _isLoading = false;
      });
      _resolveTemplateNames(plan);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _resolveTemplateNames(TrainingPlan plan) async {
    final repo = ref.read(workoutTemplateRepositoryProvider);
    final names = <String, String>{};
    for (final item in plan.schedule) {
      if (names.containsKey(item.workoutTemplateId)) continue;
      try {
        final t = await repo.getById(item.workoutTemplateId);
        names[t.id] = t.name;
      } catch (_) {
        names[item.workoutTemplateId] = item.name ?? item.workoutTemplateId;
      }
    }
    if (mounted) setState(() => _templateNames = names);
  }

  Future<void> _activate() async {
    try {
      final repo = ref.read(trainingPlanRepositoryProvider);
      await repo.activate(widget.planId);
      if (mounted) {
        ref.read(planListProvider.notifier).refresh();
        ref.read(homeProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('План активирован!')),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Удалить план?',
            style: AppTypography.mediumTextSemiBold
                .copyWith(color: AppColors.blackColor)),
        content: Text('Это действие нельзя отменить.',
            style: AppTypography.mediumTextRegular
                .copyWith(color: AppColors.gray1)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Отмена',
                style: AppTypography.mediumTextMedium
                    .copyWith(color: AppColors.gray1)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Удалить',
                style: AppTypography.mediumTextMedium
                    .copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final repo = ref.read(trainingPlanRepositoryProvider);
        await repo.delete(widget.planId);
        if (mounted) {
          ref.read(planListProvider.notifier).refresh();
          ref.read(homeProvider.notifier).refresh();
          Navigator.of(context).pop();
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: const Text('План'),
        actions: [
          if (_plan != null && !_plan!.isActive)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/training-plans/${_plan!.id}/edit',
                      extra: _plan);
                } else if (value == 'delete') {
                  _delete();
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'edit', child: Text('Редактировать')),
                const PopupMenuItem(
                    value: 'delete', child: Text('Удалить')),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.blackColor))
          : _plan == null
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _plan!.name,
                              style: AppTypography.h3Bold.copyWith(
                                  color: AppColors.blackColor),
                            ),
                          ),
                          if (_plan!.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: AppGradients.purpleLinear,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Активный',
                                style: AppTypography.smallTextSemiBold
                                    .copyWith(color: AppColors.whiteColor),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ..._days.map((day) {
                        final item = _plan!.schedule.firstWhere(
                          (s) => s.dayOfWeek == day.name,
                          orElse: () => PlanScheduleItem(
                              dayOfWeek: '', workoutTemplateId: ''),
                        );
                        if (item.dayOfWeek.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: DayAssignmentTile(
                            day: day,
                            templateName:
                                _templateNames[item.workoutTemplateId] ??
                                    item.name,
                            onTap: () => context.push(
                                '/workouts/${item.workoutTemplateId}'),
                          ),
                        );
                      }),
                      if (!_plan!.isActive &&
                          _plan!.schedule.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: InkWell(
                            onTap: _activate,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppGradients.blueLinear,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Активировать',
                                style: AppTypography.largeTextSemiBold
                                    .copyWith(color: AppColors.whiteColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
