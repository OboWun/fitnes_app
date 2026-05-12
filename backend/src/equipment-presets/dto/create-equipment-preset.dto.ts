import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsArray, MinLength } from 'class-validator';

export class CreateEquipmentPresetDto {
  @ApiProperty({ example: 'Мой зал' })
  @IsString()
  @MinLength(1)
  name!: string;

  @ApiProperty({ example: 'my-gym' })
  @IsString()
  @MinLength(1)
  slug!: string;

  @ApiProperty({ type: [String], example: ['barbell', 'dumbbell', 'cable'] })
  @IsArray()
  @IsString({ each: true })
  equipmentSlugs!: string[];
}
