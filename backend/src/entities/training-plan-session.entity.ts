export interface TrainingPlanSession {
  id: string;
  planId: string;
  userId: string;
  startedAt: string;
  currentWeek: number;
  status: 'active' | 'completed' | 'archived';
  createdAt: string;
}
