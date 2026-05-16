part of 'onboarding_page.dart';

class _NavigationButtons extends StatelessWidget
    implements PreferredSizeWidget {
  final OnboardingState state;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _NavigationButtons({
    required this.state,
    required this.onBack,
    required this.onNext,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.whiteColor,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              if (!state.isFirstStep) ...[
                Expanded(
                  child: TextButton(
                    onPressed: onBack,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back_ios, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Назад',
                          style: AppTypography.largeTextMedium.copyWith(
                            color: AppColors.gray1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: _GradientButton(
                  onPressed: state.canProceed ? onNext : null,
                  isLoading: state.isSubmitting,
                  label: state.isLastStep ? 'Завершить' : 'Далее',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
