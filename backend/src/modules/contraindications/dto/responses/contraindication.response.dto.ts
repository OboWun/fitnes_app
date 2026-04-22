import { IsString, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum ContraindicationSeverity {
  NOT_RECOMMENDED = 'not_recommended',
  LOW_WEIGHT = 'low_weight',
  FORBIDDEN = 'forbidden',
}

export class ContraindicationResponseDto {
  @ApiProperty({ description: 'Название противопоказания' })
  @IsString()
  name: string;

  @ApiProperty({ description: 'URL Slug для противопоказания' })
  @IsString()
  slug: string;
}

export class ContraindicationLinkResponseDto {
  @ApiProperty({ description: 'Slug противопоказания' })
  @IsString()
  slug: string;

  @ApiProperty({ 
    enum: ContraindicationSeverity, 
    description: 'Уровень серьезности противопоказания' 
  })
  @IsEnum(ContraindicationSeverity)
  severity: ContraindicationSeverity;
}
