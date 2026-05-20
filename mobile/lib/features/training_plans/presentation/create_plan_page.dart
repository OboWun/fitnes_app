import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../home/domain/week_session.dart';
import '../data/training_plan_repository.dart';
import '../domain/plan_schedule_item.dart';
import '../domain/training_plan.dart';
import '../plan_list_provider.dart';
import '../presentation/widgets/day_assignment_tile.dart';
import '../presentation/widgets/template_picker_sheet.dart';
import '../../workout_templates/domain/workout_template.dart';

class CreatePlanPage extends ConsumerStatefulWidget {
  final TrainingPlan? existing;

  const CreatePlanPage({super.key, this.existing});

  @override
  ConsumerState<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends ConsumerState<CreatePlanPage> {
  final _nameController = TextEditingController();
  final _assignments = <String, _DayAssignment>{};
  bool _isSaving = false;

  static const _days = DayOfWeek.values;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final p = widget.existing!;
      _nameController.text = p.name;
      for (final s in p.schedule) {
        _assignments[s.dayOfWeek] = _DayAssignment(
          templateId: s.workoutTemplateId,
          templateName: s.name ?? s.workoutTemplateId,
          time: s.time,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickTemplate(String dayOfWeek) async {
    final template = await showModalBottomSheet<WorkoutTemplate>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TemplatePickerSheet(),
    );
    if (template == null) return;

    final assignment = _assignments[dayOfWeek];
    setState(() {
      _assignments[dayOfWeek] = _DayAssignment(
        templateId: template.id,
        templateName: template.name,
        time: assignment?.time,
      );
    });
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(trainingPlanRepositoryProvider);
      final schedule = _assignments.entries
          .map((e) => PlanScheduleItem(
                dayOfWeek: e.key,
                workoutTemplateId: e.value.templateId,
                time: e.value.time,
                name: e.value.templateName,
                sortOrder: _days.indexWhere((d) => d.name == e.key),
              ))
          .toList();

      if (_isEdit) {
        await repo.update(
          widget.existing!.id,
          name: _nameController.text.trim(),
          schedule: schedule,
        );
      } else {
        await repo.create(
          name: _nameController.text.trim(),
          schedule: schedule,
        );
      }
      if (mounted) {
        ref.read(planListProvider.notifier).refresh();
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
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(_isEdit ? 'Редактирование плана' : 'Новый план'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Сохранить',
                    style: AppTypography.mediumTextSemiBold.copyWith(
                      color: AppColors.blackColor,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название плана'),
            ),
            const SizedBox(height: 20),
            Text(
              'Расписание',
              style: AppTypography.h4Bold.copyWith(color: AppColors.blackColor),
            ),
            const SizedBox(height: 12),
            ..._days.map((day) {
              final assignment = _assignments[day.name];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DayAssignmentTile(
                  day: day,
                  templateName: assignment?.templateName,
                  onAssign: () => _pickTemplate(day.name),
                  onRemove: assignment != null
                      ? () => setState(() => _assignments.remove(day.name))
                      : null,
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DayAssignment {
  final String templateId;
  final String templateName;
  final String? time;

  const _DayAssignment({
    required this.templateId,
    required this.templateName,
    this.time,
  });
}
