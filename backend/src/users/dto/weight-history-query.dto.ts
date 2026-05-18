import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsIn } from 'class-validator';

export class WeightHistoryQueryDto {
  @ApiPropertyOptional({
    description: 'Период',
    enum: ['week', 'month', 'all'],
    example: 'all',
  })
  @IsOptional()
  @IsIn(['week', 'month', 'all'])
  period?: 'week' | 'month' | 'all';
}
