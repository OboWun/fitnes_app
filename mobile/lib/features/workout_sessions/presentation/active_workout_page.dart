import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../exercises/data/exercise_repository.dart';
import '../../home/home_provider.dart';
import '../data/workout_session_repository.dart';
import '../domain/complete_set_entry.dart';
import '../domain/session_exercise.dart';
import '../domain/workout_session.dart';
import '../domain/workout_set.dart';
import 'widgets/exercise_block.dart';
import 'widgets/rest_timer_overlay.dart';
import 'widgets/workout_progress_bar.dart';

part '_skip_dialog.dart';

class ActiveWorkoutPage extends ConsumerStatefulWidget {
  final String sessionId;

  const ActiveWorkoutPage({super.key, required this.sessionId});

  @override
  ConsumerState<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends ConsumerState<ActiveWorkoutPage> {
  WorkoutSession? _session;
  Map<String, String> _exerciseNames = {};
  final Map<String, WorkoutSet> _updatedSets = {};
  bool _isLoading = true;
  bool _isCompleting = false;

  int? _restDurationSec;
  RestType _restType = RestType.betweenSets;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(workoutSessionRepositoryProvider);
      final session = await repo.getById(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _session = session;
        _isLoading = false;
      });
      _resolveNames(session);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _resolveNames(WorkoutSession session) async {
    final repo = ref.read(exerciseRepositoryProvider);
    final names = <String, String>{};
    for (final ex in session.exercises) {
      try {
        final detail = await repo.getExerciseDetail(ex.exerciseSlug);
        names[ex.exerciseSlug] = detail.name;
      } catch (_) {
        names[ex.exerciseSlug] = ex.exerciseSlug;
      }
    }
    if (mounted) setState(() => _exerciseNames = names);
  }

  static String _setKey(String slug, int setNumber) => '${slug}_$setNumber';

  void _onSetChanged(String exerciseSlug, WorkoutSet updated) {
    setState(() {
      _updatedSets[_setKey(exerciseSlug, updated.setNumber)] = updated;
    });

    if (updated.completedAt != null) {
      _startRestFor(exerciseSlug, updated.setNumber);
    }
  }

  void _startRestFor(String exerciseSlug, int completedSetNumber) {
    final ex = _session?.exercises.firstWhere(
      (e) => e.exerciseSlug == exerciseSlug,
      orElse: () => SessionExercise(
        exerciseSlug: '',
        sets: 0,
        order: 0,
      ),
    );
    if (ex == null || ex.exerciseSlug.isEmpty) return;

    final merged = _mergedSets(ex);
    final currentIdx =
        merged.indexWhere((s) => s.setNumber == completedSetNumber);
    final isLastSet = currentIdx >= merged.length - 1;

    int? restSec;
    if (isLastSet) {
      restSec = ex.restAfterExercise;
    } else {
      restSec = ex.restBetweenSets;
    }

    if (restSec != null && restSec > 0) {
      setState(() {
        _restDurationSec = restSec;
        _restType =
            isLastSet ? RestType.afterExercise : RestType.betweenSets;
      });
    }
  }

  void _onRestSkip() {
    setState(() => _restDurationSec = null);
  }

  List<WorkoutSet> _mergedSets(SessionExercise ex) {
    return ex.setDetails.map((s) {
      final key = _setKey(ex.exerciseSlug, s.setNumber);
      return _updatedSets[key] ?? s;
    }).toList();
  }

  int get _totalSets {
    if (_session == null) return 0;
    return _session!.exercises.fold<int>(
        0, (sum, ex) => sum + ex.setDetails.length);
  }

  int get _completedSets {
    var count = 0;
    for (final ex in _session?.exercises ?? <SessionExercise>[]) {
      for (final s in ex.setDetails) {
        final key = _setKey(ex.exerciseSlug, s.setNumber);
        final merged = _updatedSets[key] ?? s;
        if (merged.completedAt != null) count++;
      }
    }
    return count;
  }

  Future<void> _complete() async {
    if (_session == null) return;
    setState(() => _isCompleting = true);

    try {
      final entries = <CompleteSetEntry>[];
      for (final ex in _session!.exercises) {
        for (final s in ex.setDetails) {
          final key = _setKey(ex.exerciseSlug, s.setNumber);
          final merged = _updatedSets[key] ?? s;
          if (merged.completedAt != null) {
            entries.add(CompleteSetEntry(
              exerciseSlug: ex.exerciseSlug,
              setNumber: merged.setNumber,
              actualWeightKg: merged.actualWeightKg,
              actualReps: merged.actualReps,
              actualDurationSec: merged.actualDurationSec,
              actualDistanceM: merged.actualDistanceM,
              actualRpe: merged.actualRpe,
            ));
          }
        }
      }

      if (entries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выполните хотя бы один подход')),
        );
        setState(() => _isCompleting = false);
        return;
      }

      final repo = ref.read(workoutSessionRepositoryProvider);
      await repo.complete(_session!.id, entries);
      if (mounted) {
        ref.read(homeProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Тренировка завершена!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
      setState(() => _isCompleting = false);
    }
  }

  Future<void> _skip() async {
    final reschedule = await showDialog<bool>(
      context: context,
      builder: (_) => const _SkipDialog(),
    );
    if (reschedule == null || _session == null || !mounted) return;

    try {
      final repo = ref.read(workoutSessionRepositoryProvider);
      await repo.skip(_session!.id, reschedule: reschedule);
      if (mounted) {
        ref.read(homeProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Тренировка пропущена')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),
      appBar: AppBar(
        title: Text(_session != null
            ? _dayOfWeekLabel(_session!.dayOfWeek)
            : 'Тренировка'),
        actions: [
          if (_session != null && _session!.status == 'planned')
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'skip') _skip();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'skip', child: Text('Пропустить')),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.blackColor))
          : _session == null
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: WorkoutProgressBar(
                        completed: _completedSets,
                        total: _totalSets,
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _session!.exercises.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ex = _session!.exercises[index];
                          return ExerciseBlock(
                            exerciseName:
                                _exerciseNames[ex.exerciseSlug] ??
                                    ex.exerciseSlug,
                            sets: _mergedSets(ex),
                            onSetChanged: (updated) =>
                                _onSetChanged(ex.exerciseSlug, updated),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: _isLoading || _session == null
          ? null
          : _restDurationSec != null
              ? RestTimerOverlay(
                  durationSec: _restDurationSec!,
                  restType: _restType,
                  onSkip: _onRestSkip,
                )
              : _session!.status == 'planned'
                  ? _BottomBar(
                      isCompleting: _isCompleting,
                      canComplete: _completedSets > 0,
                      onComplete: _complete,
                    )
                  : null,
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool isCompleting;
  final bool canComplete;
  final VoidCallback onComplete;

  const _BottomBar({
    required this.isCompleting,
    required this.canComplete,
    required this.onComplete,
  });

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
        child: ElevatedButton(
          onPressed: isCompleting || !canComplete ? null : onComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppGradients.blueLinear.colors.first,
            foregroundColor: AppColors.whiteColor,
            disabledBackgroundColor: AppColors.gray3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isCompleting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.whiteColor,
                  ),
                )
              : Text(
                  canComplete
                      ? 'Завершить тренировку'
                      : 'Выполните подходы',
                  style: AppTypography.largeTextSemiBold,
                ),
        ),
      ),
    );
  }
}

String _dayOfWeekLabel(String day) {
  return switch (day.toLowerCase()) {
    'monday' => 'Понедельник',
    'tuesday' => 'Вторник',
    'wednesday' => 'Среда',
    'thursday' => 'Четверг',
    'friday' => 'Пятница',
    'saturday' => 'Суббота',
    'sunday' => 'Воскресенье',
    _ => day,
  };
}
