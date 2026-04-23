import type { ContraindicationSeverity } from './contraindication.entity.js';

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
}
