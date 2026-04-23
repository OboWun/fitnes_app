import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ContraindicationSeverityResponseDto } from './contraindication-severity-response.dto.js';
import { EquipmentResponseDto } from '../../equipments/dto/equipment-response.dto.js';
import { MuscleResponseDto } from '../../muscles/dto/muscle-response.dto.js';
import { BodypartResponseDto } from '../../bodyparts/dto/bodypart-response.dto.js';

export class ExerciseResponseDto {
  @ApiProperty({ example: 'trmte8s', description: 'Unique exercise identifier' })
  exerciseId: string;

  @ApiProperty({ example: 'С Эспандером Шраги', description: 'Exercise name' })
  name: string;

  @ApiProperty({ example: 'band-shrug', description: 'Exercise slug' })
  slug: string;

  @ApiProperty({ example: 'https://static.exercisedb.dev/media/trmte8s.gif', description: 'GIF URL' })
  gifUrl: string;

  @ApiProperty({ type: [MuscleResponseDto], description: 'Target muscles' })
  targetMuscles: MuscleResponseDto[];

  @ApiProperty({ type: [BodypartResponseDto], description: 'Body parts' })
  bodyParts: BodypartResponseDto[];

  @ApiProperty({ type: [EquipmentResponseDto], description: 'Equipments' })
  equipments: EquipmentResponseDto[];

  @ApiPropertyOptional({ type: [MuscleResponseDto], description: 'Secondary muscles' })
  secondaryMuscles?: MuscleResponseDto[];

  @ApiProperty({ type: [String], description: 'Exercise instructions' })
  instructions: string[];

  @ApiPropertyOptional({ type: [ContraindicationSeverityResponseDto], description: 'Contraindications' })
  contraindications?: ContraindicationSeverityResponseDto[];
}
