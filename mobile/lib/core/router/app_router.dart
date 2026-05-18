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
import '../../features/workouts/presentation/workout_detail_page.dart';
import '../../features/workouts/presentation/workouts_page.dart';

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
        path: '/workouts/:id',
        builder: (context, state) => WorkoutDetailPage(
          workoutId: state.pathParameters['id'] ?? '',
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
