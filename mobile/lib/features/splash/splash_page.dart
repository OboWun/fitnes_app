import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/design_system.dart';
import '../auth/public.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

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
              style: AppTypography.h1Bold.copyWith(
                color: AppColors.whiteColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Everybody Can Train',
              style: AppTypography.mediumTextRegular.copyWith(
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
                      style: AppTypography.mediumTextRegular.copyWith(
                        color: AppColors.whiteColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(authProvider.notifier).initialize(),
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
