import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

class EquipmentDetailDto {
  @ApiProperty()
  slug!: string;

  @ApiProperty()
  name!: string;
}

export class EquipmentPresetResponseDto {
  @ApiProperty()
  id!: string;

  @ApiPropertyOptional()
  userId?: string;

  @ApiProperty({ example: 'Тренажёрный зал' })
  name!: string;

  @ApiProperty({ example: 'gym-full' })
  slug!: string;

  @ApiProperty()
  isSystem!: boolean;

  @ApiProperty({ type: [String] })
  equipmentSlugs!: string[];

  @ApiPropertyOptional({ type: [EquipmentDetailDto] })
  equipmentDetails?: EquipmentDetailDto[];

  @ApiProperty()
  createdAt!: string;

  @ApiProperty()
  updatedAt!: string;
}
