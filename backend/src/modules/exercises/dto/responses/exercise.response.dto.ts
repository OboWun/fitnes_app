import { IsString, IsOptional, IsArray, ValidateNested, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export enum ContraindicationSeverity {
  NOT_RECOMMENDED = 'not_recommended',
  LOW_WEIGHT = 'low_weight',
  FORBIDDEN = 'forbidden',
}

export class ContraindicationLinkDto {
  @ApiProperty({ description: 'Slug противопоказания' })
  @IsString()
  slug: string;

  @ApiProperty({ enum: ContraindicationSeverity, description: 'Уровень серьезности' })
  @IsEnum(ContraindicationSeverity)
  severity: ContraindicationSeverity;
}

export class ExerciseResponseDto {
  @ApiProperty({ description: 'Уникальный ID упражнения' })
  @IsString()
  exerciseId: string;

  @ApiProperty({ description: 'Название упражнения' })
  @IsString()
  name: string;

  @ApiProperty({ description: 'URL Slug для упражнения' })
  @IsString()
  slug: string;

  @ApiProperty({ description: 'URL к GIF анимации упражнения' })
  @IsString()
  gifUrl: string;

  @ApiProperty({ description: 'Целевые мышцы', isArray: true })
  @IsArray()
  @IsString({ each: true })
  targetMuscles: string[];

  @ApiProperty({ description: 'Части тела', isArray: true })
  @IsArray()
  @IsString({ each: true })
  bodyParts: string[];

  @ApiProperty({ description: 'Оборудование', isArray: true })
  @IsArray()
  @IsString({ each: true })
  equipments: string[];

  @ApiProperty({ description: 'Вторичные мышцы', isArray: true })
  @IsArray()
  @IsString({ each: true })
  secondaryMuscles: string[];

  @ApiProperty({ description: 'Инструкции по выполнению', isArray: true })
  @IsArray()
  @IsString({ each: true })
  instructions: string[];

  @ApiPropertyOptional({ description: 'Противопоказания', type: [ContraindicationLinkDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ContraindicationLinkDto)
  contraindications?: ContraindicationLinkDto[];
}
