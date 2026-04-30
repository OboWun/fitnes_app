import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/design_system.dart';
import '../auth/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Привет, ${user?.name ?? 'Атлет'}!',
                style: AppTypography.h2Bold().copyWith(
                  color: AppColors.blackColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Готов к тренировке?',
                style: AppTypography.mediumTextRegular().copyWith(
                  color: AppColors.gray1,
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Основной экран (в разработке)',
                  style: AppTypography.largeTextMedium().copyWith(
                    color: AppColors.gray2,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
