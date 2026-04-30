import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../onboarding_provider.dart';

class StepName extends ConsumerStatefulWidget {
  const StepName({super.key});

  @override
  ConsumerState<StepName> createState() => _StepNameState();
}

class _StepNameState extends ConsumerState<StepName> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Как тебя зовут?',
          style: AppTypography.h2Bold().copyWith(
            color: AppColors.blackColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Это поможет нам персонализировать приложение',
          style: AppTypography.smallTextRegular().copyWith(
            color: AppColors.gray1,
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _controller,
          onChanged: (value) {
            ref.read(onboardingProvider.notifier).setName(value);
          },
          style: AppTypography.mediumTextRegular(),
          decoration: InputDecoration(
            hintText: 'Введи своё имя',
            prefixIcon: const Icon(Icons.person_outline, color: AppColors.gray2),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.gray2),
                    onPressed: () {
                      _controller.clear();
                      ref.read(onboardingProvider.notifier).setName('');
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
