class WorkoutSet {
  final int setNumber;
  final String setType;
  final double? plannedWeightKg;
  final int? plannedReps;
  final int? plannedDurationSec;
  final double? plannedDistanceM;
  final double? actualWeightKg;
  final int? actualReps;
  final int? actualDurationSec;
  final double? actualDistanceM;
  final double? actualRpe;
  final String? completedAt;

  const WorkoutSet({
    required this.setNumber,
    this.setType = 'working',
    this.plannedWeightKg,
    this.plannedReps,
    this.plannedDurationSec,
    this.plannedDistanceM,
    this.actualWeightKg,
    this.actualReps,
    this.actualDurationSec,
    this.actualDistanceM,
    this.actualRpe,
    this.completedAt,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      setNumber: _toInt(json['setNumber']),
      setType: json['setType'] as String? ?? 'working',
      plannedWeightKg: _toDouble(json['plannedWeightKg']),
      plannedReps: _toIntOrNull(json['plannedReps']),
      plannedDurationSec: _toIntOrNull(json['plannedDurationSec']),
      plannedDistanceM: _toDouble(json['plannedDistanceM']),
      actualWeightKg: _toDouble(json['actualWeightKg']),
      actualReps: _toIntOrNull(json['actualReps']),
      actualDurationSec: _toIntOrNull(json['actualDurationSec']),
      actualDistanceM: _toDouble(json['actualDistanceM']),
      actualRpe: _toDouble(json['actualRpe']),
      completedAt: json['completedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'setNumber': setNumber,
      'setType': setType,
      'plannedWeightKg': plannedWeightKg,
      'plannedReps': plannedReps,
      'plannedDurationSec': plannedDurationSec,
      'plannedDistanceM': plannedDistanceM,
      'actualWeightKg': actualWeightKg,
      'actualReps': actualReps,
      'actualDurationSec': actualDurationSec,
      'actualDistanceM': actualDistanceM,
      'actualRpe': actualRpe,
      'completedAt': completedAt,
    };
  }

  WorkoutSet copyWith({
    int? setNumber,
    String? setType,
    double? plannedWeightKg,
    int? plannedReps,
    int? plannedDurationSec,
    double? plannedDistanceM,
    double? actualWeightKg,
    int? actualReps,
    int? actualDurationSec,
    double? actualDistanceM,
    double? actualRpe,
    String? completedAt,
    bool clearCompletedAt = false,
  }) {
    return WorkoutSet(
      setNumber: setNumber ?? this.setNumber,
      setType: setType ?? this.setType,
      plannedWeightKg: plannedWeightKg ?? this.plannedWeightKg,
      plannedReps: plannedReps ?? this.plannedReps,
      plannedDurationSec: plannedDurationSec ?? this.plannedDurationSec,
      plannedDistanceM: plannedDistanceM ?? this.plannedDistanceM,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      actualReps: actualReps ?? this.actualReps,
      actualDurationSec: actualDurationSec ?? this.actualDurationSec,
      actualDistanceM: actualDistanceM ?? this.actualDistanceM,
      actualRpe: actualRpe ?? this.actualRpe,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  static double? _toDouble(dynamic v) =>
      (v is num) ? v.toDouble() : (v is String) ? double.tryParse(v) : null;

  static int? _toIntOrNull(dynamic v) =>
      (v is num) ? v.toInt() : (v is String) ? int.tryParse(v) : null;

  static int _toInt(dynamic v) =>
      (v is num) ? v.toInt() : (v is String) ? int.tryParse(v) ?? 0 : 0;
}
