import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding_provider.dart';
import '../widgets/sliver_gender_step.dart';

class SliverGenderStepSmart extends ConsumerWidget {
  const SliverGenderStepSmart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gender = ref.watch(onboardingProvider.select((s) => s.gender));
    return SliverGenderStep(
      value: gender.isEmpty ? null : gender,
      onChanged: (v) => ref.read(onboardingProvider.notifier).setGender(v),
    );
  }
}
