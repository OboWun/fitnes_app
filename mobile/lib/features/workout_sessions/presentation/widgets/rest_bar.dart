import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class RestBar extends StatelessWidget {
  final int durationSec;

  const RestBar({super.key, required this.durationSec});

  double get _height => (durationSec * 40 / 60).clamp(40.0, 200.0);

  String get _label {
    final m = durationSec ~/ 60;
    final s = durationSec % 60;
    if (m > 0) return '$m:${s.toString().padLeft(2, '0')}';
    return '$sс';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.whiteColor,
            const Color(0xFFE8EEFF),
            AppColors.whiteColor,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 14, color: AppColors.gray2),
            const SizedBox(width: 6),
            Text(
              _label,
              style: AppTypography.smallTextSemiBold.copyWith(
                color: AppColors.gray2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
