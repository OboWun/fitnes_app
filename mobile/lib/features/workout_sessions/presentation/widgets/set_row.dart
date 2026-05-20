import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/workout_set.dart';

class SetRow extends StatelessWidget {
  final WorkoutSet value;
  final ValueChanged<WorkoutSet>? onChanged;

  const SetRow({super.key, required this.value, this.onChanged});
  const SetRow.loading({super.key})
      : value = const WorkoutSet(setNumber: 0),
        onChanged = null;

  @override
  Widget build(BuildContext context) {
    if (value.setNumber == 0) return const _SetRowLoading();
    return _SetRowData(value: value, onChanged: onChanged);
  }
}

class _SetRowData extends StatelessWidget {
  final WorkoutSet value;
  final ValueChanged<WorkoutSet>? onChanged;

  const _SetRowData({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isCompleted = value.completedAt != null;
    final setTypeLabel = switch (value.setType) {
      'warmup' => 'W',
      'dropset' => 'D',
      _ => '',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.borderColor,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Center(
              child: setTypeLabel.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.gray3,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        setTypeLabel,
                        style: AppTypography.captionBold,
                      ),
                    )
                  : Text(
                      '${value.setNumber}',
                      style: AppTypography.mediumTextSemiBold,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _PlannedInfo(value: value)),
          if (isCompleted)
            _CompletedInfo(value: value)
          else
            _ActualInputs(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _PlannedInfo extends StatelessWidget {
  final WorkoutSet value;

  const _PlannedInfo({required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.plannedWeightKg != null && value.plannedReps != null) {
      return Text(
        '${value.plannedWeightKg} kg × ${value.plannedReps}',
        style:
            AppTypography.mediumTextRegular.copyWith(color: AppColors.gray1),
      );
    }
    if (value.plannedReps != null) {
      return Text(
        '${value.plannedReps} reps',
        style:
            AppTypography.mediumTextRegular.copyWith(color: AppColors.gray1),
      );
    }
    if (value.plannedDurationSec != null) {
      final min = value.plannedDurationSec! ~/ 60;
      return Text(
        '$min min',
        style:
            AppTypography.mediumTextRegular.copyWith(color: AppColors.gray1),
      );
    }
    return const SizedBox.shrink();
  }
}

class _ActualInputs extends StatefulWidget {
  final WorkoutSet value;
  final ValueChanged<WorkoutSet>? onChanged;

  const _ActualInputs({required this.value, this.onChanged});

  @override
  State<_ActualInputs> createState() => _ActualInputsState();
}

class _ActualInputsState extends State<_ActualInputs> {
  late final TextEditingController _weightCtrl;
  late final TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
      text: widget.value.actualWeightKg?.toString() ??
          widget.value.plannedWeightKg?.toString(),
    );
    _repsCtrl = TextEditingController(
      text: widget.value.actualReps?.toString() ??
          widget.value.plannedReps?.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _ActualInputs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value.setNumber != widget.value.setNumber ||
        oldWidget.value.setType != widget.value.setType) {
      _weightCtrl.text = widget.value.actualWeightKg?.toString() ??
          widget.value.plannedWeightKg?.toString() ??
          '';
      _repsCtrl.text = widget.value.actualReps?.toString() ??
          widget.value.plannedReps?.toString() ??
          '';
    }
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final w = double.tryParse(_weightCtrl.text);
    final r = int.tryParse(_repsCtrl.text);
    widget.onChanged?.call(widget.value.copyWith(
      actualWeightKg: w ?? widget.value.plannedWeightKg,
      actualReps: r ?? widget.value.plannedReps,
      completedAt: DateTime.now().toIso8601String(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hasWeight = widget.value.plannedWeightKg != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasWeight)
          SizedBox(
            width: 60,
            height: 32,
            child: TextField(
              controller: _weightCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              decoration: InputDecoration(
                hintText: '${widget.value.plannedWeightKg}',
                hintStyle: AppTypography.smallTextRegular
                    .copyWith(color: AppColors.gray3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderColor),
                ),
              ),
              style: AppTypography.smallTextSemiBold,
              textAlign: TextAlign.center,
            ),
          ),
        if (hasWeight) const SizedBox(width: 6),
        SizedBox(
          width: 46,
          height: 32,
          child: TextField(
            controller: _repsCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: widget.value.plannedReps != null
                  ? '${widget.value.plannedReps}'
                  : 'reps',
              hintStyle: AppTypography.smallTextRegular
                  .copyWith(color: AppColors.gray3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
            ),
            style: AppTypography.smallTextSemiBold,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 6),
        InkWell(
          onTap: _confirm,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppGradients.blueLinear.colors.first,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.whiteColor,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletedInfo extends StatelessWidget {
  final WorkoutSet value;

  const _CompletedInfo({required this.value});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (value.actualWeightKg != null) parts.add('${value.actualWeightKg} kg');
    if (value.actualReps != null) parts.add('×${value.actualReps}');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          parts.join(' '),
          style: AppTypography.smallTextSemiBold.copyWith(
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.check_circle, color: AppColors.success, size: 18),
      ],
    );
  }
}

class _SetRowLoading extends StatelessWidget {
  const _SetRowLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
