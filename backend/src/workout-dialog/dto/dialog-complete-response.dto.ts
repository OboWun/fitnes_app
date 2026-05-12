import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class DialogCompleteResponseDto {
  @ApiProperty({ example: 'abc123' })
  dialogId!: string;

  @ApiProperty({ example: 'complete' })
  step!: string;

  @ApiProperty({ example: 'weekly' })
  planType!: string;

  @ApiPropertyOptional({
    example: {
      sessionDurationMin: 60,
      experienceLevel: 'intermediate',
      goal: 'hypertrophy',
      focusMuscles: ['chest', 'back'],
      availableEquipment: ['barbell', 'dumbbell'],
    },
  })
  generateParams?: Record<string, unknown>;

  @ApiPropertyOptional({
    example: {
      availableDays: ['monday', 'wednesday', 'friday'],
      trainingCountPerWeek: 3,
      sessionDurationMin: 60,
      experienceLevel: 'intermediate',
      goal: 'hypertrophy',
      availableEquipment: ['barbell', 'dumbbell'],
    },
  })
  weeklyParams?: Record<string, unknown>;
}
