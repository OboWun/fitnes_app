import { IsString, IsOptional, IsArray } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class MuscleResponseDto {
  @ApiProperty({ description: 'Название мышцы' })
  @IsString()
  name: string;

  @ApiProperty({ description: 'URL Slug для мышцы' })
  @IsString()
  slug: string;

  @ApiPropertyOptional({ description: 'Мышцы-антагонисты (список slug)', isArray: true })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  antagonists?: string[];
}
