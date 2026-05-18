import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../profile_provider.dart';
import '../widgets/workout_history_section.dart';

class WorkoutHistorySectionSmart extends ConsumerWidget {
  const WorkoutHistorySectionSmart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(recentSessionsProvider);

    return sessionsAsync.when(
      data: (sessions) => WorkoutHistorySection(
        sessions: sessions,
        onSessionTap: (id) => context.push('/workouts/$id'),
        onViewAll: () => context.push('/workouts'),
      ),
      loading: () => const WorkoutHistorySection.loading(),
      error: (_, __) => const WorkoutHistorySection(
        sessions: [],
      ),
    );
  }
}
