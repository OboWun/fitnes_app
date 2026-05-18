import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class EquipmentResponseDto {
  @ApiProperty({ example: 'гантель', description: 'Equipment name' })
  name: string;

  @ApiProperty({
    example: 'dumbbell',
    description: 'Equipment slug identifier',
  })
  slug: string;

  @ApiPropertyOptional({
    example: 'Свободный вес для изолирующих и базовых упражнений',
    description: 'Краткое описание инвентаря',
  })
  description?: string;

  @ApiPropertyOptional({
    example: '/media/equipments/dumbbell.png',
    description: 'Путь к картинке',
  })
  imageUrl?: string;
}
