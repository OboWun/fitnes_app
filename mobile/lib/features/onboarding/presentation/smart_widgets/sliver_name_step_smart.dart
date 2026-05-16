import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding_provider.dart';
import '../widgets/sliver_name_step.dart';

class SliverNameStepSmart extends ConsumerStatefulWidget {
  const SliverNameStepSmart({super.key});

  @override
  ConsumerState<SliverNameStepSmart> createState() => _SliverNameStepSmartState();
}

class _SliverNameStepSmartState extends ConsumerState<SliverNameStepSmart> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final name = ref.read(onboardingProvider).name;
    _controller = TextEditingController(text: name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(onboardingProvider.select((s) => s.name));
    return SliverNameStep(
      value: name,
      controller: _controller,
      onChanged: (v) => ref.read(onboardingProvider.notifier).setName(v),
    );
  }
}
