import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNumber, IsOptional, IsArray, Min } from 'class-validator';

export class ExerciseInputDto {
  @ApiProperty()
  exerciseSlug!: string;

  @ApiProperty()
  sets!: number;

  @ApiPropertyOptional()
  order?: number;
}

export class WorkoutMetricsInputDto {
  @ApiProperty({ type: [ExerciseInputDto] })
  @IsArray()
  exercises!: ExerciseInputDto[];

  @ApiPropertyOptional({
    example: 90,
    description: 'Rest time between sets in seconds',
  })
  @IsOptional()
  @IsNumber()
  @Min(30)
  restBetweenSetsSec?: number;

  @ApiPropertyOptional({
    example: 75,
    description: 'User bodyweight in kg, for calorie estimation',
  })
  @IsOptional()
  @IsNumber()
  @Min(30)
  bodyweightKg?: number;

  @ApiPropertyOptional({
    example: 'hypertrophy',
    description: 'Training goal for intensity estimation',
  })
  @IsOptional()
  goal?: string;
}

export class WorkoutMetricsResponseDto {
  @ApiProperty({ example: 15 })
  totalSets!: number;

  @ApiProperty({ example: 120 })
  totalReps!: number;

  @ApiProperty({ example: 4500 })
  estimatedTonnageKg!: number;

  @ApiProperty({ example: 72 })
  relativeIntensity!: number;

  @ApiProperty({ example: 1200 })
  activeTimeSec!: number;

  @ApiProperty({ example: 900 })
  restTimeSec!: number;

  @ApiProperty({ example: 280 })
  estimatedCalories!: number;

  @ApiProperty({ example: { chest: 85, back: 72, legs: 45 } })
  muscleLoadScores!: Record<string, number>;

  @ApiProperty({ example: 65 })
  fatigueIndex!: number;
}
