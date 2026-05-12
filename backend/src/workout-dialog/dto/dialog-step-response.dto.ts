import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class DialogOptionDto {
  @ApiProperty({ example: 'weekly' })
  value!: string;

  @ApiProperty({ example: 'План на неделю' })
  label!: string;
}

export class DialogStepResponseDto {
  @ApiProperty({ example: 'abc123' })
  dialogId!: string;

  @ApiProperty({
    example: 'goal',
    enum: [
      'plan_type',
      'goal',
      'experience',
      'focus_muscles',
      'equipment',
      'frequency',
      'days',
      'duration',
      'complete',
    ],
  })
  step!: string;

  @ApiProperty({ example: 'Какова ваша основная цель?' })
  question!: string;

  @ApiPropertyOptional({ example: 'Выберите одну цель' })
  description?: string;

  @ApiProperty({
    example: 'single_choice',
    enum: ['single_choice', 'multi_choice'],
  })
  inputType!: string;

  @ApiProperty({ type: [DialogOptionDto] })
  options!: DialogOptionDto[];

  @ApiProperty({ example: false })
  canSkip!: boolean;

  @ApiProperty({ example: { planType: 'weekly' } })
  collectedSoFar!: Record<string, unknown>;
}
