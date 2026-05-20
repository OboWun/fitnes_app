import 'workout_set.dart';

class SessionExercise {
  final String exerciseSlug;
  final int sets;
  final int order;
  final Map<String, dynamic>? metadata;
  final List<WorkoutSet> setDetails;

  const SessionExercise({
    required this.exerciseSlug,
    required this.sets,
    required this.order,
    this.metadata,
    this.setDetails = const [],
  });

  factory SessionExercise.fromJson(Map<String, dynamic> json) {
    return SessionExercise(
      exerciseSlug: json['exerciseSlug'] as String,
      sets: _toInt(json['sets']),
      order: _toInt(json['order']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      setDetails:
          (json['setDetails'] as List<dynamic>?)
              ?.map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'exerciseSlug': exerciseSlug,
      'sets': sets,
      'order': order,
      'metadata': metadata,
      'setDetails': setDetails.map((e) => e.toJson()).toList(),
    };
  }

  int? get restBetweenSets {
    final v = metadata?['restBetweenSets'];
    return v is int ? v : (v is num ? v.toInt() : null);
  }

  int? get restAfterExercise {
    final v = metadata?['restAfterExercise'];
    return v is int ? v : (v is num ? v.toInt() : null);
  }

  static int _toInt(dynamic v) =>
      (v is num) ? v.toInt() : (v is String) ? int.tryParse(v) ?? 0 : 0;
}
