import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { EquipmentResponseDto } from '../../equipments/dto/equipment-response.dto.js';

export class ExerciseShortResponseDto {
  @ApiProperty({ example: 'barbell-bench-press', description: 'Exercise slug' })
  slug: string;

  @ApiProperty({ example: 'Жим штанги лёжа', description: 'Exercise name' })
  name: string;

  @ApiProperty({
    example: 'https://localhost:3001/media/abc123.gif',
    description: 'GIF image URL',
  })
  imageUrl: string;

  @ApiPropertyOptional({
    example: 'Базовое упражнение для груди',
    description: 'Short description',
  })
  description?: string;

  @ApiProperty({
    type: [EquipmentResponseDto],
    description: 'Required equipment',
  })
  equipments: EquipmentResponseDto[];

  @ApiPropertyOptional({
    example: 'not_recommended',
    enum: ['low_weight', 'not_recommended', 'forbidden'],
    description:
      'Most severe contraindication match for current user. null = safe',
  })
  contraindication?: 'low_weight' | 'not_recommended' | 'forbidden' | null;
}
