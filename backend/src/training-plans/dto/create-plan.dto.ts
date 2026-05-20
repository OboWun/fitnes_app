import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsArray,
  ValidateNested,
  IsIn,
} from 'class-validator';
import { Type } from 'class-transformer';

export class ScheduleItemDto {
  @ApiProperty({ example: 'monday', enum: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'] })
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

export class CreateTrainingPlanDto {
  @ApiProperty({ example: 'My PPL Split' })
  @IsNotEmpty()
  @IsString()
  name!: string;

  @ApiPropertyOptional({ type: [ScheduleItemDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ScheduleItemDto)
  schedule?: ScheduleItemDto[];
}
