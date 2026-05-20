part of 'workout_dialog_page.dart';

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isWorkout;
  final bool isSwitchingMode;
  final ChatSession? session;
  final VoidCallback onClose;
  final VoidCallback onToggleMode;

  const _AppBar({
    required this.isWorkout,
    required this.isSwitchingMode,
    required this.session,
    required this.onClose,
    required this.onToggleMode,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppGradients.blueLinear,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.whiteColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Тренер',
            style: AppTypography.largeTextSemiBold.copyWith(
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: AppColors.whiteColor,
      elevation: 0,
      leading: IconButton(
        onPressed: onClose,
        icon: const Icon(Icons.close, color: AppColors.blackColor),
      ),
      actions: [
        if (session != null && !isSwitchingMode)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _ModeToggle(isWorkout: isWorkout, onToggle: onToggleMode),
          ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool isWorkout;
  final VoidCallback onToggle;

  const _ModeToggle({required this.isWorkout, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isWorkout ? Icons.chat_bubble_outline : Icons.fitness_center,
              size: 16,
              color: AppColors.gray1,
            ),
            const SizedBox(width: 4),
            Text(
              isWorkout ? 'Чат' : 'Тренировка',
              style: AppTypography.captionMedium.copyWith(
                color: AppColors.gray1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final List<ChatMessageModel> messages;
  final bool isSending;
  final bool isComplete;
  final ChatMessageModel? completeMessage;
  final bool isCreating;
  final VoidCallback onCreateFromDialog;
  final VoidCallback? onNewGeneration;
  final ScrollController scrollController;

  const _MessageList({
    required this.messages,
    required this.isSending,
    required this.isComplete,
    required this.completeMessage,
    required this.isCreating,
    required this.onCreateFromDialog,
    this.onNewGeneration,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final extraCount = (isSending ? 1 : 0) + (isComplete ? 2 : 0);
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      addAutomaticKeepAlives: false,
      itemCount: messages.length + extraCount,
      itemBuilder: (context, index) {
        if (isComplete && index == messages.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: DialogCompleteCard(
              planType: completeMessage!.planType ?? 'generate',
              params: completeMessage!.dialogParams ?? {},
              onCreate: onCreateFromDialog,
              isCreating: isCreating,
            ),
          );
        }
        if (isComplete && index == messages.length + 1) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _NewGenerationButton(
              onPressed: onNewGeneration,
              isLoading: isCreating,
            ),
          );
        }
        if (isSending && index == messages.length + (isComplete ? 2 : 0)) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: TypingIndicator(),
          );
        }

        final msg = messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _MessageBubble(msg: msg),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel msg;

  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return switch (msg.role) {
      ChatRole.user => UserMessageBubble(message: msg.content),
      ChatRole.system => SystemMessageBubble(message: msg.content),
      ChatRole.assistant => CoachMessageBubble(message: msg.content),
    };
  }
}

class _ChatFooter extends StatelessWidget {
  final ValueChanged<String> onSubmitted;
  final bool isEnabled;

  const _ChatFooter({required this.onSubmitted, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return _FooterContainer(
      child: ChatInputField(onSubmitted: onSubmitted, isEnabled: isEnabled),
    );
  }
}

class _FooterContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _FooterContainer({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: child,
    );
  }
}

class _CloseConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Завершить диалог?',
        style: AppTypography.mediumTextSemiBold.copyWith(
          color: AppColors.blackColor,
        ),
      ),
      content: Text(
        'Прогресс будет сохранён. Вы сможете продолжить позже.',
        style: AppTypography.mediumTextRegular.copyWith(
          color: AppColors.gray1,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Отмена',
            style: AppTypography.mediumTextMedium.copyWith(
              color: AppColors.gray1,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Выйти',
            style: AppTypography.mediumTextMedium.copyWith(
              color: AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivatePlanDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'План готов!',
        style: AppTypography.h4Bold.copyWith(color: AppColors.blackColor),
      ),
      content: Text(
        'Сделать этот план активным? Вы всегда сможете отредактировать его позже.',
        style: AppTypography.mediumTextRegular.copyWith(
          color: AppColors.gray1,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Позже',
            style: AppTypography.mediumTextMedium.copyWith(
              color: AppColors.gray1,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Активировать',
            style: AppTypography.mediumTextSemiBold.copyWith(
              color: AppColors.blackColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _NewGenerationButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _NewGenerationButton({this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 20, color: AppColors.gray1),
            const SizedBox(width: 8),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                'Создать ещё одну тренировку',
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
