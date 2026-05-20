import type { TrainingPlan, TrainingPlanSession } from '../../entities/index.js';

export const TRAINING_PLANS_REPOSITORY = Symbol('TRAINING_PLANS_REPOSITORY');

export interface ITrainingPlansRepository {
  findByUserId(userId: string): Promise<TrainingPlan[]>;
  findById(id: string): Promise<TrainingPlan | undefined>;
  findActiveByUserId(userId: string): Promise<TrainingPlan | undefined>;
  create(
    data: Omit<TrainingPlan, 'id' | 'createdAt'> & {
      schedule?: TrainingPlan['schedule'];
    },
  ): Promise<TrainingPlan>;
  update(
    id: string,
    data: Partial<Omit<TrainingPlan, 'id' | 'userId' | 'createdAt'>> & {
      schedule?: TrainingPlan['schedule'];
    },
  ): Promise<TrainingPlan | undefined>;
  delete(id: string): Promise<boolean>;
  activate(id: string): Promise<void>;
  deactivateByUserId(userId: string): Promise<void>;
  assignTemplate(
    planId: string,
    dayOfWeek: string,
    workoutTemplateId: string,
    time?: string,
    name?: string,
  ): Promise<void>;
  unassignTemplate(planId: string, dayOfWeek: string): Promise<void>;

  createPlanSession(data: Omit<TrainingPlanSession, 'id' | 'createdAt'>): Promise<TrainingPlanSession>;
  findActivePlanSession(userId: string): Promise<TrainingPlanSession | undefined>;
  updatePlanSessionWeek(sessionId: string, week: number): Promise<void>;
  archivePlanSession(sessionId: string): Promise<void>;
}
