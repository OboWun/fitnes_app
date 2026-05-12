import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class GeneratedExerciseDto {
  @ApiProperty()
  exerciseSlug!: string;

  @ApiProperty()
  sets!: number;

  @ApiProperty({ example: 10, description: 'Recommended reps per set' })
  repsPerSet!: number;

  @ApiProperty()
  order!: number;
}

export class WorkoutMetricsDto {
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

export class GenerateWorkoutResponseDto {
  @ApiProperty({ type: [GeneratedExerciseDto] })
  exercises!: GeneratedExerciseDto[];

  @ApiProperty({ example: 3200 })
  totalTimeSec!: number;

  @ApiPropertyOptional()
  totalLoadByMuscle?: Record<string, number>;

  @ApiPropertyOptional()
  templateId?: string;

  @ApiPropertyOptional({
    example: false,
    description: 'True if fallback algorithm was used',
  })
  usedFallback?: boolean;

  @ApiPropertyOptional({
    example: false,
    description: 'True if not all mandatory muscles could be covered',
  })
  partialCoverage?: boolean;

  @ApiPropertyOptional({
    example: ['back'],
    description: 'List of mandatory muscles that could not be covered',
  })
  unmetMandatory?: string[];

  @ApiPropertyOptional({ type: WorkoutMetricsDto })
  metrics?: WorkoutMetricsDto;
}
