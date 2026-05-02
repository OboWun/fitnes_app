import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsIn, IsOptional } from 'class-validator';
import type { DayOfWeek } from '../../entities/index.js';

const DAYS_OF_WEEK: DayOfWeek[] = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

export class ScheduleWorkoutDto {
  @ApiProperty({
    example: 'l1a2b3c',
    description: 'Workout template ID',
  })
  @IsString()
  templateId: string;

  @ApiProperty({
    example: 'monday',
    enum: DAYS_OF_WEEK,
    description: 'Day of the week',
  })
  @IsString()
  @IsIn(DAYS_OF_WEEK)
  dayOfWeek: DayOfWeek;

  @ApiProperty({
    example: '09:00',
    description: 'Workout time in HH:mm format',
  })
  @IsString()
  time: string;
}

export class UpdateScheduledWorkoutDto {
  @ApiPropertyOptional({
    example: 'l1a2b3c',
    description: 'Workout template ID',
  })
  @IsOptional()
  @IsString()
  templateId?: string;

  @ApiPropertyOptional({
    example: 'tuesday',
    enum: DAYS_OF_WEEK,
    description: 'Day of the week',
  })
  @IsOptional()
  @IsString()
  @IsIn(DAYS_OF_WEEK)
  dayOfWeek?: DayOfWeek;

  @ApiPropertyOptional({
    example: '10:00',
    description: 'Workout time in HH:mm format',
  })
  @IsOptional()
  @IsString()
  time?: string;
}
