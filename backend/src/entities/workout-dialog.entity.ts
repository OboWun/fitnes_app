export interface WorkoutDialog {
  id: string;
  userId: string;
  currentStep: string;
  planType?: string;
  collectedParams: Record<string, unknown>;
  createdAt: string;
  updatedAt: string;
}
