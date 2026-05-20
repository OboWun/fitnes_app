import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../exercises/data/exercise_repository.dart';
import '../data/workout_session_repository.dart';
import '../domain/workout_session.dart';

class WorkoutHistoryPage extends ConsumerStatefulWidget {
  const WorkoutHistoryPage({super.key});

  @override
  ConsumerState<WorkoutHistoryPage> createState() =>
      _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends ConsumerState<WorkoutHistoryPage> {
  List<WorkoutSession> _sessions = [];
  Map<String, String> _exerciseNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(workoutSessionRepositoryProvider);
      final sessions =
          await repo.getAll(status: 'completed', limit: 20, sort: 'id_desc');
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
      _resolveNames(sessions);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resolveNames(List<WorkoutSession> sessions) async {
    final repo = ref.read(exerciseRepositoryProvider);
    final names = <String, String>{};
    final slugs = <String>{};
    for (final s in sessions) {
      for (final ex in s.exercises) {
        slugs.add(ex.exerciseSlug);
      }
    }
    for (final slug in slugs) {
      if (names.containsKey(slug)) continue;
      try {
        final detail = await repo.getExerciseDetail(slug);
        names[slug] = detail.name;
      } catch (_) {
        names[slug] = slug;
      }
    }
    if (mounted) setState(() => _exerciseNames = names);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),
      appBar: AppBar(title: const Text('История тренировок')),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.blackColor))
          : _sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: AppColors.gray3),
                      const SizedBox(height: 16),
                      Text(
                        'Нет завершённых тренировок',
                        style: AppTypography.largeTextMedium.copyWith(
                          color: AppColors.gray2,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return _SessionHistoryCard(
                      session: session,
                      exerciseNames: _exerciseNames,
                      onTap: () =>
                          context.push('/workout-session/${session.id}'),
                    );
                  },
                ),
    );
  }
}

class _SessionHistoryCard extends StatelessWidget {
  final WorkoutSession session;
  final Map<String, String> exerciseNames;
  final VoidCallback? onTap;

  const _SessionHistoryCard({
    required this.session,
    required this.exerciseNames,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalSets = session.exercises.fold<int>(
        0, (sum, ex) => sum + ex.setDetails.length);
    final completedSets = session.exercises.fold<int>(
      0,
      (sum, ex) =>
          sum + ex.setDetails.where((s) => s.completedAt != null).length,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _dayOfWeekLabel(session.dayOfWeek),
                    style: AppTypography.largeTextSemiBold.copyWith(
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
                Text(
                  '$completedSets/$totalSets',
                  style: AppTypography.smallTextSemiBold.copyWith(
                    color: AppColors.gray2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: session.exercises.map((ex) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    exerciseNames[ex.exerciseSlug] ?? ex.exerciseSlug,
                    style: AppTypography.smallTextRegular.copyWith(
                      color: AppColors.gray1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
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
