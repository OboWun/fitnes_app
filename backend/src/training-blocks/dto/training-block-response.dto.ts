import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import type { TrainingBlockMetadata } from '../../entities/index.js';

export class TrainingBlockResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  userId!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty({ enum: ['base', 'build', 'taper', 'recovery'] })
  type!: string;

  @ApiProperty()
  index!: number;

  @ApiProperty()
  durationWeeks!: number;

  @ApiPropertyOptional()
  goal?: string;

  @ApiPropertyOptional({ type: [String] })
  targetMuscles?: string[];

  @ApiPropertyOptional()
  metadata?: TrainingBlockMetadata;
}
