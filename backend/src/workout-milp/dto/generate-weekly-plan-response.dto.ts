import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class WeeklySessionDto {
  @ApiProperty()
  dayOfWeek!: string;

  @ApiProperty({ type: [Object] })
  exercises!: { exerciseSlug: string; sets: number; order: number }[];

  @ApiProperty()
  loadByMuscle!: Record<string, number>;

  @ApiProperty()
  totalTimeSec!: number;
}

export class GenerateWeeklyPlanResponseDto {
  @ApiProperty()
  blockId!: string;

  @ApiProperty({ type: [WeeklySessionDto] })
  sessions!: WeeklySessionDto[];

  @ApiProperty({ type: [Number] })
  restDays!: number[];

  @ApiProperty()
  totalWeeklyLoad!: number;
}
