import { ApiProperty } from '@nestjs/swagger';

export class WeightLogResponseDto {
  @ApiProperty({ example: '2026-05-17', description: 'Дата записи' })
  date: string;

  @ApiProperty({ example: 75.0, description: 'Вес в кг' })
  weight: number;
}
