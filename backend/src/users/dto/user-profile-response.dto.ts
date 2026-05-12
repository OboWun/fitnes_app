import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

class UserMetadataDto {
  @ApiPropertyOptional({ example: 'hypertrophy' })
  goal?: string;

  @ApiPropertyOptional({ example: 'intermediate' })
  experienceLevel?: string;

  @ApiPropertyOptional({ type: [String], example: ['barbell', 'dumbbell'] })
  availableEquipment?: string[];

  @ApiPropertyOptional({ example: 24 })
  trainingAgeMonths?: number;

  @ApiPropertyOptional({ example: 7 })
  recoveryCapacity?: number;

  @ApiPropertyOptional({ type: [String] })
  injuryHistory?: string[];

  @ApiPropertyOptional({ type: [String] })
  currentLimitations?: string[];

  @ApiPropertyOptional({ type: [String] })
  preferredExercises?: string[];

  @ApiPropertyOptional({ type: [String] })
  dislikedExercises?: string[];

  @ApiPropertyOptional({ type: [String] })
  preferredMovementPatterns?: string[];

  @ApiPropertyOptional({ example: 'preset-gym-full' })
  defaultEquipmentPresetId?: string;
}

export class UserProfileResponseDto {
  @ApiProperty({ example: 'l1a2b3c', description: 'User ID' })
  id: string;

  @ApiProperty({ example: 'device-abc123', description: 'Device identifier' })
  deviceId: string;

  @ApiPropertyOptional({ example: 'Иван', description: 'User name' })
  name?: string;

  @ApiPropertyOptional({ example: 'male', description: 'Gender' })
  gender?: string;

  @ApiPropertyOptional({ example: 75, description: 'Weight in kg' })
  weight?: number;

  @ApiPropertyOptional({ example: 180, description: 'Height in cm' })
  height?: number;

  @ApiPropertyOptional({ example: 30, description: 'Age in years' })
  age?: number;

  @ApiProperty({
    type: [String],
    example: ['herniated_disc'],
    description: 'Contraindication slugs',
  })
  contraindications: string[];

  @ApiProperty({
    example: '2026-01-01T00:00:00.000Z',
    description: 'Account creation date',
  })
  createdAt: string;

  @ApiPropertyOptional({ type: UserMetadataDto, description: 'User metadata' })
  metadata?: UserMetadataDto;
}
