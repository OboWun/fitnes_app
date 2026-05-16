import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/view_all_link.dart';

class ViewAllLinkSmart extends StatelessWidget {
  final String route;
  final String label;

  const ViewAllLinkSmart({
    super.key,
    required this.route,
    this.label = 'Посмотреть все',
  });

  @override
  Widget build(BuildContext context) {
    return ViewAllLink(
      label: label,
      onTap: () => context.push(route),
    );
  }
}
