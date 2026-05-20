part of 'active_workout_page.dart';

class _SkipDialog extends StatefulWidget {
  const _SkipDialog();

  @override
  State<_SkipDialog> createState() => _SkipDialogState();
}

class _SkipDialogState extends State<_SkipDialog> {
  bool _reschedule = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Пропустить тренировку?',
          style: AppTypography.mediumTextSemiBold
              .copyWith(color: AppColors.blackColor)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Тренировка будет отмечена как пропущенная.',
              style: AppTypography.mediumTextRegular
                  .copyWith(color: AppColors.gray1)),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _reschedule,
            onChanged: (v) => setState(() => _reschedule = v),
            title: Text('Перенести на другой день',
                style: AppTypography.mediumTextRegular
                    .copyWith(color: AppColors.blackColor)),
            contentPadding: EdgeInsets.zero,
            activeColor: AppGradients.blueLinear.colors.first,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Отмена',
              style: AppTypography.mediumTextMedium
                  .copyWith(color: AppColors.gray1)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_reschedule),
          child: Text('Пропустить',
              style: AppTypography.mediumTextMedium
                  .copyWith(color: AppColors.danger)),
        ),
      ],
    );
  }
}
