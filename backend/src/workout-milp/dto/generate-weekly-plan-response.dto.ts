import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { GeneratedExerciseDto } from './generate-workout-response.dto.js';

export class WeeklySessionDto {
  @ApiProperty()
  dayOfWeek!: string;

  @ApiProperty({
    enum: ['full_body', 'upper', 'lower', 'push', 'pull', 'legs'],
  })
  sessionType!: string;

  @ApiProperty({ type: [GeneratedExerciseDto] })
  exercises!: GeneratedExerciseDto[];

  @ApiProperty()
  loadByMuscle!: Record<string, number>;

  @ApiProperty()
  totalTimeSec!: number;

  @ApiProperty({ example: 10 })
  repsPerSet!: number;
}

export class GenerateWeeklyPlanResponseDto {
  @ApiProperty()
  blockId!: string;

  @ApiProperty({ example: 'ppl' })
  splitName!: string;

  @ApiProperty({ type: [WeeklySessionDto] })
  sessions!: WeeklySessionDto[];

  @ApiProperty()
  totalWeeklyLoad!: number;

  @ApiProperty({ example: { chest: 12, back: 14, quads: 10 } })
  weeklyVolumeByMuscle!: Record<string, number>;

  @ApiPropertyOptional({ example: false })
  usedFallback?: boolean;
}
