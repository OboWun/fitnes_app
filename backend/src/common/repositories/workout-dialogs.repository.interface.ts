import type { WorkoutDialog } from '../../entities/index.js';

export const WORKOUT_DIALOGS_REPOSITORY = Symbol('WORKOUT_DIALOGS_REPOSITORY');

export interface IWorkoutDialogsRepository {
  findById(id: string): Promise<WorkoutDialog | undefined>;
  findByUserId(userId: string): Promise<WorkoutDialog[]>;
  create(
    data: Omit<WorkoutDialog, 'id' | 'createdAt' | 'updatedAt'>,
  ): Promise<WorkoutDialog>;
  update(
    id: string,
    data: Partial<
      Pick<WorkoutDialog, 'currentStep' | 'planType' | 'collectedParams'>
    >,
  ): Promise<WorkoutDialog | undefined>;
  delete(id: string): Promise<boolean>;
}
