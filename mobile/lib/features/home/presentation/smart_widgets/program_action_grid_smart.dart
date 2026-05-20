import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/program_action_grid.dart';

class ProgramActionGridSmart extends StatelessWidget {
  const ProgramActionGridSmart({super.key});

  @override
  Widget build(BuildContext context) {
    return ProgramActionGrid(
      onCoachTap: () => context.push('/workout-dialog'),
      onManualTap: () => context.push('/training-plans/new'),
    );
  }
}
