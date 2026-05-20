import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../exercises/data/exercise_repository.dart';
import '../../workout_templates/data/workout_template_repository.dart';
import '../../workout_templates/domain/workout_exercise.dart';
import '../../workout_templates/domain/workout_template.dart';
import '../../workout_templates/template_list_provider.dart';

part '_widgets.dart';

class CreateTemplatePage extends ConsumerStatefulWidget {
  final WorkoutTemplate? existing;

  const CreateTemplatePage({super.key, this.existing});

  @override
  ConsumerState<CreateTemplatePage> createState() =>
      _CreateTemplatePageState();
}

class _CreateTemplatePageState extends ConsumerState<CreateTemplatePage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _exercises = <_ExerciseEntry>[];
  bool _isSaving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final t = widget.existing!;
      _nameController.text = t.name;
      _descController.text = t.description ?? '';
      _exercises.addAll(
        t.exercises.map((e) => _ExerciseEntry(
              slug: e.exerciseSlug,
              name: e.exerciseSlug,
              sets: e.sets,
              restBetweenSets: e.restBetweenSets,
              restAfterExercise: e.restAfterExercise,
            )),
      );
      _resolveNames();
    }
  }

  Future<void> _resolveNames() async {
    final repo = ref.read(exerciseRepositoryProvider);
    for (int i = 0; i < _exercises.length; i++) {
      if (_exercises[i].name == _exercises[i].slug) {
        try {
          final detail = await repo.getExerciseDetail(_exercises[i].slug);
          if (mounted) {
            setState(() {
              _exercises[i] = _ExerciseEntry(
                slug: _exercises[i].slug,
                name: detail.name,
                sets: _exercises[i].sets,
                restBetweenSets: _exercises[i].restBetweenSets,
                restAfterExercise: _exercises[i].restAfterExercise,
              );
            });
          }
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty || _exercises.isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(workoutTemplateRepositoryProvider);
      final exercises = _exercises
          .asMap()
          .entries
          .map((e) => WorkoutExercise(
                exerciseSlug: e.value.slug,
                sets: e.value.sets,
                order: e.key + 1,
                restBetweenSets: e.value.restBetweenSets,
                restAfterExercise: e.value.restAfterExercise,
              ))
          .toList();

      if (_isEdit) {
        await repo.update(
          widget.existing!.id,
          name: _nameController.text.trim(),
          description: _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : null,
          exercises: exercises,
        );
      } else {
        await repo.create(
          name: _nameController.text.trim(),
          description: _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : null,
          exercises: exercises,
        );
      }

      if (mounted) {
        ref.read(templateListProvider.notifier).refresh();
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

  Future<void> _pickExercises() async {
    final selected = await context.push<Set<String>>(
      '/exercises-picker',
      extra: _exercises.map((e) => e.slug).toSet(),
    );
    if (selected == null || !mounted) return;

    final existing = _exercises.map((e) => e.slug).toSet();
    final added = selected.difference(existing);
    final removed = existing.difference(selected);

    setState(() {
      _exercises.removeWhere((e) => removed.contains(e.slug));
      for (final slug in added) {
        _exercises.add(_ExerciseEntry(slug: slug, name: slug));
      }
    });
    _resolveNames();
  }

  void _update(int i, {int? sets, int? restBetween, int? restAfter}) {
    final e = _exercises[i];
    setState(() => _exercises[i] = _ExerciseEntry(
      slug: e.slug,
      name: e.name,
      sets: sets ?? e.sets,
      restBetweenSets: restBetween ?? e.restBetweenSets,
      restAfterExercise: restAfter ?? e.restAfterExercise,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(_isEdit ? 'Редактирование' : 'Новый шаблон'),
        actions: [
          TextButton(
            onPressed: _isSaving ||
                    _nameController.text.trim().isEmpty ||
                    _exercises.isEmpty
                ? null
                : _save,
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
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Описание (необязательно)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            Text(
              'Упражнения',
              style: AppTypography.h4Bold.copyWith(
                color: AppColors.blackColor,
              ),
            ),
            const SizedBox(height: 12),
            ..._exercises.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ExerciseTile(
                  name: e.name,
                  sets: e.sets,
                  restBetweenSets: e.restBetweenSets,
                  restAfterExercise: e.restAfterExercise,
                  onSetsChanged: (v) => _update(i, sets: v),
                  onRestBetweenSetsChanged: (v) =>
                      _update(i, restBetween: v),
                  onRestAfterExerciseChanged: (v) =>
                      _update(i, restAfter: v),
                  onDelete: () =>
                      setState(() => _exercises.removeAt(i)),
                ),
              );
            }),
            const SizedBox(height: 8),
            _AddExerciseButton(onTap: _pickExercises),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
