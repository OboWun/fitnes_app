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

  @ApiPropertyOptional({ type: [String], description: 'Alternative exercise names' })
  alias?: string[];

  @ApiPropertyOptional({
    example: 'strength',
    enum: ['strength', 'hypertrophy', 'endurance', 'mobility', 'stability', 'cardio', 'plyometric', 'rehab', 'stretching'],
    description: 'Exercise type',
  })
  exerciseType?: 'strength' | 'hypertrophy' | 'endurance' | 'mobility' | 'stability' | 'cardio' | 'plyometric' | 'rehab' | 'stretching';

  @ApiPropertyOptional({ example: 'Краткое описание упражнения на русском языке.', description: 'Short Russian description' })
  description?: string;

  @ApiPropertyOptional({ example: 0.86, minimum: 0, maximum: 1, description: 'Confidence score from 0 to 1' })
  confidence?: number;

  @ApiPropertyOptional({
    example: 'intermediate',
    enum: ['beginner', 'intermediate', 'advanced'],
    description: 'Difficulty level',
  })
  difficulty?: 'beginner' | 'intermediate' | 'advanced';

  @ApiPropertyOptional({
    example: 'pull',
    enum: ['push', 'pull', 'squat', 'hinge', 'lunge', 'carry', 'rotate', 'anti_rotate', 'jump', 'crawl', 'press', 'row', 'curl', 'extension', 'flexion', 'abduction', 'adduction', 'rotation', 'stabilization', 'locomotion', 'stretch'],
    description: 'Primary movement pattern',
  })
  movementPattern?: 'push' | 'pull' | 'squat' | 'hinge' | 'lunge' | 'carry' | 'rotate' | 'anti_rotate' | 'jump' | 'crawl' | 'press' | 'row' | 'curl' | 'extension' | 'flexion' | 'abduction' | 'adduction' | 'rotation' | 'stabilization' | 'locomotion' | 'stretch';

  @ApiPropertyOptional({ type: [String], description: 'Variations using existing exercise slugs' })
  variations?: string[];

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
