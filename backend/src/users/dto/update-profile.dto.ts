import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNumber,
  IsArray,
  IsOptional,
  Min,
  Max,
  IsInt,
} from 'class-validator';

export class UpdateProfileDto {
  @ApiPropertyOptional({ example: 'Иван', description: 'User name' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ example: 75, description: 'Weight in kg' })
  @IsOptional()
  @IsNumber()
  @Min(20)
  @Max(300)
  weight?: number;

  @ApiPropertyOptional({ example: 180, description: 'Height in cm' })
  @IsOptional()
  @IsNumber()
  @Min(50)
  @Max(300)
  height?: number;

  @ApiPropertyOptional({ example: 30, description: 'Age in years' })
  @IsOptional()
  @IsInt()
  @Min(10)
  @Max(120)
  age?: number;

  @ApiPropertyOptional({
    type: [String],
    example: ['herniated_disc', 'hypertension'],
    description: 'Contraindication slugs',
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  contraindications?: string[];
}
