import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/dictionary_grid.dart';

class DictionaryGridSmart extends StatelessWidget {
  const DictionaryGridSmart({super.key});

  @override
  Widget build(BuildContext context) {
    return DictionaryGrid(
      onEquipmentTap: () => context.go('/equipment'),
      onMusclesTap: () => context.go('/muscles'),
      onExercisesTap: () => context.go('/exercises'),
    );
  }
}
