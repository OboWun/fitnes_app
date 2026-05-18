import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/design_system.dart';

class WeightUpdateSheet extends StatefulWidget {
  final int? currentWeight;
  final ValueChanged<int>? onSave;

  const WeightUpdateSheet({
    super.key,
    this.currentWeight,
    this.onSave,
  });

  @override
  State<WeightUpdateSheet> createState() => _WeightUpdateSheetState();
}

class _WeightUpdateSheetState extends State<WeightUpdateSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.currentWeight?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Обновить вес',
            style: AppTypography.h4SemiBold
                .copyWith(color: AppColors.blackColor),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            autofocus: true,
            style: AppTypography.largeTextRegular,
            decoration: const InputDecoration(
              hintText: 'Вес',
              prefixIcon: Icon(Icons.monitor_weight_outlined,
                  color: AppColors.gray2),
              suffixText: 'кг',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () {
                final weight = int.tryParse(_controller.text);
                if (weight != null && weight > 0) {
                  widget.onSave?.call(weight);
                  Navigator.of(context).pop();
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppGradients.blueLinear,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.blue,
                ),
                child: Center(
                  child: Text(
                    'Сохранить',
                    style: AppTypography.largeTextSemiBold
                        .copyWith(color: AppColors.whiteColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
