import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import type {
  WorkoutSessionMetadata,
  WorkoutSessionExerciseMetadata,
} from '../../entities/index.js';
import { SetResponseDto } from './set-response.dto.js';

export class SessionExerciseResponseDto {
  @ApiProperty()
  exerciseSlug!: string;

  @ApiProperty()
  sets!: number;

  @ApiProperty()
  order!: number;

  @ApiPropertyOptional()
  metadata?: WorkoutSessionExerciseMetadata;

  @ApiPropertyOptional({ type: [SetResponseDto] })
  setDetails?: SetResponseDto[];
}

export class WorkoutSessionResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  planSessionId!: string;

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
