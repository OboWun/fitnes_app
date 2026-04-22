import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class BodyPartResponseDto {
  @ApiProperty({ description: 'Название части тела' })
  @IsString()
  name: string;

  @ApiProperty({ description: 'URL Slug для части тела' })
  @IsString()
  slug: string;
}
