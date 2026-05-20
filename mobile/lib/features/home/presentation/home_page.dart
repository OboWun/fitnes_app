import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../home_provider.dart';
import 'smart_widgets/dictionary_grid_smart.dart';
import 'smart_widgets/profile_header_smart.dart';
import 'smart_widgets/program_action_grid_smart.dart';
import 'smart_widgets/trainer_chat_card_smart.dart';
import 'smart_widgets/view_all_link_smart.dart';
import 'smart_widgets/week_calendar_smart.dart';
import '../../workout_sessions/presentation/smart_widgets/next_workout_card_smart.dart';
import 'widgets/section_header.dart';
import 'widgets/workout_reminder.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);
    final hasActivePlan = homeAsync.value?.activeBlock != null;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileHeaderSmart(),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Тренировки'),
              const SizedBox(height: 16),
              const WeekCalendarSmart(),
              if (homeAsync.value?.todaySession != null) ...[
                const SizedBox(height: 16),
                WorkoutReminder(
                  session: homeAsync.value!.todaySession!,
                  onTap: () => context.push(
                    '/workout-session/${homeAsync.value!.todaySession!.id}',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (!hasActivePlan)
                const ProgramActionGridSmart(),
              if (hasActivePlan)
                const NextWorkoutCardSmart(),
              const SizedBox(height: 12),
              const ViewAllLinkSmart(route: '/workouts'),
              const SizedBox(height: 24),
              const TrainerChatCardSmart(),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Справочник'),
              const SizedBox(height: 16),
              const DictionaryGridSmart(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
