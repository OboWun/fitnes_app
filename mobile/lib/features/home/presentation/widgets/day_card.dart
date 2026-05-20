import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class DayCard extends StatelessWidget {
  final String? _dayName;
  final String? _date;
  final String? _workoutLabel;
  final bool _isToday;
  final String _status;
  final VoidCallback? _onTap;

  const DayCard({
    super.key,
    required String dayName,
    required String date,
    String? workoutLabel,
    bool isToday = false,
    String status = 'planned',
    VoidCallback? onTap,
  })  : _dayName = dayName,
        _date = date,
        _workoutLabel = workoutLabel,
        _isToday = isToday,
        _status = status,
        _onTap = onTap;

  const DayCard.loading({super.key, bool isToday = false})
      : _dayName = null,
        _date = null,
        _workoutLabel = null,
        _isToday = isToday,
        _status = 'planned',
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_dayName == null || _date == null) {
      return const _DayCardLoading(isToday: false);
    }
    return _DayCardData(
      dayName: _dayName!,
      date: _date!,
      workoutLabel: _workoutLabel,
      isToday: _isToday,
      status: _status,
      onTap: _onTap,
    );
  }
}

class _DayCardData extends StatelessWidget {
  final String dayName;
  final String date;
  final String? workoutLabel;
  final bool isToday;
  final String status;
  final VoidCallback? onTap;

  const _DayCardData({
    required this.dayName,
    required this.date,
    this.workoutLabel,
    this.isToday = false,
    this.status = 'planned',
    this.onTap,
  });

  bool get _isCompleted => status == 'completed';
  bool get _isSkipped => status == 'skipped' || status == 'replaced';
  bool get _isPast => _isCompleted || _isSkipped;

  Color get _bgColor {
    if (isToday) return AppColors.whiteColor;
    if (_isCompleted) return AppColors.success.withValues(alpha: 0.12);
    if (_isSkipped) return AppColors.gray3.withValues(alpha: 0.5);
    return AppColors.borderColor;
  }

  Color get _dayNameColor {
    if (isToday) return AppColors.whiteColor;
    if (_isPast) return AppColors.gray3;
    return AppColors.gray2;
  }

  Color get _dateColor {
    if (isToday) return AppColors.whiteColor;
    if (_isPast) return AppColors.gray3;
    return AppColors.blackColor;
  }

  Color get _labelBg {
    if (isToday) return AppColors.whiteColor.withValues(alpha: 0.25);
    if (_isCompleted) return AppColors.success.withValues(alpha: 0.15);
    if (_isSkipped) return AppColors.gray3.withValues(alpha: 0.3);
    return AppGradients.blueLinear.colors.first.withValues(alpha: 0.12);
  }

  Color get _labelColor {
    if (isToday) return AppColors.whiteColor;
    if (_isCompleted) return AppColors.success;
    if (_isSkipped) return AppColors.gray2;
    return AppGradients.blueLinear.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      constraints: const BoxConstraints(minWidth: 44),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        gradient: isToday ? AppGradients.blueLinear : null,
        color: isToday ? null : _bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayName,
            style: AppTypography.captionMedium.copyWith(color: _dayNameColor),
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: AppTypography.smallTextSemiBold.copyWith(color: _dateColor),
          ),
          if (_isCompleted)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(Icons.check_circle, size: 12, color: AppColors.success),
            )
          else if (_isSkipped)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '—',
                style: AppTypography.captionMedium.copyWith(
                  color: AppColors.gray3,
                ),
              ),
            )
          else if (workoutLabel != null) ...[
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: _labelBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                workoutLabel!,
                style: AppTypography.captionRegular.copyWith(
                  color: _labelColor,
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

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: child,
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
