import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNumber,
  IsArray,
  IsOptional,
  IsEnum,
  Min,
  Max,
  IsInt,
} from 'class-validator';

export enum Gender {
  MALE = 'male',
  FEMALE = 'female',
}

export class UpdateProfileDto {
  @ApiPropertyOptional({ example: 'Иван', description: 'User name' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ example: 'male', enum: Gender, description: 'Gender' })
  @IsOptional()
  @IsEnum(Gender)
  gender?: Gender;

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

  @ApiPropertyOptional({
    example: 'hypertrophy',
    description: 'Training goal (stored in user.metadata)',
  })
  @IsOptional()
  @IsString()
  goal?: string;

  @ApiPropertyOptional({
    example: 'intermediate',
    description: 'Experience level (stored in user.metadata)',
  })
  @IsOptional()
  @IsString()
  experienceLevel?: string;

  @ApiPropertyOptional({
    type: [String],
    example: ['barbell', 'dumbbell'],
    description: 'Available equipment slugs (stored in user.metadata)',
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  availableEquipment?: string[];

  @ApiPropertyOptional({
    example: 'preset-gym-full',
    description: 'Default equipment preset ID (stored in user.metadata)',
  })
  @IsOptional()
  @IsString()
  defaultEquipmentPresetId?: string;
}
