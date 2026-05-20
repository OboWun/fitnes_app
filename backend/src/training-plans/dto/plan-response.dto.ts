import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ScheduleItemResponseDto {
  @ApiProperty()
  dayOfWeek!: string;

  @ApiProperty()
  workoutTemplateId!: string;

  @ApiPropertyOptional()
  time?: string;

  @ApiPropertyOptional()
  name?: string;

  @ApiProperty()
  sortOrder!: number;
}

export class TrainingPlanResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  userId!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty()
  isActive!: boolean;

  @ApiPropertyOptional()
  source?: string;

  @ApiProperty({ type: [ScheduleItemResponseDto] })
  schedule!: ScheduleItemResponseDto[];

  @ApiProperty()
  createdAt!: string;
}
