import type { WorkoutSession, WorkoutSessionExercise } from '../../entities/index.js';

export const WORKOUT_SESSIONS_REPOSITORY = Symbol('WORKOUT_SESSIONS_REPOSITORY');

export interface IWorkoutSessionsRepository {
  findByBlockId(blockId: string): Promise<WorkoutSession[]>;
  findByUserId(userId: string): Promise<WorkoutSession[]>;
  findById(id: string): Promise<WorkoutSession | undefined>;
  create(
    data: Omit<WorkoutSession, 'id'> & { exercises?: WorkoutSessionExercise[] },
  ): Promise<WorkoutSession>;
  update(
    id: string,
    data: Partial<Omit<WorkoutSession, 'id' | 'userId' | 'blockId'>> & { exercises?: WorkoutSessionExercise[] },
  ): Promise<WorkoutSession | undefined>;
  delete(id: string): Promise<boolean>;
  findRecentCompletedByUserId(userId: string, daysBack: number): Promise<WorkoutSession[]>;
}
