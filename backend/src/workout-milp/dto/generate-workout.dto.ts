import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNumber,
  IsOptional,
  IsArray,
  IsString,
  IsEnum,
  Min,
  Max,
  ValidateIf,
  IsIn,
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
  GLUTE_GROWTH = 'glute_growth',
  RECOMPOSITION = 'recomposition',
}

export enum ActivityLevel {
  SEDENTARY = 'sedentary',
  LIGHT = 'light',
  MODERATE = 'moderate',
  ACTIVE = 'active',
}

export class GenerateWorkoutDto {
  @ApiPropertyOptional({
    example: 60,
    minimum: 20,
    maximum: 120,
    nullable: true,
    description: 'Session duration in minutes. null = auto from goal+experience',
  })
  @IsOptional()
  @ValidateIf((o) => o.sessionDurationMin !== null)
  @IsNumber()
  @Min(20)
  @Max(120)
  sessionDurationMin?: number | null;

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

  @ApiPropertyOptional({ enum: ActivityLevel, description: 'Daily activity level. Affects weekly volume scale' })
  @IsOptional()
  @IsEnum(ActivityLevel)
  activityLevel?: ActivityLevel;

  @ApiPropertyOptional({ description: 'Preferred cardio type for weight_loss' })
  @IsOptional()
  @IsString()
  cardioPreference?: string;

  @ApiPropertyOptional({
    type: [String],
    description: 'Primary lifts to prioritize (squat/bench/deadlift/ohp)',
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @IsIn(['squat', 'bench', 'deadlift', 'ohp'], { each: true })
  primaryLifts?: string[];

  @ApiPropertyOptional({ description: 'Endurance type: muscular/cardio/mixed' })
  @IsOptional()
  @IsString()
  enduranceType?: string;
}
