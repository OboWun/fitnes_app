import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, MinLength } from 'class-validator';

export class CloneEquipmentPresetDto {
  @ApiProperty({ example: 'Мой зал (кастом)' })
  @IsString()
  @MinLength(1)
  name!: string;

  @ApiPropertyOptional({ example: 'my-gym-custom' })
  @IsOptional()
  @IsString()
  @MinLength(1)
  slug?: string;
}
