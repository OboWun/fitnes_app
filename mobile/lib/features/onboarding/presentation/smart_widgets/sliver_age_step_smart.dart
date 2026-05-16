import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding_provider.dart';
import '../widgets/sliver_age_step.dart';

class SliverAgeStepSmart extends ConsumerStatefulWidget {
  const SliverAgeStepSmart({super.key});

  @override
  ConsumerState<SliverAgeStepSmart> createState() => _SliverAgeStepSmartState();
}

class _SliverAgeStepSmartState extends ConsumerState<SliverAgeStepSmart> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final age = ref.read(onboardingProvider).age;
    _controller = TextEditingController(text: age?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAgeStep(
      value: ref.watch(onboardingProvider.select((s) => s.age)),
      controller: _controller,
      onChanged: (v) => ref.read(onboardingProvider.notifier).setAge(v),
    );
  }
}
