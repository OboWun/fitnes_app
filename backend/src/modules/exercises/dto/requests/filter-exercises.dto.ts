import { IsString, IsOptional, IsIn } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class FilterExercisesDto {
  @ApiPropertyOptional({ description: 'Поисковой запрос по названию упражнения' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ description: 'Целевые мышцы (CSV список slug)' })
  @IsOptional()
  @IsString()
  targetMuscles?: string;

  @ApiPropertyOptional({ description: 'Вторичные мышцы (CSV список slug)' })
  @IsOptional()
  @IsString()
  secondaryMuscles?: string;

  @ApiPropertyOptional({ description: 'Части тела (CSV список slug)' })
  @IsOptional()
  @IsString()
  bodyParts?: string;

  @ApiPropertyOptional({ description: 'Оборудование (CSV список slug)' })
  @IsOptional()
  @IsString()
  equipments?: string;

  @ApiPropertyOptional({ enum: ['asc', 'desc'], default: 'asc' })
  @IsOptional()
  @IsIn(['asc', 'desc'])
  sortOrder?: 'asc' | 'desc' = 'asc';

  @ApiPropertyOptional({ enum: ['name', 'slug'], default: 'name' })
  @IsOptional()
  @IsIn(['name', 'slug'])
  sortBy?: 'name' | 'slug' = 'name';
}
