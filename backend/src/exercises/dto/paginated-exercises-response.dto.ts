import { ApiProperty } from '@nestjs/swagger';
import { ExerciseResponseDto } from './exercise-response.dto.js';

export class PaginatedExercisesResponseDto {
  @ApiProperty({ type: [ExerciseResponseDto], description: 'Array of exercises' })
  data: ExerciseResponseDto[];

  @ApiProperty({ example: 100, description: 'Total number of items' })
  total: number;

  @ApiProperty({ example: 1, description: 'Current page' })
  page: number;

  @ApiProperty({ example: 20, description: 'Items per page' })
  limit: number;

  @ApiProperty({ example: 5, description: 'Total number of pages' })
  totalPages: number;
}
