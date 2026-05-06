import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsIn, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { SessionExerciseDto } from './create-workout-session.dto.js';

export class UpdateWorkoutSessionDto {
  @ApiPropertyOptional({ enum: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'] })
  @IsOptional()
  @IsString()
  @IsIn(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'])
  dayOfWeek?: string;

  @ApiPropertyOptional({ example: '10:00' })
  @IsOptional()
  @IsString()
  time?: string;

  @ApiPropertyOptional({ enum: ['planned', 'completed', 'skipped', 'replaced'] })
  @IsOptional()
  @IsString()
  @IsIn(['planned', 'completed', 'skipped', 'replaced'])
  status?: string;

  @ApiPropertyOptional({ type: [SessionExerciseDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SessionExerciseDto)
  exercises?: SessionExerciseDto[];

  @ApiPropertyOptional()
  @IsOptional()
  metadata?: Record<string, unknown>;
}
