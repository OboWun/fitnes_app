import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class ChatInputField extends StatefulWidget {
  final ValueChanged<String> onSubmitted;
  final bool isEnabled;

  const ChatInputField({
    super.key,
    required this.onSubmitted,
    this.isEnabled = true,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.isEnabled) return;
    widget.onSubmitted(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.isEnabled,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'Напишите сообщение...',
              hintStyle: AppTypography.mediumTextRegular.copyWith(
                color: AppColors.gray3,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.borderColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            style: AppTypography.mediumTextRegular.copyWith(
              color: AppColors.blackColor,
            ),
            textInputAction: TextInputAction.send,
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _submit,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppGradients.blueLinear,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.send,
              color: AppColors.whiteColor,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
