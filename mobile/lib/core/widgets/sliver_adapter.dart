import 'package:flutter/cupertino.dart';

class SliverAdapter extends StatelessWidget {
  const SliverAdapter({
    super.key,
    this.padding,
    required this.child,
  });

  final EdgeInsets? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = this.padding;
    final sliver = SliverToBoxAdapter(child: child);
    if (padding == null) return sliver;
    return SliverPadding(
      padding: padding,
      sliver: sliver,
    );
  }
}
