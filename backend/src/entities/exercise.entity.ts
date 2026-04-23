import type { ContraindicationSeverity } from './contraindication.entity.js';

export type ExerciseType =
  | 'strength'
  | 'hypertrophy'
  | 'endurance'
  | 'mobility'
  | 'stability'
  | 'cardio'
  | 'plyometric'
  | 'rehab'
  | 'stretching';

export type Difficulty = 'beginner' | 'intermediate' | 'advanced';

export type MovementPattern =
  | 'push'
  | 'pull'
  | 'squat'
  | 'hinge'
  | 'lunge'
  | 'carry'
  | 'rotate'
  | 'anti_rotate'
  | 'jump'
  | 'crawl'
  | 'press'
  | 'row'
  | 'curl'
  | 'extension'
  | 'flexion'
  | 'abduction'
  | 'adduction'
  | 'rotation'
  | 'stabilization'
  | 'locomotion'
  | 'stretch';

export interface Exercise {
  exerciseId: string;
  name: string;
  slug: string;
  gifUrl: string;
  targetMuscles: string[];
  bodyParts: string[];
  equipments: string[];
  secondaryMuscles?: string[];
  instructions: string[];
  contraindications?: ContraindicationSeverity[];
  alias?: string[];
  exerciseType?: ExerciseType;
  description?: string;
  confidence?: number;
  difficulty?: Difficulty;
  movementPattern?: MovementPattern;
  variations?: string[];
}
