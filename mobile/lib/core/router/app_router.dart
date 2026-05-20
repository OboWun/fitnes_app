import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/public.dart';
import '../../features/dictionaries/presentation/clone_preset_page.dart';
import '../../features/dictionaries/presentation/edit_preset_page.dart';
import '../../features/dictionaries/presentation/equipment_detail_page.dart';
import '../../features/dictionaries/presentation/equipment_page.dart';
import '../../features/dictionaries/presentation/muscles_page.dart';
import '../../features/dictionaries/presentation/preset_detail_page.dart';
import '../../features/exercises/presentation/exercises_page.dart';
import '../../features/exercises/presentation/exercise_detail_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/profile/domain/equipment_preset.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/workout_dialog/public.dart';
import '../../features/workout_templates/domain/workout_template.dart';
import '../../features/workout_templates/presentation/create_template_page.dart';
import '../../features/workout_templates/presentation/template_detail_page.dart';
import '../../features/workouts/presentation/workouts_page.dart';
import '../../features/training_plans/domain/training_plan.dart';
import '../../features/training_plans/presentation/create_plan_page.dart';
import '../../features/training_plans/presentation/plan_detail_page.dart';
import '../../features/workout_sessions/presentation/active_workout_page.dart';
import '../../features/workout_sessions/presentation/workout_history_page.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: _AuthNotifierListener(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final status = authState.status;

      final isSplash = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return isSplash ? null : '/splash';
      }

      if (status == AuthStatus.onboarding) {
        return isOnboarding ? null : '/onboarding';
      }

      if (status == AuthStatus.authenticated) {
        if (isSplash || isOnboarding) return '/';
        return null;
      }

      if (status == AuthStatus.error) {
        return isSplash ? null : '/splash';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/workouts',
        builder: (context, state) => const WorkoutsPage(),
      ),
      GoRoute(
        path: '/workout-dialog',
        builder: (context, state) => const WorkoutDialogPage(),
      ),
      GoRoute(
        path: '/workouts/new',
        builder: (context, state) => const CreateTemplatePage(),
      ),
      GoRoute(
        path: '/workouts/:id/edit',
        builder: (context, state) {
          final template = state.extra as WorkoutTemplate?;
          return CreateTemplatePage(existing: template);
        },
      ),
      GoRoute(
        path: '/workouts/:id',
        builder: (context, state) => TemplateDetailPage(
          templateId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/training-plans/new',
        builder: (context, state) => const CreatePlanPage(),
      ),
      GoRoute(
        path: '/workout-session/:id',
        builder: (context, state) => ActiveWorkoutPage(
          sessionId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/workout-history',
        builder: (context, state) => const WorkoutHistoryPage(),
      ),
      GoRoute(
        path: '/training-plans/:id/edit',
        builder: (context, state) {
          final plan = state.extra as TrainingPlan?;
          return CreatePlanPage(existing: plan);
        },
      ),
      GoRoute(
        path: '/training-plans/:id',
        builder: (context, state) => PlanDetailPage(
          planId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/exercises',
        builder: (context, state) => ExercisesPage(
          equipment: state.uri.queryParameters['equipment'],
          search: state.uri.queryParameters['search'],
          muscles: state.uri.queryParameters['muscles'],
        ),
      ),
      GoRoute(
        path: '/exercises-picker',
        builder: (context, state) => ExercisesPage(
          isPickerMode: true,
          initialSelection: state.extra as Set<String>? ?? {},
        ),
      ),
      GoRoute(
        path: '/exercises/:slug',
        builder: (context, state) => ExerciseDetailPage(
          slug: state.pathParameters['slug'] ?? '',
        ),
      ),
      GoRoute(
        path: '/muscles',
        builder: (context, state) => const MusclesPage(),
      ),
      GoRoute(
        path: '/equipment',
        builder: (context, state) => const EquipmentPage(),
      ),
      GoRoute(
        path: '/equipment/presets/new',
        builder: (context, state) {
          final preset = state.extra as dynamic;
          return ClonePresetPage(sourcePreset: preset as EquipmentPreset);
        },
      ),
      GoRoute(
        path: '/equipment/presets/:id/edit',
        builder: (context, state) {
          final preset = state.extra as dynamic;
          return EditPresetPage(preset: preset as EquipmentPreset);
        },
      ),
      GoRoute(
        path: '/equipment/presets/:id',
        builder: (context, state) => PresetDetailPage(
          presetId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/equipment/:slug',
        builder: (context, state) => EquipmentDetailPage(
          slug: state.pathParameters['slug'] ?? '',
        ),
      ),
    ],
  );
}

class _AuthNotifierListener extends ChangeNotifier {
  _AuthNotifierListener(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (prev, next) {
        if (prev?.status != next.status) notifyListeners();
      },
    );
  }

  final Ref _ref;
}
