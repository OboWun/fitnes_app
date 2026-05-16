import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/public.dart';
import '../../features/dictionaries/presentation/equipment_page.dart';
import '../../features/dictionaries/presentation/muscles_page.dart';
import '../../features/exercises/presentation/exercises_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/workouts/presentation/workouts_page.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final authStateValue = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: _AuthNotifierListener(ref),
    redirect: (context, state) {
      final status = authStateValue.status;

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
        path: '/exercises',
        builder: (context, state) => const ExercisesPage(),
      ),
      GoRoute(
        path: '/muscles',
        builder: (context, state) => const MusclesPage(),
      ),
      GoRoute(
        path: '/equipment',
        builder: (context, state) => const EquipmentPage(),
      ),
    ],
  );
}

class _AuthNotifierListener extends ChangeNotifier {
  _AuthNotifierListener(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;
}
