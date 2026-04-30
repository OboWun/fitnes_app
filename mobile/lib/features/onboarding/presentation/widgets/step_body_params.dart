import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../onboarding_provider.dart';

class StepBodyParams extends ConsumerStatefulWidget {
  const StepBodyParams({super.key});

  @override
  ConsumerState<StepBodyParams> createState() => _StepBodyParamsState();
}

class _StepBodyParamsState extends ConsumerState<StepBodyParams> {
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    final onboarding = ref.read(onboardingProvider);
    _weightController = TextEditingController(text: onboarding.weight?.toString() ?? '');
    _heightController = TextEditingController(text: onboarding.height?.toString() ?? '');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Параметры тела',
          style: AppTypography.h2Bold().copyWith(
            color: AppColors.blackColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Необязательно, поможет отслеживать прогресс',
          style: AppTypography.smallTextRegular().copyWith(
            color: AppColors.gray1,
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          onChanged: (value) {
            ref.read(onboardingProvider.notifier).setWeight(int.tryParse(value));
          },
          style: AppTypography.mediumTextRegular(),
          decoration: const InputDecoration(
            hintText: 'Вес',
            prefixIcon: Icon(Icons.monitor_weight_outlined, color: AppColors.gray2),
            suffixText: 'кг',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _heightController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          onChanged: (value) {
            ref.read(onboardingProvider.notifier).setHeight(int.tryParse(value));
          },
          style: AppTypography.mediumTextRegular(),
          decoration: const InputDecoration(
            hintText: 'Рост',
            prefixIcon: Icon(Icons.height_outlined, color: AppColors.gray2),
            suffixText: 'см',
          ),
        ),
      ],
    );
  }
}
