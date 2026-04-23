import { ApiProperty } from '@nestjs/swagger';

export class EquipmentResponseDto {
  @ApiProperty({ example: 'гантель', description: 'Equipment name' })
  name: string;

  @ApiProperty({ example: 'dumbbell', description: 'Equipment slug identifier' })
  slug: string;
}
