import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../onboarding_provider.dart';

class StepAge extends ConsumerStatefulWidget {
  const StepAge({super.key});

  @override
  ConsumerState<StepAge> createState() => _StepAgeState();
}

class _StepAgeState extends ConsumerState<StepAge> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Сколько тебе лет?',
          style: AppTypography.h2Bold().copyWith(
            color: AppColors.blackColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Необязательно, но поможет скорректировать программу',
          style: AppTypography.smallTextRegular().copyWith(
            color: AppColors.gray1,
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          onChanged: (value) {
            final age = int.tryParse(value);
            ref.read(onboardingProvider.notifier).setAge(age);
          },
          style: AppTypography.mediumTextRegular(),
          decoration: const InputDecoration(
            hintText: 'Возраст',
            prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.gray2),
            suffixText: 'лет',
          ),
        ),
      ],
    );
  }
}
