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
} from 'class-validator';
import { ExperienceLevel, TrainingGoal } from './generate-workout.dto.js';

export class GenerateWeeklyPlanDto {
  @ApiProperty({ type: [String], example: ['monday', 'wednesday', 'friday'] })
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
  availableDays!: string[];

  @ApiProperty({ example: 3, minimum: 2, maximum: 6 })
  @IsNumber()
  @Min(2)
  @Max(6)
  trainingCountPerWeek!: number;

  @ApiProperty({ example: 60, minimum: 20, maximum: 120 })
  @IsNumber()
  @Min(20)
  @Max(120)
  sessionDurationMin!: number;

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
}
