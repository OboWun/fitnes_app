import { ApiProperty } from '@nestjs/swagger';
import { ExerciseShortResponseDto } from './exercise-short-response.dto.js';

export class PaginatedExercisesResponseDto {
  @ApiProperty({
    type: [ExerciseShortResponseDto],
    description: 'Array of exercises',
  })
  data: ExerciseShortResponseDto[];

  @ApiProperty({ example: 100, description: 'Total number of items' })
  total: number;

  @ApiProperty({ example: 1, description: 'Current page' })
  page: number;

  @ApiProperty({ example: 20, description: 'Items per page' })
  limit: number;

  @ApiProperty({ example: 5, description: 'Total number of pages' })
  totalPages: number;
}
