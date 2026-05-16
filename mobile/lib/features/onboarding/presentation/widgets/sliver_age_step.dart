import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/sliver_adapter.dart';
import '../../../../core/widgets/sliver_decorated_box.dart';
import '../../../../design_system/design_system.dart';

class SliverAgeStep extends StatelessWidget {
  final int? value;
  final ValueChanged<int?>? onChanged;
  final TextEditingController? controller;

  const SliverAgeStep({
    super.key,
    this.value,
    this.onChanged,
    this.controller,
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
                'Сколько тебе лет?',
                style:
                    AppTypography.h2Bold.copyWith(color: AppColors.blackColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Необязательно, но поможет скорректировать программу',
                style: AppTypography.smallTextRegular
                    .copyWith(color: AppColors.gray1),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                onChanged: (v) => onChanged?.call(int.tryParse(v)),
                style: AppTypography.mediumTextRegular,
                decoration: const InputDecoration(
                  hintText: 'Возраст',
                  prefixIcon: Icon(Icons.calendar_today_outlined,
                      color: AppColors.gray2),
                  suffixText: 'лет',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
