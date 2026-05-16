import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/sliver_adapter.dart';
import '../../../../core/widgets/sliver_decorated_box.dart';
import '../../../../design_system/design_system.dart';

class SliverBodyParamsStep extends StatelessWidget {
  final int? weight;
  final int? height;
  final ValueChanged<int?>? onWeightChanged;
  final ValueChanged<int?>? onHeightChanged;
  final TextEditingController? weightController;
  final TextEditingController? heightController;

  const SliverBodyParamsStep({
    super.key,
    this.weight,
    this.height,
    this.onWeightChanged,
    this.onHeightChanged,
    this.weightController,
    this.heightController,
  });

  @override
  Widget build(BuildContext context) {
    return SliverDecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        sliver: SliverAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Параметры тела',
                style:
                    AppTypography.h2Bold.copyWith(color: AppColors.blackColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Необязательно, поможет отслеживать прогресс',
                style: AppTypography.smallTextRegular
                    .copyWith(color: AppColors.gray1),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                onChanged: (v) => onWeightChanged?.call(int.tryParse(v)),
                style: AppTypography.mediumTextRegular,
                decoration: const InputDecoration(
                  hintText: 'Вес',
                  prefixIcon: Icon(Icons.monitor_weight_outlined,
                      color: AppColors.gray2),
                  suffixText: 'кг',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                onChanged: (v) => onHeightChanged?.call(int.tryParse(v)),
                style: AppTypography.mediumTextRegular,
                decoration: const InputDecoration(
                  hintText: 'Рост',
                  prefixIcon:
                      Icon(Icons.height_outlined, color: AppColors.gray2),
                  suffixText: 'см',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
