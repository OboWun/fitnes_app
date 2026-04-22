import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class EquipmentResponseDto {
  @ApiProperty({ description: 'Название оборудования' })
  @IsString()
  name: string;

  @ApiProperty({ description: 'URL Slug для оборудования' })
  @IsString()
  slug: string;
}
