class ExerciseFilter {
  final int page;
  final int limit;
  final String? search;
  final List<String> equipments;
  final List<String> targetMuscles;
  final bool isPersonal;
  final String? presetId;
  final String? presetName;

  const ExerciseFilter({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.equipments = const [],
    this.targetMuscles = const [],
    this.isPersonal = true,
    this.presetId,
    this.presetName,
  });

  ExerciseFilter copyWith({
    int? page,
    int? limit,
    String? search,
    List<String>? equipments,
    List<String>? targetMuscles,
    bool? isPersonal,
    String? presetId,
    String? presetName,
  }) {
    return ExerciseFilter(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      equipments: equipments ?? this.equipments,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      isPersonal: isPersonal ?? this.isPersonal,
      presetId: presetId ?? this.presetId,
      presetName: presetName ?? this.presetName,
    );
  }

  bool get hasActiveFilters =>
      equipments.isNotEmpty || targetMuscles.isNotEmpty || presetId != null;

  ExerciseFilter copyWithClearPreset() {
    return ExerciseFilter(
      page: page,
      limit: limit,
      search: search,
      equipments: equipments,
      targetMuscles: targetMuscles,
      isPersonal: isPersonal,
      presetId: null,
      presetName: null,
    );
  }
}
