import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsArray, IsOptional, IsString } from 'class-validator';
import { Transform } from 'class-transformer';
import { PaginationQueryDto } from '../../common/dto/index.js';

export class ExerciseFilterQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Filter out exercises with these contraindication slugs (comma-separated)',
    example: 'herniated_disc,hypertension',
    type: String,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.split(',').map((s: string) => s.trim()) : value))
  @IsArray()
  @IsString({ each: true })
  contraindications?: string[];

  @ApiPropertyOptional({
    description: 'Filter by equipment slugs, ordered by preference (comma-separated, first = most preferred)',
    example: 'dumbbell,barbell,cable',
    type: String,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.split(',').map((s: string) => s.trim()) : value))
  @IsArray()
  @IsString({ each: true })
  equipments?: string[];

  @ApiPropertyOptional({
    description: 'Filter by target muscle slugs (comma-separated)',
    example: 'biceps,triceps',
    type: String,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.split(',').map((s: string) => s.trim()) : value))
  @IsArray()
  @IsString({ each: true })
  targetMuscles?: string[];

  @ApiPropertyOptional({ description: 'Search by exercise name or slug' })
  @IsOptional()
  @IsString()
  search?: string;
}
