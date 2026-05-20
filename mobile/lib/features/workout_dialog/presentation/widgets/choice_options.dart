import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/chat_message.dart';
import '../../domain/dialog_option.dart';

class ChoiceOptions extends StatelessWidget {
  final List<DialogOption> options;
  final DialogInputType inputType;
  final Set<String> selectedValues;
  final ValueChanged<String> onSingleSelect;
  final ValueChanged<String> onMultiToggle;
  final VoidCallback? onMultiSubmit;

  const ChoiceOptions({
    super.key,
    required this.options,
    required this.inputType,
    required this.selectedValues,
    required this.onSingleSelect,
    required this.onMultiToggle,
    this.onMultiSubmit,
  });

  @override
  Widget build(BuildContext context) {
    if (inputType == DialogInputType.multiChoice) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((opt) {
                  final isSelected =
                      selectedValues.contains(opt.value);
                  return _ChoiceChip(
                    label: opt.label,
                    isSelected: isSelected,
                    onTap: () => onMultiToggle(opt.value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: selectedValues.isNotEmpty
                    ? AppGradients.blueLinear
                    : null,
                color: selectedValues.isEmpty ? AppColors.gray3 : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap:
                    selectedValues.isNotEmpty ? onMultiSubmit : null,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    'Далее',
                    style: AppTypography.largeTextSemiBold.copyWith(
                      color: selectedValues.isNotEmpty
                          ? AppColors.whiteColor
                          : AppColors.gray1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selectedValues.contains(opt.value);
        return _ChoiceChip(
          label: opt.label,
          isSelected: isSelected,
          onTap: () => onSingleSelect(opt.value),
        );
      }).toList(),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.blueLinear : null,
          color: isSelected ? null : AppColors.borderColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: AppTypography.mediumTextMedium.copyWith(
            color:
                isSelected ? AppColors.whiteColor : AppColors.gray1,
          ),
        ),
      ),
    );
  }
}
