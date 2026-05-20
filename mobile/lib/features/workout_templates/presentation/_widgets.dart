part of 'create_template_page.dart';

class _ExerciseEntry {
  final String slug;
  final String name;
  final int sets;
  final int? restBetweenSets;
  final int? restAfterExercise;

  const _ExerciseEntry({
    required this.slug,
    required this.name,
    this.sets = 3,
    this.restBetweenSets,
    this.restAfterExercise,
  });
}

class _ExerciseTile extends StatelessWidget {
  final String name;
  final int sets;
  final int? restBetweenSets;
  final int? restAfterExercise;
  final ValueChanged<int>? onSetsChanged;
  final ValueChanged<int>? onRestBetweenSetsChanged;
  final ValueChanged<int>? onRestAfterExerciseChanged;
  final VoidCallback? onDelete;

  const _ExerciseTile({
    required this.name,
    required this.sets,
    this.restBetweenSets,
    this.restAfterExercise,
    this.onSetsChanged,
    this.onRestBetweenSetsChanged,
    this.onRestAfterExerciseChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.drag_handle, color: AppColors.gray2, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.mediumTextSemiBold.copyWith(
                    color: AppColors.blackColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _StepperRow(
                  label: 'Подходы:',
                  value: '$sets',
                  onDecrement:
                      sets > 1 ? () => onSetsChanged?.call(sets - 1) : null,
                  onIncrement:
                      sets < 10 ? () => onSetsChanged?.call(sets + 1) : null,
                ),
                const SizedBox(height: 4),
                _StepperRow(
                  label: 'Отдых между:',
                  value: restBetweenSets == null
                      ? '—'
                      : '${restBetweenSets}с',
                  onDecrement: restBetweenSets != null && restBetweenSets! > 15
                      ? () => onRestBetweenSetsChanged
                          ?.call(restBetweenSets! - 15)
                      : null,
                  onIncrement:
                      (restBetweenSets ?? 0) < 300
                          ? () => onRestBetweenSetsChanged?.call(
                                (restBetweenSets ?? 45) + 15,
                              )
                          : null,
                ),
                const SizedBox(height: 4),
                _StepperRow(
                  label: 'Отдых после:',
                  value: restAfterExercise == null
                      ? '—'
                      : '${restAfterExercise}с',
                  onDecrement:
                      restAfterExercise != null && restAfterExercise! > 15
                          ? () => onRestAfterExerciseChanged
                              ?.call(restAfterExercise! - 15)
                          : null,
                  onIncrement:
                      (restAfterExercise ?? 0) < 300
                          ? () => onRestAfterExerciseChanged?.call(
                                (restAfterExercise ?? 75) + 15,
                              )
                          : null,
                ),
              ],
            ),
          ),
          if (onDelete != null)
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(8),
              child:
                  Icon(Icons.close, color: AppColors.gray2, size: 20),
            ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _StepperRow({
    required this.label,
    required this.value,
    this.onDecrement,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.smallTextRegular.copyWith(
            color: AppColors.gray1,
          ),
        ),
        const SizedBox(width: 8),
        _SmallButton(icon: Icons.remove, onTap: onDecrement),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            value,
            style: AppTypography.smallTextSemiBold.copyWith(
              color: AppColors.blackColor,
            ),
          ),
        ),
        _SmallButton(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SmallButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray3),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: AppColors.gray1),
      ),
    );
  }
}

class _AddExerciseButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddExerciseButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.gray1, size: 20),
            const SizedBox(width: 8),
            Text(
              'Добавить упражнение',
              style: AppTypography.mediumTextMedium.copyWith(
                color: AppColors.gray1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
