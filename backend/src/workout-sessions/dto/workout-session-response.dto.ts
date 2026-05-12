import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import type {
  WorkoutSessionMetadata,
  WorkoutSessionExerciseMetadata,
} from '../../entities/index.js';

export class SessionExerciseResponseDto {
  @ApiProperty()
  exerciseSlug!: string;

  @ApiProperty()
  sets!: number;

  @ApiProperty()
  order!: number;

  @ApiPropertyOptional()
  metadata?: WorkoutSessionExerciseMetadata;
}

export class WorkoutSessionResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  blockId!: string;

  @ApiProperty()
  userId!: string;

  @ApiProperty()
  dayOfWeek!: string;

  @ApiPropertyOptional()
  time?: string;

  @ApiPropertyOptional({
    enum: ['planned', 'completed', 'skipped', 'replaced'],
  })
  status?: string;

  @ApiPropertyOptional({ type: [SessionExerciseResponseDto] })
  exercises?: SessionExerciseResponseDto[];

  @ApiPropertyOptional()
  metadata?: WorkoutSessionMetadata;
}
