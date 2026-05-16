import 'package:flutter/material.dart';

import '../design_system.dart';

class ShimmerCard extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerCard({
    super.key,
    this.width = double.infinity,
    this.height = 80,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: AppColors.borderColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              final slidePercent = _controller.value * 2.0 - 0.5;
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  AppColors.borderColor,
                  Color(0xFFEEEEEE),
                  AppColors.borderColor,
                ],
                stops: [
                  (slidePercent - 0.3).clamp(0.0, 1.0),
                  slidePercent.clamp(0.0, 1.0),
                  (slidePercent + 0.3).clamp(0.0, 1.0),
                ],
              ).createShader(bounds);
            },
            child: child,
          );
        },
        child: Container(color: AppColors.borderColor),
      ),
    );
  }
}
