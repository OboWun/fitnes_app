export interface TrainingBlockMetadata {
  phase?: string;
  weekType?: string;
  splitName?: string;
  experienceLevel?: string;
  goal?: string;
  gender?: string;
  minRestDays?: number;
  maxRestDays?: number;
  weeklyLoadLimit?: number;
  consecutiveTrainingDaysLimit?: number;
}

export interface TrainingBlock {
  id: string;
  userId: string;
  name: string;
  type: 'base' | 'build' | 'taper' | 'recovery';
  index: number;
  durationWeeks: number;
  goal?: string;
  targetMuscles?: string[];
  metadata?: TrainingBlockMetadata;
}
