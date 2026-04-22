export interface ContraindicationSeverity {
  slug: string;
  severity: 'forbidden' | 'not_recommended' | 'low_weight';
}

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
