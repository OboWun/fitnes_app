import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsInt, Min, IsIn } from 'class-validator';
import { Transform } from 'class-transformer';

export class WorkoutSessionsQueryDto {
  @ApiPropertyOptional({
    description: 'Ограничение количества',
    example: 10,
  })
  @IsOptional()
  @Transform(({ value }) => (value ? parseInt(value, 10) : undefined))
  @IsInt()
  @Min(1)
  limit?: number;

  @ApiPropertyOptional({
    description: 'Фильтр по статусу (CSV): planned, completed, skipped, replaced',
    example: 'completed',
  })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({
    description: 'Сортировка',
    enum: ['id_desc', 'id_asc'],
    example: 'id_desc',
  })
  @IsOptional()
  @IsIn(['id_desc', 'id_asc'])
  sort?: 'id_desc' | 'id_asc';
}
