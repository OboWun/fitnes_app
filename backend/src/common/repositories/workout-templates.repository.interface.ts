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
  findByUserId(userId: string): WorkoutTemplate[];
  findById(id: string): WorkoutTemplate | undefined;
  create(
    data: Omit<WorkoutTemplate, 'id' | 'createdAt' | 'updatedAt'>,
  ): WorkoutTemplate;
  update(
    id: string,
    data: Partial<
      Omit<WorkoutTemplate, 'id' | 'userId' | 'createdAt' | 'updatedAt'>
    >,
  ): WorkoutTemplate | undefined;
  delete(id: string): boolean;
}

export interface IScheduledWorkoutsRepository {
  findByUserId(userId: string): ScheduledWorkout[];
  findById(id: string): ScheduledWorkout | undefined;
  findByUserIdAndDay(userId: string, dayOfWeek: string): ScheduledWorkout[];
  create(data: Omit<ScheduledWorkout, 'id' | 'createdAt'>): ScheduledWorkout;
  update(
    id: string,
    data: Partial<Omit<ScheduledWorkout, 'id' | 'userId' | 'createdAt'>>,
  ): ScheduledWorkout | undefined;
  delete(id: string): boolean;
}
