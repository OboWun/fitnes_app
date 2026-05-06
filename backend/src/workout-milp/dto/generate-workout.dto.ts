import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNumber, IsOptional, IsArray, IsString, Min, Max } from 'class-validator';

export class GenerateWorkoutDto {
  @ApiProperty({ example: 60, minimum: 20, maximum: 120 })
  @IsNumber()
  @Min(20)
  @Max(120)
  sessionDurationMin!: number;

  @ApiProperty({ example: 5, minimum: 3, maximum: 8 })
  @IsNumber()
  @Min(3)
  @Max(8)
  exerciseCount!: number;

  @ApiProperty({ example: 3, minimum: 1, maximum: 6 })
  @IsNumber()
  @Min(1)
  @Max(6)
  setsPerExercise!: number;

  @ApiPropertyOptional({ example: 90, description: 'Rest time between sets in seconds', minimum: 30, maximum: 300 })
  @IsOptional()
  @IsNumber()
  @Min(30)
  @Max(300)
  restBetweenSetsSec?: number;

  @ApiPropertyOptional({ type: [String], example: ['barbell', 'dumbbell'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  availableEquipment?: string[];

  @ApiPropertyOptional({ example: 'accumulation' })
  @IsOptional()
  @IsString()
  phase?: string;

  @ApiPropertyOptional({ type: [String], example: ['chest', 'back'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  mandatoryMuscles?: string[];
}
