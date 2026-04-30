import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../design_system/design_system.dart';
import '../../onboarding_provider.dart';

/// Провайдер списка противопоказаний с бекенда
final contraindicationsListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/contraindications');
  final list = response.data as List<dynamic>;
  return list.map((e) => e as Map<String, dynamic>).toList();
});

class StepContraindications extends ConsumerWidget {
  const StepContraindications({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider.select((s) => s.contraindications));
    final contraindicationsAsync = ref.watch(contraindicationsListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Противопоказания',
          style: AppTypography.h2Bold().copyWith(
            color: AppColors.blackColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Необязательно. Мы исключим неподходящие упражнения',
          style: AppTypography.smallTextRegular().copyWith(
            color: AppColors.gray1,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: contraindicationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Не удалось загрузить',
                    style: AppTypography.mediumTextRegular().copyWith(color: AppColors.gray1),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(contraindicationsListProvider),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'Нет противопоказаний',
                    style: AppTypography.mediumTextRegular().copyWith(color: AppColors.gray2),
                  ),
                );
              }

              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final slug = item['slug'] as String;
                  final name = item['name'] as String;
                  final isSelected = selected.contains(slug);

                  return GestureDetector(
                    onTap: () {
                      ref.read(onboardingProvider.notifier).toggleContraindication(slug);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? null : AppColors.borderColor,
                        gradient: isSelected ? AppGradients.purpleLinear : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                            color: isSelected ? AppColors.whiteColor : AppColors.gray2,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: AppTypography.mediumTextMedium().copyWith(
                                color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
