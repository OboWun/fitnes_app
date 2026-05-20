import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsIn,
} from 'class-validator';

export class AssignTemplateDto {
  @ApiProperty({ example: 'monday' })
  @IsNotEmpty()
  @IsString()
  @IsIn(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'])
  dayOfWeek!: string;

  @ApiProperty({ example: 'tpl-push-day' })
  @IsNotEmpty()
  @IsString()
  workoutTemplateId!: string;

  @ApiPropertyOptional({ example: '18:00' })
  @IsOptional()
  @IsString()
  time?: string;

  @ApiPropertyOptional({ example: 'Push Day' })
  @IsOptional()
  @IsString()
  name?: string;
}

export class UnassignTemplateDto {
  @ApiProperty({ example: 'monday' })
  @IsNotEmpty()
  @IsString()
  @IsIn(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'])
  dayOfWeek!: string;
}
