import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ContraindicationSeverityResponseDto } from './contraindication-severity-response.dto.js';
import { EquipmentResponseDto } from '../../equipments/dto/equipment-response.dto.js';
import { MuscleResponseDto } from '../../muscles/dto/muscle-response.dto.js';
import { BodypartResponseDto } from '../../bodyparts/dto/bodypart-response.dto.js';
import { ExerciseShortResponseDto } from './exercise-short-response.dto.js';
import type { ExerciseMetadata } from '../../entities/index.js';

export class ExerciseDetailResponseDto {
  @ApiProperty({ example: 'barbell-bench-press' })
  slug: string;

  @ApiProperty({ example: 'Жим штанги лёжа' })
  name: string;

  @ApiProperty({
    example: 'https://localhost:3001/media/abc123.gif',
    description: 'GIF image URL',
  })
  imageUrl: string;

  @ApiPropertyOptional({ example: 'Базовое упражнение для развития грудных мышц' })
  description?: string;

  @ApiPropertyOptional({ example: 'strength' })
  exerciseType?: string;

  @ApiPropertyOptional({ example: 'intermediate' })
  difficulty?: string;

  @ApiPropertyOptional({ example: 'push' })
  movementPattern?: string;

  @ApiPropertyOptional({ example: 0.86 })
  confidence?: number;

  @ApiProperty({ type: [String] })
  instructions: string[];

  @ApiProperty({ type: [MuscleResponseDto] })
  targetMuscles: MuscleResponseDto[];

  @ApiPropertyOptional({ type: [MuscleResponseDto] })
  secondaryMuscles?: MuscleResponseDto[];

  @ApiProperty({ type: [BodypartResponseDto] })
  bodyParts: BodypartResponseDto[];

  @ApiProperty({ type: [EquipmentResponseDto] })
  equipments: EquipmentResponseDto[];

  @ApiPropertyOptional({ type: [String] })
  variations?: string[];

  @ApiPropertyOptional({ type: [String] })
  alias?: string[];

  @ApiPropertyOptional({})
  metadata?: ExerciseMetadata;

  @ApiPropertyOptional({
    type: [ContraindicationSeverityResponseDto],
    description: 'User-specific contraindications (intersection)',
  })
  userContraindications?: ContraindicationSeverityResponseDto[];

  @ApiPropertyOptional({
    type: [ExerciseShortResponseDto],
    description: 'Similar exercises (short form)',
  })
  similarExercises?: ExerciseShortResponseDto[];
}
