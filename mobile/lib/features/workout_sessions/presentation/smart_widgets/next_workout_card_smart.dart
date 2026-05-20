import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../home/home_provider.dart';
import '../../../home/domain/week_session.dart';
import '../widgets/next_workout_card.dart';

class NextWorkoutCardSmart extends ConsumerWidget {
  const NextWorkoutCardSmart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);

    return homeAsync.when(
      loading: () => const NextWorkoutCard.loading(),
      error: (_, __) => const SizedBox.shrink(),
      data: (homeData) {
        final todayStr =
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

        WeekSession? next;
        for (final s in homeData.weekSessions) {
          if (s.status != 'planned') continue;
          if ((s.date ?? '').compareTo(todayStr) < 0) continue;
          if (homeData.todaySession != null && s.id == homeData.todaySession!.id) continue;
          next = s;
          break;
        }

        if (next == null) return const SizedBox.shrink();

        return NextWorkoutCard(
          sessionId: next.id,
          dayOfWeek: next.dayOfWeek.name,
          description: next.description,
          exerciseCount: next.exerciseCount,
          onStartTap: () => context.push('/workout-session/${next!.id}'),
        );
      },
    );
  }
}
