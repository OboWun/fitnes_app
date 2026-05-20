import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { ScheduleItemDto } from './create-plan.dto.js';

export class UpdateTrainingPlanDto {
  @ApiPropertyOptional({ example: 'Updated Plan' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ type: [ScheduleItemDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ScheduleItemDto)
  schedule?: ScheduleItemDto[];
}
