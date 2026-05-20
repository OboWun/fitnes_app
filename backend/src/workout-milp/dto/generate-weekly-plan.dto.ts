import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNumber,
  IsOptional,
  IsArray,
  IsString,
  Min,
  Max,
  IsIn,
  IsEnum,
  ValidateIf,
} from 'class-validator';
import { ExperienceLevel, TrainingGoal, ActivityLevel } from './generate-workout.dto.js';

export enum SplitType {
  AUTO = 'auto',
  FULL_BODY = 'full_body',
  UPPER_LOWER = 'upper_lower',
  PPL = 'ppl',
}

export enum CardioPreference {
  RUNNING = 'running',
  CYCLING = 'cycling',
  ROWING = 'rowing',
  JUMP_ROPE = 'jump_rope',
  SWIMMING = 'swimming',
  ANY = 'any',
}

export enum EnduranceType {
  MUSCULAR = 'muscular',
  CARDIO = 'cardio',
  MIXED = 'mixed',
}

export enum PrimaryLift {
  SQUAT = 'squat',
  BENCH = 'bench',
  DEADLIFT = 'deadlift',
  OHP = 'ohp',
}

export class GenerateWeeklyPlanDto {
  @ApiPropertyOptional({
    type: [String],
    example: ['monday', 'wednesday', 'friday'],
    description: 'Available days. Empty = all days (auto)',
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @IsIn(
    [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ],
    { each: true },
  )
  availableDays?: string[];

  @ApiPropertyOptional({
    example: 3,
    minimum: 2,
    maximum: 6,
    nullable: true,
    description: 'Workouts per week. null = auto from goal+experience',
  })
  @IsOptional()
  @ValidateIf((o) => o.trainingCountPerWeek !== null)
  @IsNumber()
  @Min(2)
  @Max(6)
  trainingCountPerWeek?: number | null;

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

  @ApiPropertyOptional({ enum: ExperienceLevel, example: 'intermediate' })
  @IsOptional()
  @IsEnum(ExperienceLevel)
  experienceLevel?: ExperienceLevel;

  @ApiPropertyOptional({ enum: TrainingGoal, example: 'hypertrophy' })
  @IsOptional()
  @IsEnum(TrainingGoal)
  goal?: TrainingGoal;

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

  @ApiPropertyOptional({ enum: SplitType, description: 'Split type. auto = MILP selects' })
  @IsOptional()
  @IsEnum(SplitType)
  splitType?: SplitType;

  @ApiPropertyOptional({ enum: ActivityLevel, description: 'Daily activity level' })
  @IsOptional()
  @IsEnum(ActivityLevel)
  activityLevel?: ActivityLevel;

  @ApiPropertyOptional({ enum: CardioPreference, description: 'Preferred cardio type (weight_loss/endurance)' })
  @IsOptional()
  @IsEnum(CardioPreference)
  cardioPreference?: CardioPreference;

  @ApiPropertyOptional({
    type: [String],
    description: 'Primary lifts to build around (strength). squat/bench/deadlift/ohp',
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @IsIn(['squat', 'bench', 'deadlift', 'ohp'], { each: true })
  primaryLifts?: string[];

  @ApiPropertyOptional({ enum: EnduranceType, description: 'Endurance type (endurance goal)' })
  @IsOptional()
  @IsEnum(EnduranceType)
  enduranceType?: EnduranceType;

  @ApiPropertyOptional({ example: 75, description: 'Target weight in kg (weight_loss tracking)' })
  @IsOptional()
  @IsNumber()
  targetWeightKg?: number;
}
