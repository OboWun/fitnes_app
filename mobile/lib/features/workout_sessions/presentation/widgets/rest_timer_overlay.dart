import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

enum RestType { betweenSets, afterExercise }

class RestTimerOverlay extends StatefulWidget {
  final int durationSec;
  final RestType restType;
  final VoidCallback? onSkip;

  const RestTimerOverlay({
    super.key,
    required this.durationSec,
    this.restType = RestType.betweenSets,
    this.onSkip,
  });

  @override
  State<RestTimerOverlay> createState() => _RestTimerOverlayState();
}

class _RestTimerOverlayState extends State<RestTimerOverlay>
    with WidgetsBindingObserver {
  late final DateTime _startedAt;
  late int _remainingSec;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startedAt = DateTime.now();
    _remainingSec = widget.durationSec;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final elapsed = DateTime.now().difference(_startedAt).inSeconds;
      final newRemaining = widget.durationSec - elapsed;
      if (newRemaining <= 0) {
        _timer?.cancel();
        widget.onSkip?.call();
      } else {
        _timer?.cancel();
        setState(() => _remainingSec = newRemaining);
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remainingSec--);
      if (_remainingSec <= 0) {
        _timer?.cancel();
        widget.onSkip?.call();
      }
    });
  }

  String get _timeLabel {
    final m = _remainingSec ~/ 60;
    final s = _remainingSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final elapsed = widget.durationSec - _remainingSec;
    return (elapsed / widget.durationSec).clamp(0.0, 1.0);
  }

  String get _label => switch (widget.restType) {
        RestType.betweenSets => 'Отдых между подходами',
        RestType.afterExercise => 'Отдых перед следующим',
      };

  IconData get _icon => switch (widget.restType) {
        RestType.betweenSets => Icons.more_horiz,
        RestType.afterExercise => Icons.arrow_forward_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Material(
          elevation: 8,
          shadowColor: AppColors.blackColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppGradients.blueLinear,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(_icon, color: AppColors.whiteColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _label,
                        style: AppTypography.mediumTextSemiBold.copyWith(
                          color: AppColors.whiteColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeLabel,
                      style: AppTypography.largeTextBold.copyWith(
                        color: AppColors.whiteColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        _timer?.cancel();
                        widget.onSkip?.call();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Пропустить',
                          style: AppTypography.smallTextSemiBold.copyWith(
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 4,
                    backgroundColor: AppColors.whiteColor.withValues(alpha: 0.25),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
