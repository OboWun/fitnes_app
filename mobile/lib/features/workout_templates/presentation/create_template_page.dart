import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../exercises/data/exercise_repository.dart';
import '../../workout_templates/data/workout_template_repository.dart';
import '../../workout_templates/domain/workout_exercise.dart';
import '../../workout_templates/domain/workout_template.dart';
import '../../workout_templates/template_list_provider.dart';

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
                  onSetsChanged: (v) => setState(() {
                    _exercises[i] = _ExerciseEntry(
                      slug: e.slug,
                      name: e.name,
                      sets: v,
                    );
                  }),
                  onDelete: () =>
                      setState(() => _exercises.removeAt(i)),
                ),
              );
            }),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickExercises,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: AppColors.gray1, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Добавить упражнение',
                      style: AppTypography.mediumTextMedium.copyWith(
                        color: AppColors.gray1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final String name;
  final int sets;
  final ValueChanged<int>? onSetsChanged;
  final VoidCallback? onDelete;

  const _ExerciseTile({
    required this.name,
    required this.sets,
    this.onSetsChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.drag_handle, color: AppColors.gray2, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.mediumTextSemiBold.copyWith(
                    color: AppColors.blackColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Подходы:',
                      style: AppTypography.smallTextRegular.copyWith(
                        color: AppColors.gray1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SmallButton(
                      icon: Icons.remove,
                      onTap: sets > 1
                          ? () => onSetsChanged?.call(sets - 1)
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$sets',
                        style: AppTypography.smallTextSemiBold.copyWith(
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    _SmallButton(
                      icon: Icons.add,
                      onTap: sets < 10
                          ? () => onSetsChanged?.call(sets + 1)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onDelete != null)
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(8),
              child:
                  Icon(Icons.close, color: AppColors.gray2, size: 20),
            ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SmallButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray3),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: AppColors.gray1),
      ),
    );
  }
}

class _ExerciseEntry {
  final String slug;
  final String name;
  final int sets;

  const _ExerciseEntry({required this.slug, required this.name, this.sets = 3});
}
