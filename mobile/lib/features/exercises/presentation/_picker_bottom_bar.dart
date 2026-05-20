part of 'exercises_page.dart';

class _PickerBottomBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onConfirm;

  const _PickerBottomBar({
    required this.selectedCount,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: InkWell(
            onTap: selectedCount > 0 ? onConfirm : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                gradient:
                    selectedCount > 0 ? AppGradients.blueLinear : null,
                color: selectedCount == 0 ? AppColors.gray3 : null,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                selectedCount == 0
                    ? 'Выберите упражнения'
                    : 'Выбрать ($selectedCount)',
                style: AppTypography.largeTextSemiBold.copyWith(
                  color: selectedCount > 0
                      ? AppColors.whiteColor
                      : AppColors.gray1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
