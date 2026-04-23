export interface Contraindication {
  name: string;
  slug: string;
}

export interface ContraindicationSeverity {
  slug: string;
  severity: 'forbidden' | 'not_recommended' | 'low_weight';
}
