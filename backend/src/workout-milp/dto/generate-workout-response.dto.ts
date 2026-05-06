import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class GeneratedExerciseDto {
  @ApiProperty()
  exerciseSlug!: string;

  @ApiProperty()
  sets!: number;

  @ApiProperty()
  order!: number;
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

  @ApiPropertyOptional({ example: false, description: 'True if fallback algorithm was used' })
  usedFallback?: boolean;

  @ApiPropertyOptional({ example: false, description: 'True if not all mandatory muscles could be covered' })
  partialCoverage?: boolean;

  @ApiPropertyOptional({ example: ['back'], description: 'List of mandatory muscles that could not be covered' })
  unmetMandatory?: string[];
}
