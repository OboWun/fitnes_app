import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/public.dart';
import '../../../../design_system/design_system.dart';
import '../../data/profile_repository.dart';
import '../widgets/weight_card.dart';
import '../widgets/weight_update_sheet.dart';

class WeightCardSmart extends ConsumerWidget {
  const WeightCardSmart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.select((s) => s.user));

    if (user == null) return const WeightCard.loading();

    return WeightCard(
      weight: user.weight ?? 0,
      onUpdate: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.whiteColor,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => WeightUpdateSheet(
            currentWeight: user.weight,
            onSave: (weight) {
              ref.read(profileRepositoryProvider).updateWeight(weight);
              ref
                  .read(authProvider.notifier)
                  .updateUserLocally(user.copyWith(weight: weight));
            },
          ),
        );
      },
    );
  }
}
