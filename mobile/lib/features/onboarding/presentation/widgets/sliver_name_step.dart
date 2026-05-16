import 'package:flutter/material.dart';

import '../../../../core/widgets/sliver_adapter.dart';
import '../../../../core/widgets/sliver_decorated_box.dart';
import '../../../../design_system/design_system.dart';

class SliverNameStep extends StatelessWidget {
  final String value;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SliverNameStep({
    super.key,
    required this.value,
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
      child: SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Как тебя зовут?',
                style:
                    AppTypography.h2Bold.copyWith(color: AppColors.blackColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Это поможет нам персонализировать приложение',
                style: AppTypography.smallTextRegular
                    .copyWith(color: AppColors.gray1),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: controller,
                onChanged: onChanged,
                style: AppTypography.mediumTextRegular,
                decoration: InputDecoration(
                  hintText: 'Введи своё имя',
                  prefixIcon: const Icon(Icons.person_outline,
                      color: AppColors.gray2),
                  suffixIcon: value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              size: 18, color: AppColors.gray2),
                          onPressed: () {
                            controller?.clear();
                            onChanged?.call('');
                          },
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
