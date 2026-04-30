import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/design_system.dart';
import '../auth/auth_provider.dart';
import '../auth/domain/auth_state.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Запускаем аутентификацию
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Навигация при изменении статуса
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (next.status == AuthStatus.onboarding) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      } else if (next.status == AuthStatus.error) {
        // Показываем ошибку, но можно повторить
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Ошибка подключения'),
            action: SnackBarAction(
              label: 'Повторить',
              onPressed: () => ref.read(authProvider.notifier).initialize(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.blueLinear,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.whiteColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 48,
                color: AppColors.whiteColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'FitnessX',
              style: AppTypography.h1Bold().copyWith(
                color: AppColors.whiteColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Everybody Can Train',
              style: AppTypography.mediumTextRegular().copyWith(
                color: AppColors.whiteColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 48),
            if (authState.status == AuthStatus.loading)
              const CircularProgressIndicator(color: AppColors.whiteColor),
            if (authState.status == AuthStatus.error)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      'Не удалось подключиться к серверу',
                      textAlign: TextAlign.center,
                      style: AppTypography.mediumTextRegular().copyWith(
                        color: AppColors.whiteColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(authProvider.notifier).initialize(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whiteColor,
                        foregroundColor: AppColors.blackColor,
                      ),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
