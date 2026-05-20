import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../exercises/data/exercise_repository.dart';
import '../data/workout_template_repository.dart';
import '../domain/workout_template.dart';
import '../template_list_provider.dart';

class _ExerciseInfo {
  final String name;
  final String? imageUrl;

  const _ExerciseInfo({required this.name, this.imageUrl});
}

class TemplateDetailPage extends ConsumerStatefulWidget {
  final String templateId;

  const TemplateDetailPage({super.key, required this.templateId});

  @override
  ConsumerState<TemplateDetailPage> createState() =>
      _TemplateDetailPageState();
}

class _TemplateDetailPageState extends ConsumerState<TemplateDetailPage> {
  WorkoutTemplate? _template;
  Map<String, _ExerciseInfo> _exerciseInfos = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(workoutTemplateRepositoryProvider);
      final template = await repo.getById(widget.templateId);
      if (!mounted) return;
      setState(() {
        _template = template;
        _isLoading = false;
      });
      _resolveInfos(template);
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

  Future<void> _resolveInfos(WorkoutTemplate template) async {
    final repo = ref.read(exerciseRepositoryProvider);
    final infos = <String, _ExerciseInfo>{};
    for (final ex in template.exercises) {
      try {
        final detail = await repo.getExerciseDetail(ex.exerciseSlug);
        infos[ex.exerciseSlug] = _ExerciseInfo(
          name: detail.name,
          imageUrl: detail.imageUrl,
        );
      } catch (_) {
        infos[ex.exerciseSlug] = _ExerciseInfo(name: ex.exerciseSlug);
      }
    }
    if (mounted) setState(() => _exerciseInfos = infos);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Удалить шаблон?',
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
      final repo = ref.read(workoutTemplateRepositoryProvider);
      await repo.delete(widget.templateId);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: const Text('Шаблон'),
        actions: [
          if (_template != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/workouts/${_template!.id}/edit',
                      extra: _template);
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
          : _template == null
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _template!.name,
                        style: AppTypography.h3Bold.copyWith(
                          color: AppColors.blackColor,
                        ),
                      ),
                      if (_template!.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _template!.description!,
                          style: AppTypography.mediumTextRegular.copyWith(
                            color: AppColors.gray1,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      ..._template!.exercises.map((ex) {
                        final info = _exerciseInfos[ex.exerciseSlug];
                        return _ExerciseTile(
                          name: info?.name ?? ex.exerciseSlug,
                          imageUrl: info?.imageUrl,
                          setsRepsLabel:
                              '${ex.sets} × ${ex.reps ?? '—'} повторений',
                          restLabel: ex.restBetweenSets != null
                              ? 'Отдых ${ex.restBetweenSets}с между подходами'
                              : null,
                          onTap: () => context.push('/exercises/${ex.exerciseSlug}'),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String setsRepsLabel;
  final String? restLabel;
  final VoidCallback onTap;

  const _ExerciseTile({
    required this.name,
    this.imageUrl,
    required this.setsRepsLabel,
    this.restLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.borderColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const _ImagePlaceholder(),
                          errorWidget: (_, __, ___) =>
                              const _ImagePlaceholder(),
                        )
                      : const _ImagePlaceholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.mediumTextSemiBold
                          .copyWith(color: AppColors.blackColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      setsRepsLabel,
                      style: AppTypography.smallTextRegular
                          .copyWith(color: AppColors.gray1),
                    ),
                    if (restLabel != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 13, color: AppColors.gray2),
                          const SizedBox(width: 4),
                          Text(
                            restLabel!,
                            style: AppTypography.captionMedium.copyWith(
                              color: AppColors.gray2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.gray2, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gray3,
      child: const Icon(
        Icons.fitness_center,
        color: AppColors.gray2,
        size: 24,
      ),
    );
  }
}
