import { IsString, IsOptional } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class SearchExercisesDto {
  @ApiPropertyOptional({ description: 'Поисковой запрос' })
  @IsOptional()
  @IsString()
  query?: string;

  @ApiPropertyOptional({ description: 'Порог релевантности (0-1)', default: 0.3 })
  @IsOptional()
  @IsString()
  threshold?: string;
}
