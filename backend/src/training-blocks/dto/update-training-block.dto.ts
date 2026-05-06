import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsNumber, IsArray, IsIn } from 'class-validator';
import { TrainingBlockMetadataDto } from './create-training-block.dto.js';

export class UpdateTrainingBlockDto {
  @ApiPropertyOptional({ example: 'Week 1 Updated' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ enum: ['base', 'build', 'taper', 'recovery'] })
  @IsOptional()
  @IsString()
  @IsIn(['base', 'build', 'taper', 'recovery'])
  type?: 'base' | 'build' | 'taper' | 'recovery';

  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @IsNumber()
  index?: number;

  @ApiPropertyOptional({ example: 6 })
  @IsOptional()
  @IsNumber()
  durationWeeks?: number;

  @ApiPropertyOptional({ example: 'hypertrophy' })
  @IsOptional()
  @IsString()
  goal?: string;

  @ApiPropertyOptional({ example: ['chest', 'shoulders'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  targetMuscles?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  metadata?: TrainingBlockMetadataDto;
}
