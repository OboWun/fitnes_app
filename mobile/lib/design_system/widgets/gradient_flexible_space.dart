import 'package:flutter/material.dart';

import '../design_system.dart';

class GradientFlexibleSpace extends StatelessWidget {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget expandedChild;
  final Widget collapsedChild;
  final LinearGradient gradient;
  final BorderRadius? borderRadius;
  final double collapseThreshold;

  const GradientFlexibleSpace({
    super.key,
    required this.expandedHeight,
    required this.expandedChild,
    required this.collapsedChild,
    this.collapsedHeight = 60,
    this.gradient = AppGradients.blueLinear,
    this.borderRadius = const BorderRadius.vertical(
      bottom: Radius.circular(32),
    ),
    this.collapseThreshold = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final t = ((constraints.maxHeight - collapsedHeight) /
                (expandedHeight - collapsedHeight))
            .clamp(0.0, 1.0);

        final isCollapsed = t < collapseThreshold;

        return Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: borderRadius,
          ),
          child: AnimatedSwitcher(
            duration: Durations.short3,
            child: Builder(
              key: ValueKey(isCollapsed),
              builder: (_) {
                if (isCollapsed) return collapsedChild;
                return expandedChild;
              },
            ),
          ),
        );
      },
    );
  }
}
