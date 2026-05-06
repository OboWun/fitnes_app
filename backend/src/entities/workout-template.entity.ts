export type DayOfWeek =
  | 'monday'
  | 'tuesday'
  | 'wednesday'
  | 'thursday'
  | 'friday'
  | 'saturday'
  | 'sunday';

export interface WorkoutExercise {
  exerciseSlug: string;
  sets: number;
  reps?: number;
  restBetweenSets?: number;
  restAfterExercise?: number;
  order: number;
}

export interface WorkoutTemplateMetadata {
  sessionDurationMin?: number;
  trainingGoal?: string;
  expectedLoad?: number;
  recoveryWindowDays?: number;
  blockType?: string;
  phase?: string;
}

export interface WorkoutTemplate {
  id: string;
  userId: string;
  name: string;
  description?: string;
  exercises: WorkoutExercise[];
  metadata?: WorkoutTemplateMetadata;
  createdAt: string;
  updatedAt: string;
}

export interface ScheduledWorkout {
  id: string;
  templateId: string;
  userId: string;
  dayOfWeek: DayOfWeek;
  time: string;
  createdAt: string;
}
