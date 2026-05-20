import type { DayOfWeek } from './workout-template.entity.js';

export interface WorkoutSessionMetadata {
  previousSessionId?: string;
  nextSessionId?: string;
  sessionDurationMin?: number;
  sessionType?: string;
  repsPerSet?: number;
  sessionLoadByMuscle?: { slug: string; load: number }[];
  mandatoryMuscles?: string[];
  forbiddenExercises?: string[];
  allowedTimeDeviationMin?: number;
  allowedLoadDeviation?: number;
  autoSkipped?: boolean;
  rescheduledFrom?: string;
}

export interface WorkoutSession {
  id: string;
  planSessionId: string;
  userId: string;
  dayOfWeek: DayOfWeek;
  time?: string;
  weekNumber?: number;
  status?: 'planned' | 'completed' | 'skipped' | 'replaced';
  exercises?: WorkoutSessionExercise[];
  metadata?: WorkoutSessionMetadata;
}

export interface WorkoutSessionExercise {
  sessionId?: string;
  exerciseSlug: string;
  sets: number;
  order: number;
  metadata?: WorkoutSessionExerciseMetadata;
}

export interface WorkoutSessionExerciseMetadata {
  targetLoad?: number;
  setWeight?: number;
}
