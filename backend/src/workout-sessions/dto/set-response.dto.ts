import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SetResponseDto {
  @ApiProperty()
  setNumber!: number;

  @ApiProperty({ enum: ['warmup', 'working', 'dropset'] })
  setType!: string;

  @ApiPropertyOptional()
  plannedWeightKg?: number;

  @ApiPropertyOptional()
  plannedReps?: number;

  @ApiPropertyOptional()
  plannedDurationSec?: number;

  @ApiPropertyOptional()
  plannedDistanceM?: number;

  @ApiPropertyOptional()
  actualWeightKg?: number;

  @ApiPropertyOptional()
  actualReps?: number;

  @ApiPropertyOptional()
  actualDurationSec?: number;

  @ApiPropertyOptional()
  actualDistanceM?: number;

  @ApiPropertyOptional()
  actualRpe?: number;

  @ApiPropertyOptional()
  completedAt?: Date;
}
