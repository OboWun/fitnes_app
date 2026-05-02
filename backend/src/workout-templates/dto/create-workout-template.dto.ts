import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsArray,
  IsOptional,
  IsInt,
  Min,
  Max,
  ValidateNested,
  ArrayMinSize,
} from 'class-validator';
import { Type } from 'class-transformer';

export class WorkoutExerciseDto {
  @ApiProperty({
    example: 'band-shrug',
    description: 'Exercise slug',
  })
  @IsString()
  exerciseSlug: string;

  @ApiProperty({ example: 3, description: 'Number of sets', minimum: 1 })
  @IsInt()
  @Min(1)
  @Max(50)
  sets: number;

  @ApiPropertyOptional({ example: 12, description: 'Number of reps per set' })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(200)
  reps?: number;

  @ApiPropertyOptional({
    example: 90,
    description: 'Rest between sets in seconds',
  })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(600)
  restBetweenSets?: number;

  @ApiPropertyOptional({
    example: 120,
    description: 'Rest after this exercise in seconds',
  })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(600)
  restAfterExercise?: number;

  @ApiProperty({ example: 1, description: 'Order in workout', minimum: 1 })
  @IsInt()
  @Min(1)
  order: number;
}

export class CreateWorkoutTemplateDto {
  @ApiProperty({ example: 'Push Day', description: 'Template name' })
  @IsString()
  name: string;

  @ApiPropertyOptional({
    example: 'Chest, shoulders and triceps workout',
    description: 'Template description',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({
    type: [WorkoutExerciseDto],
    description: 'Exercises in the template',
  })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => WorkoutExerciseDto)
  exercises: WorkoutExerciseDto[];
}
