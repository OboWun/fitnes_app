import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNumber, IsOptional, IsArray, IsString, Min, Max, IsIn } from 'class-validator';

export class GenerateWeeklyPlanDto {
  @ApiProperty({ type: [String], example: ['monday', 'wednesday', 'friday'] })
  @IsArray()
  @IsString({ each: true })
  @IsIn(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'], { each: true })
  availableDays!: string[];

  @ApiProperty({ example: 3, minimum: 2, maximum: 6 })
  @IsNumber()
  @Min(2)
  @Max(6)
  trainingCountPerWeek!: number;

  @ApiProperty({ example: 60, minimum: 20, maximum: 120 })
  @IsNumber()
  @Min(20)
  @Max(120)
  sessionDurationMin!: number;

  @ApiPropertyOptional({ example: 5, minimum: 3, maximum: 8 })
  @IsOptional()
  @IsNumber()
  @Min(3)
  @Max(8)
  exerciseCount?: number;

  @ApiPropertyOptional({ example: 3, minimum: 1, maximum: 6 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(6)
  setsPerExercise?: number;

  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  minRestDays?: number;

  @ApiPropertyOptional({ example: 3 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  maxRestDays?: number;

  @ApiPropertyOptional({ example: 500 })
  @IsOptional()
  @IsNumber()
  weeklyLoadLimit?: number;

  @ApiPropertyOptional({ example: 2 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  consecutiveTrainingDaysLimit?: number;

  @ApiPropertyOptional({ example: 'accumulation' })
  @IsOptional()
  @IsString()
  phase?: string;

  @ApiPropertyOptional({ example: 'base', enum: ['base', 'build', 'taper', 'recovery'] })
  @IsOptional()
  @IsString()
  weekType?: string;

  @ApiPropertyOptional({ type: [String], example: ['barbell', 'dumbbell'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  availableEquipment?: string[];

  @ApiPropertyOptional({ type: [String], example: ['chest', 'back'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  mandatoryMuscles?: string[];
}
