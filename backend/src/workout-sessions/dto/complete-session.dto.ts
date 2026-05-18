import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsArray,
  Min,
  Max,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CompleteSetEntryDto {
  @ApiProperty({ example: 'bench-press' })
  @IsNotEmpty()
  @IsString()
  exerciseSlug!: string;

  @ApiProperty({ example: 1 })
  @IsNumber()
  @Min(1)
  setNumber!: number;

  @ApiPropertyOptional({ example: 60 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  actualWeightKg?: number;

  @ApiPropertyOptional({ example: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  actualReps?: number;

  @ApiPropertyOptional({ example: 300 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  actualDurationSec?: number;

  @ApiPropertyOptional({ example: 1000 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  actualDistanceM?: number;

  @ApiPropertyOptional({ example: 7.5 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(10)
  actualRpe?: number;
}

export class CompleteSessionDto {
  @ApiProperty({ type: [CompleteSetEntryDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CompleteSetEntryDto)
  sets!: CompleteSetEntryDto[];
}
