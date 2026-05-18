import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsBoolean } from 'class-validator';
import { Transform } from 'class-transformer';

export class SkipSessionDto {
  @ApiPropertyOptional({ description: 'Create a duplicate session on next available day' })
  @IsOptional()
  @Transform(({ value }) => value === true || value === 'true')
  @IsBoolean()
  reschedule?: boolean;
}
