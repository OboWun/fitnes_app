import { ApiProperty } from '@nestjs/swagger';

export class ScheduledWorkoutResponseDto {
  @ApiProperty({ example: 'sch1a2b3c', description: 'Schedule entry ID' })
  id: string;

  @ApiProperty({ example: 'l1a2b3c', description: 'Workout template ID' })
  templateId: string;

  @ApiProperty({ example: 'user-id-123', description: 'Owner user ID' })
  userId: string;

  @ApiProperty({
    example: 'monday',
    enum: [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ],
    description: 'Day of the week',
  })
  dayOfWeek: string;

  @ApiProperty({
    example: '09:00',
    description: 'Workout time in HH:mm format',
  })
  time: string;

  @ApiProperty({
    example: '2026-01-01T00:00:00.000Z',
    description: 'Creation date',
  })
  createdAt: string;
}
