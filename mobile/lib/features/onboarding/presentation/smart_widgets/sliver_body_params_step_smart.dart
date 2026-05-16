import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding_provider.dart';
import '../widgets/sliver_body_params_step.dart';

class SliverBodyParamsStepSmart extends ConsumerStatefulWidget {
  const SliverBodyParamsStepSmart({super.key});

  @override
  ConsumerState<SliverBodyParamsStepSmart> createState() =>
      _SliverBodyParamsStepSmartState();
}

class _SliverBodyParamsStepSmartState
    extends ConsumerState<SliverBodyParamsStepSmart> {
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    final onboarding = ref.read(onboardingProvider);
    _weightController =
        TextEditingController(text: onboarding.weight?.toString() ?? '');
    _heightController =
        TextEditingController(text: onboarding.height?.toString() ?? '');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverBodyParamsStep(
      weight: ref.watch(onboardingProvider.select((s) => s.weight)),
      height: ref.watch(onboardingProvider.select((s) => s.height)),
      weightController: _weightController,
      heightController: _heightController,
      onWeightChanged: (v) =>
          ref.read(onboardingProvider.notifier).setWeight(v),
      onHeightChanged: (v) =>
          ref.read(onboardingProvider.notifier).setHeight(v),
    );
  }
}
