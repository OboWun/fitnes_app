import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

class WorkoutExerciseResponseDto {
  @ApiProperty({ example: 'band-shrug', description: 'Exercise slug' })
  exerciseSlug: string;

  @ApiProperty({ example: 3, description: 'Number of sets' })
  sets: number;

  @ApiPropertyOptional({ example: 12, description: 'Number of reps per set' })
  reps?: number;

  @ApiPropertyOptional({
    example: 90,
    description: 'Rest between sets in seconds',
  })
  restBetweenSets?: number;

  @ApiPropertyOptional({
    example: 120,
    description: 'Rest after this exercise in seconds',
  })
  restAfterExercise?: number;

  @ApiProperty({ example: 1, description: 'Order in workout' })
  order: number;
}

export class WorkoutTemplateResponseDto {
  @ApiProperty({ example: 'l1a2b3c', description: 'Template ID' })
  id: string;

  @ApiProperty({ example: 'user-id-123', description: 'Owner user ID' })
  userId: string;

  @ApiProperty({ example: 'Push Day', description: 'Template name' })
  name: string;

  @ApiPropertyOptional({
    example: 'Chest, shoulders and triceps workout',
    description: 'Description',
  })
  description?: string;

  @ApiProperty({
    type: [WorkoutExerciseResponseDto],
    description: 'Exercises',
  })
  exercises: WorkoutExerciseResponseDto[];

  @ApiProperty({
    example: '2026-01-01T00:00:00.000Z',
    description: 'Creation date',
  })
  createdAt: string;

  @ApiProperty({
    example: '2026-01-15T12:00:00.000Z',
    description: 'Last update date',
  })
  updatedAt: string;
}
