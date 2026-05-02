import type {
  WorkoutTemplate,
  ScheduledWorkout,
} from '../../entities/index.js';

export const WORKOUT_TEMPLATES_REPOSITORY = Symbol(
  'WORKOUT_TEMPLATES_REPOSITORY',
);
export const SCHEDULED_WORKOUTS_REPOSITORY = Symbol(
  'SCHEDULED_WORKOUTS_REPOSITORY',
);

export interface IWorkoutTemplatesRepository {
  findByUserId(userId: string): Promise<WorkoutTemplate[]>;
  findById(id: string): Promise<WorkoutTemplate | undefined>;
  create(
    data: Omit<WorkoutTemplate, 'id' | 'createdAt' | 'updatedAt'>,
  ): Promise<WorkoutTemplate>;
  update(
    id: string,
    data: Partial<
      Omit<WorkoutTemplate, 'id' | 'userId' | 'createdAt' | 'updatedAt'>
    >,
  ): Promise<WorkoutTemplate | undefined>;
  delete(id: string): Promise<boolean>;
}

export interface IScheduledWorkoutsRepository {
  findByUserId(userId: string): Promise<ScheduledWorkout[]>;
  findById(id: string): Promise<ScheduledWorkout | undefined>;
  findByUserIdAndDay(userId: string, dayOfWeek: string): Promise<ScheduledWorkout[]>;
  create(data: Omit<ScheduledWorkout, 'id' | 'createdAt'>): Promise<ScheduledWorkout>;
  update(
    id: string,
    data: Partial<Omit<ScheduledWorkout, 'id' | 'userId' | 'createdAt'>>,
  ): Promise<ScheduledWorkout | undefined>;
  delete(id: string): Promise<boolean>;
}
