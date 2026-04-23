import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class MuscleResponseDto {
  @ApiProperty({ example: 'бицепсы', description: 'Muscle name' })
  name: string;

  @ApiProperty({ example: 'biceps', description: 'Muscle slug identifier' })
  slug: string;

  @ApiPropertyOptional({ type: [String], example: ['triceps'], description: 'Antagonist muscle slugs' })
  antagonists?: string[];
}
