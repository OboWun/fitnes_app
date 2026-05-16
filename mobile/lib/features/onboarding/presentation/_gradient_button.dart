part of 'onboarding_page.dart';

class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  const _GradientButton({
    required this.onPressed,
    required this.isLoading,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return InkWell(
      onTap: isEnabled ? onPressed : null,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isEnabled ? AppGradients.blueLinear : null,
          color: isEnabled ? null : AppColors.gray3,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled ? AppShadows.blue : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.whiteColor,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: AppTypography.largeTextSemiBold.copyWith(
                        color: isEnabled
                            ? AppColors.whiteColor
                            : AppColors.gray2,
                      ),
                    ),
                    if (label != 'Завершить') ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: isEnabled
                            ? AppColors.whiteColor
                            : AppColors.gray2,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
