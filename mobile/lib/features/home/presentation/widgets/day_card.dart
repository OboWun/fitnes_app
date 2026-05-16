import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class DayCard extends StatelessWidget {
  final String? _dayName;
  final String? _date;
  final String? _workoutLabel;
  final bool _isToday;

  const DayCard({
    super.key,
    required String dayName,
    required String date,
    String? workoutLabel,
    bool isToday = false,
  })  : _dayName = dayName,
        _date = date,
        _workoutLabel = workoutLabel,
        _isToday = isToday;

  const DayCard.loading({super.key, bool isToday = false})
      : _dayName = null,
        _date = null,
        _workoutLabel = null,
        _isToday = isToday;

  @override
  Widget build(BuildContext context) {
    if (_dayName == null || _date == null) {
      return const _DayCardLoading(isToday: false);
    }
    return _DayCardData(
      dayName: _dayName,
      date: _date,
      workoutLabel: _workoutLabel,
      isToday: _isToday,
    );
  }
}

class _DayCardData extends StatelessWidget {
  final String dayName;
  final String date;
  final String? workoutLabel;
  final bool isToday;

  const _DayCardData({
    required this.dayName,
    required this.date,
    this.workoutLabel,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 44),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        gradient: isToday ? AppGradients.blueLinear : null,
        color: isToday ? null : AppColors.borderColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayName,
            style: AppTypography.captionMedium.copyWith(
              color: isToday ? AppColors.whiteColor : AppColors.gray2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: AppTypography.smallTextSemiBold.copyWith(
              color: isToday ? AppColors.whiteColor : AppColors.blackColor,
            ),
          ),
          if (workoutLabel != null) ...[
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.whiteColor.withValues(alpha: 0.25)
                    : AppGradients.blueLinear.colors.first
                        .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                workoutLabel!,
                style: AppTypography.captionRegular.copyWith(
                  color: isToday
                      ? AppColors.whiteColor
                      : AppGradients.blueLinear.colors.first,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayCardLoading extends StatelessWidget {
  final bool isToday;

  const _DayCardLoading({required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 44),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerCard(
            height: 10,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),
          ShimmerCard(
            height: 12,
            width: 28,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
