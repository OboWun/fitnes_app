import 'package:flutter/cupertino.dart';
import 'package:mobile/core/widgets/sliver_adapter.dart';


class SliverGap extends StatelessWidget {
  const SliverGap({this.horizontal, this.vertical, super.key});

  final double? vertical;
  final double? horizontal;
  @override
  Widget build(BuildContext context) {
    return SliverAdapter(
      child: SizedBox(
        height: vertical,
        width: horizontal,
      ),
    );
  }
}
