import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/public.dart';
import '../../onboarding_provider.dart';
import '../widgets/sliver_contraindications_step.dart';

class SliverContraindicationsStepSmart extends ConsumerWidget {
  const SliverContraindicationsStepSmart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected =
        ref.watch(onboardingProvider.select((s) => s.contraindications));
    final contraindicationsAsync = ref.watch(contraindicationsProvider);

    return contraindicationsAsync.when(
      loading: () => const SliverContraindicationsStep.loading(),
      error: (_, __) => const SliverContraindicationsStep.loading(),
      data: (items) => SliverContraindicationsStep(
        items: items,
        selected: selected,
        onToggle: (slug) => ref
            .read(onboardingProvider.notifier)
            .toggleContraindication(slug),
      ),
    );
  }
}
