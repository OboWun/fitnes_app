import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNumber,
  IsOptional,
  IsArray,
  IsString,
  IsEnum,
  Min,
  Max,
} from 'class-validator';

export enum ExperienceLevel {
  BEGINNER = 'beginner',
  INTERMEDIATE = 'intermediate',
  ADVANCED = 'advanced',
}

export enum TrainingGoal {
  STRENGTH = 'strength',
  HYPERTROPHY = 'hypertrophy',
  ENDURANCE = 'endurance',
  WEIGHT_LOSS = 'weight_loss',
  GENERAL_HEALTH = 'general_health',
  REHAB = 'rehab',
  MOBILITY = 'mobility',
}

export class GenerateWorkoutDto {
  @ApiProperty({ example: 60, minimum: 20, maximum: 120 })
  @IsNumber()
  @Min(20)
  @Max(120)
  sessionDurationMin!: number;

  @ApiPropertyOptional({ example: 'intermediate', enum: ExperienceLevel })
  @IsOptional()
  @IsEnum(ExperienceLevel)
  experienceLevel?: ExperienceLevel;

  @ApiPropertyOptional({ example: 'hypertrophy', enum: TrainingGoal })
  @IsOptional()
  @IsEnum(TrainingGoal)
  goal?: TrainingGoal;

  @ApiPropertyOptional({
    type: [String],
    example: ['chest', 'back', 'arms'],
    description:
      'Abstract muscle groups to focus on (hard coverage constraint)',
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  focusMuscles?: string[];

  @ApiPropertyOptional({
    type: [String],
    example: ['upper_chest', 'lats', 'rear_delts'],
    description:
      'Specific muscles to prioritize within groups (strong bonus + hard constraint)',
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  specificMuscles?: string[];

  @ApiPropertyOptional({ type: [String], example: ['barbell', 'dumbbell'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  availableEquipment?: string[];

  @ApiPropertyOptional({
    example: 'preset-gym-full',
    description: 'Equipment preset ID — overrides availableEquipment',
  })
  @IsOptional()
  @IsString()
  equipmentPresetId?: string;

  @ApiPropertyOptional({ example: 'accumulation' })
  @IsOptional()
  @IsString()
  phase?: string;
}
