export type SetType = 'warmup' | 'working' | 'dropset';

export interface WorkoutSessionSet {
  sessionId: string;
  exerciseSlug: string;
  setNumber: number;
  setType: SetType;

  plannedWeightKg?: number;
  plannedReps?: number;
  plannedDurationSec?: number;
  plannedDistanceM?: number;

  actualWeightKg?: number;
  actualReps?: number;
  actualDurationSec?: number;
  actualDistanceM?: number;
  actualRpe?: number;

  completedAt?: Date;
}

export type MeasurementType = 'weight_reps' | 'duration_distance' | 'reps_only';

export const COMPOUND_PATTERNS = new Set([
  'squat', 'press', 'pull', 'hinge', 'row', 'lunge',
]);

export const CARDIO_PATTERNS = new Set(['locomotion']);

export function getMeasurementType(
  movementPattern?: string,
): MeasurementType {
  if (movementPattern && CARDIO_PATTERNS.has(movementPattern))
    return 'duration_distance';
  return 'weight_reps';
}

export function isCompoundExercise(movementPattern?: string): boolean {
  return !!movementPattern && COMPOUND_PATTERNS.has(movementPattern);
}
