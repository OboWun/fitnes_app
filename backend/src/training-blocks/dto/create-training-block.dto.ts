import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsNumber,
  IsArray,
  Min,
  Max,
  IsIn,
} from 'class-validator';

export class TrainingBlockMetadataDto {
  @ApiPropertyOptional({ example: 'accumulation' })
  @IsOptional()
  @IsString()
  phase?: string;

  @ApiPropertyOptional({ example: 'base' })
  @IsOptional()
  @IsString()
  weekType?: string;

  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @IsNumber()
  minRestDays?: number;

  @ApiPropertyOptional({ example: 3 })
  @IsOptional()
  @IsNumber()
  maxRestDays?: number;

  @ApiPropertyOptional({ example: 500 })
  @IsOptional()
  @IsNumber()
  weeklyLoadLimit?: number;

  @ApiPropertyOptional({ example: 2 })
  @IsOptional()
  @IsNumber()
  consecutiveTrainingDaysLimit?: number;
}

export class CreateTrainingBlockDto {
  @ApiProperty({ example: 'Week 1 Base' })
  @IsNotEmpty()
  @IsString()
  name!: string;

  @ApiProperty({
    example: 'base',
    enum: ['base', 'build', 'taper', 'recovery'],
  })
  @IsNotEmpty()
  @IsString()
  @IsIn(['base', 'build', 'taper', 'recovery'])
  type!: 'base' | 'build' | 'taper' | 'recovery';

  @ApiProperty({ example: 0 })
  @IsNumber()
  @Min(0)
  index!: number;

  @ApiProperty({ example: 4 })
  @IsNumber()
  @Min(1)
  @Max(52)
  durationWeeks!: number;

  @ApiPropertyOptional({ example: 'strength' })
  @IsOptional()
  @IsString()
  goal?: string;

  @ApiPropertyOptional({ example: ['chest', 'back'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  targetMuscles?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  metadata?: TrainingBlockMetadataDto;
}
