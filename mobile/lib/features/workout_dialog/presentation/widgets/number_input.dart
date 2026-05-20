import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/design_system.dart';

class NumberInput extends StatefulWidget {
  final String? hint;
  final ValueChanged<String> onSubmit;

  const NumberInput({
    super.key,
    this.hint,
    required this.onSubmit,
  });

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  final _controller = TextEditingController();
  bool _hasValue = false;

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
        TextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Введите значение',
            suffixText: 'кг',
          ),
          onChanged: (v) {
            setState(() => _hasValue = v.trim().isNotEmpty);
          },
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: _hasValue ? AppGradients.blueLinear : null,
              color: _hasValue ? null : AppColors.gray3,
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: _hasValue ? _submit : null,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Text(
                  'Далее',
                  style: AppTypography.largeTextSemiBold.copyWith(
                    color: _hasValue
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

  void _submit() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) widget.onSubmit(value);
  }
}
