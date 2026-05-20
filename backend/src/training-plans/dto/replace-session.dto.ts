import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class ReplaceSessionDto {
  @ApiProperty({ example: 'tpl-leg-day' })
  @IsNotEmpty()
  @IsString()
  workoutTemplateId!: string;

  @ApiPropertyOptional({ example: 'Leg Day (replacement)' })
  @IsOptional()
  @IsString()
  name?: string;
}
