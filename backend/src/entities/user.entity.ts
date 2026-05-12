export interface UserMetadata {
  goal?: string | null;
  trainingAgeMonths?: number | null;
  experienceLevel?: string | null;
  recoveryCapacity?: number | null;
  availableEquipment?: string[] | null;
  injuryHistory?: string[] | null;
  currentLimitations?: string[] | null;
  preferredExercises?: string[] | null;
  dislikedExercises?: string[] | null;
  preferredMovementPatterns?: string[] | null;
  defaultEquipmentPresetId?: string | null;
}

export interface User {
  id: string;
  deviceId: string;
  name?: string;
  gender?: 'male' | 'female';
  weight?: number;
  height?: number;
  age?: number;
  contraindications?: string[];
  createdAt: string;
  metadata?: UserMetadata;
}
