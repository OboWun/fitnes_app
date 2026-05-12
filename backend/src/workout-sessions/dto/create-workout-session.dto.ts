import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsNumber,
  IsArray,
  IsIn,
  ValidateNested,
  Min,
  Max,
} from 'class-validator';
import { Type } from 'class-transformer';

export class SessionExerciseDto {
  @ApiProperty({ example: 'bench-press' })
  @IsNotEmpty()
  @IsString()
  exerciseSlug!: string;

  @ApiProperty({ example: 3 })
  @IsNumber()
  @Min(1)
  @Max(10)
  sets!: number;

  @ApiProperty({ example: 1 })
  @IsNumber()
  order!: number;

  @ApiPropertyOptional()
  @IsOptional()
  metadata?: Record<string, unknown>;
}

export class WorkoutSessionMetadataDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  previousSessionId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  nextSessionId?: string;

  @ApiPropertyOptional({ example: 60 })
  @IsOptional()
  @IsNumber()
  sessionDurationMin?: number;

  @ApiPropertyOptional()
  @IsOptional()
  mandatoryMuscles?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  forbiddenExercises?: string[];

  @ApiPropertyOptional({ example: 5 })
  @IsOptional()
  @IsNumber()
  allowedTimeDeviationMin?: number;

  @ApiPropertyOptional({ example: 0.2 })
  @IsOptional()
  @IsNumber()
  allowedLoadDeviation?: number;
}

export class CreateWorkoutSessionDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  blockId!: string;

  @ApiProperty({
    example: 'monday',
    enum: [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ],
  })
  @IsNotEmpty()
  @IsString()
  @IsIn([
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ])
  dayOfWeek!: string;

  @ApiPropertyOptional({ example: '09:00' })
  @IsOptional()
  @IsString()
  time?: string;

  @ApiPropertyOptional({
    enum: ['planned', 'completed', 'skipped', 'replaced'],
  })
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
  metadata?: WorkoutSessionMetadataDto;
}
