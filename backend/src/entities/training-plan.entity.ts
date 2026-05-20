import type { DayOfWeek } from './workout-template.entity.js';

export interface TrainingPlan {
  id: string;
  userId: string;
  name: string;
  isActive: boolean;
  source?: 'manual' | 'milp';
  schedule?: TrainingPlanScheduleItem[];
  createdAt: string;
}

export interface TrainingPlanScheduleItem {
  dayOfWeek: DayOfWeek;
  workoutTemplateId: string;
  time?: string;
  name?: string;
  sortOrder: number;
}
