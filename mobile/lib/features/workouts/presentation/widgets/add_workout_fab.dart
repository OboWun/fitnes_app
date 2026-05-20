import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class AddWorkoutFab extends StatefulWidget {
  final VoidCallback? onCoachTap;
  final VoidCallback? onTemplateTap;
  final VoidCallback? onPlanTap;

  const AddWorkoutFab({
    super.key,
    this.onCoachTap,
    this.onTemplateTap,
    this.onPlanTap,
  });

  @override
  State<AddWorkoutFab> createState() => _AddWorkoutFabState();
}

class _AddWorkoutFabState extends State<AddWorkoutFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isOpen = false;
  bool _showSubmenu = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _controller.reverse();
      setState(() {
        _isOpen = false;
        _showSubmenu = false;
      });
    } else {
      _controller.forward();
      setState(() {
        _isOpen = true;
        _showSubmenu = false;
      });
    }
  }

  void _close() {
    if (!_isOpen) return;
    _controller.reverse();
    setState(() {
      _isOpen = false;
      _showSubmenu = false;
    });
  }

  void _openSubmenu() {
    setState(() => _showSubmenu = true);
  }

  void _backToMain() {
    setState(() => _showSubmenu = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isOpen) _Backdrop(onTap: _close, controller: _controller),
        if (_isOpen)
          _MenuPanel(
            controller: _controller,
            showSubmenu: _showSubmenu,
            onCoachTap: () {
              _close();
              widget.onCoachTap?.call();
            },
            onManualTap: _openSubmenu,
            onTemplateTap: () {
              _close();
              widget.onTemplateTap?.call();
            },
            onPlanTap: () {
              _close();
              widget.onPlanTap?.call();
            },
            onBack: _backToMain,
          ),
        Positioned(
          right: 20,
          bottom: 20,
          child: _FabButton(
            isOpen: _isOpen,
            onTap: _toggle,
          ),
        ),
      ],
    );
  }
}

class _Backdrop extends StatelessWidget {
  final VoidCallback onTap;
  final AnimationController controller;

  const _Backdrop({required this.onTap, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: AppColors.blackColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _MenuPanel extends StatelessWidget {
  final AnimationController controller;
  final bool showSubmenu;
  final VoidCallback? onCoachTap;
  final VoidCallback? onManualTap;
  final VoidCallback? onTemplateTap;
  final VoidCallback? onPlanTap;
  final VoidCallback? onBack;

  const _MenuPanel({
    required this.controller,
    required this.showSubmenu,
    this.onCoachTap,
    this.onManualTap,
    this.onTemplateTap,
    this.onPlanTap,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );

    return Positioned(
      left: 20,
      right: 20,
      bottom: 90,
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.card,
            ),
            child: showSubmenu
                ? _SubmenuButtons(
                    onTemplateTap: onTemplateTap,
                    onPlanTap: onPlanTap,
                    onBack: onBack,
                  )
                : _MainButtons(
                    onCoachTap: onCoachTap,
                    onManualTap: onManualTap,
                  ),
          ),
        ),
      ),
    );
  }
}

class _MainButtons extends StatelessWidget {
  final VoidCallback? onCoachTap;
  final VoidCallback? onManualTap;

  const _MainButtons({this.onCoachTap, this.onManualTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        _MenuButton(
          icon: Icons.chat_bubble_outline,
          label: 'С тренером',
          subtitle: 'Подберу план за минуту',
          gradient: AppGradients.purpleLinear,
          onTap: onCoachTap,
        ),
        _MenuButton(
          icon: Icons.edit_note,
          label: 'Самостоятельно',
          subtitle: 'Шаблон или план',
          gradient: AppGradients.caloriesLinear,
          onTap: onManualTap,
        ),
      ],
    );
  }
}

class _SubmenuButtons extends StatelessWidget {
  final VoidCallback? onTemplateTap;
  final VoidCallback? onPlanTap;
  final VoidCallback? onBack;

  const _SubmenuButtons({
    this.onTemplateTap,
    this.onPlanTap,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.arrow_back, size: 20, color: AppColors.gray1),
                const SizedBox(width: 8),
                Text(
                  'Назад',
                  style: AppTypography.mediumTextMedium.copyWith(
                    color: AppColors.gray1,
                  ),
                ),
              ],
            ),
          ),
        ),
        _MenuButton(
          icon: Icons.description_outlined,
          label: 'Новый шаблон',
          subtitle: 'Набор упражнений',
          gradient: AppGradients.blueLinear,
          onTap: onTemplateTap,
        ),
        _MenuButton(
          icon: Icons.calendar_month,
          label: 'Новый план',
          subtitle: 'Расписание на неделю',
          gradient: AppGradients.progressBarLinear,
          onTap: onPlanTap,
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.whiteColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.whiteColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.largeTextSemiBold.copyWith(
                      color: AppColors.whiteColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.smallTextRegular.copyWith(
                      color: AppColors.whiteColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.whiteColor.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  final bool isOpen;
  final VoidCallback? onTap;

  const _FabButton({required this.isOpen, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppGradients.blueLinear,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.blue,
        ),
        child: AnimatedRotation(
          turns: isOpen ? 0.125 : 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Icon(
            isOpen ? Icons.close : Icons.add,
            color: AppColors.whiteColor,
            size: 28,
          ),
        ),
      ),
    );
  }
}
