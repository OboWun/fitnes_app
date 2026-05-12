import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsArray, IsOptional, MinLength } from 'class-validator';

export class UpdateEquipmentPresetDto {
  @ApiPropertyOptional({ example: 'Обновлённый зал' })
  @IsOptional()
  @IsString()
  @MinLength(1)
  name?: string;

  @ApiPropertyOptional({ example: 'my-gym-v2' })
  @IsOptional()
  @IsString()
  @MinLength(1)
  slug?: string;

  @ApiPropertyOptional({
    type: [String],
    example: ['barbell', 'dumbbell', 'cable', 'kettlebell'],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  equipmentSlugs?: string[];
}
