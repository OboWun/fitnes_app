import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { EXERCISES_REPOSITORY } from '../common/repositories/index.js';
import type { IExercisesRepository, ExerciseFilterParams, PaginatedResult } from '../common/repositories/index.js';
import { MUSCLES_REPOSITORY } from '../common/repositories/index.js';
import type { IMusclesRepository } from '../common/repositories/index.js';
import { BODYPARTS_REPOSITORY } from '../common/repositories/index.js';
import type { IBodypartsRepository } from '../common/repositories/index.js';
import { EQUIPMENTS_REPOSITORY } from '../common/repositories/index.js';
import type { IEquipmentsRepository } from '../common/repositories/index.js';
import { PaginatedResponseDto } from '../common/dto/index.js';
import type { Exercise } from '../entities/index.js';
import type { ExerciseResponseDto } from './dto/exercise-response.dto.js';

@Injectable()
export class ExercisesService {
  constructor(
    @Inject(EXERCISES_REPOSITORY)
    private readonly exercisesRepository: IExercisesRepository,
    @Inject(MUSCLES_REPOSITORY)
    private readonly musclesRepository: IMusclesRepository,
    @Inject(BODYPARTS_REPOSITORY)
    private readonly bodypartsRepository: IBodypartsRepository,
    @Inject(EQUIPMENTS_REPOSITORY)
    private readonly equipmentsRepository: IEquipmentsRepository,
  ) {}

  findAll(
    page: number,
    limit: number,
    filters: ExerciseFilterParams,
  ): PaginatedResponseDto<ExerciseResponseDto> {
    const result = this.exercisesRepository.findPaginated(page, limit, filters);
    return new PaginatedResponseDto(
      result.data.map((e) => this.toResponseDto(e)),
      result.total,
      page,
      limit,
    );
  }

  findSimilar(
    slug: string,
    page: number,
    limit: number,
  ): PaginatedResponseDto<ExerciseResponseDto> {
    const exercise = this.exercisesRepository.findBySlug(slug);
    if (!exercise) {
      throw new NotFoundException(`Exercise with slug "${slug}" not found`);
    }

    const result = this.exercisesRepository.findSimilar(slug, page, limit);
    return new PaginatedResponseDto(
      result.data.map((e) => this.toResponseDto(e)),
      result.total,
      page,
      limit,
    );
  }

  findAntagonist(
    slug: string,
    page: number,
    limit: number,
  ): PaginatedResponseDto<ExerciseResponseDto> {
    const exercise = this.exercisesRepository.findBySlug(slug);
    if (!exercise) {
      throw new NotFoundException(`Exercise with slug "${slug}" not found`);
    }

    const antagonistSlugs: string[] = [];
    for (const muscleSlug of exercise.targetMuscles) {
      const antagonists = this.musclesRepository.findAntagonists(muscleSlug);
      for (const ant of antagonists) {
        if (!antagonistSlugs.includes(ant.slug)) {
          antagonistSlugs.push(ant.slug);
        }
      }
    }

    const result = this.exercisesRepository.findAntagonist(slug, antagonistSlugs, page, limit);
    return new PaginatedResponseDto(
      result.data.map((e) => this.toResponseDto(e)),
      result.total,
      page,
      limit,
    );
  }

  private toResponseDto(exercise: Exercise): ExerciseResponseDto {
    const allMuscles = this.musclesRepository.findAll();
    const allBodyparts = this.bodypartsRepository.findAll();
    const allEquipments = this.equipmentsRepository.findAll();

    return {
      exerciseId: exercise.exerciseId,
      name: exercise.name,
      alias: exercise.alias,
      exerciseType: exercise.exerciseType,
      description: exercise.description,
      confidence: exercise.confidence,
      difficulty: exercise.difficulty,
      movementPattern: exercise.movementPattern,
      variations: exercise.variations,
      slug: exercise.slug,
      gifUrl: exercise.gifUrl,
      targetMuscles: exercise.targetMuscles
        .map((slug) => allMuscles.find((m) => m.slug === slug))
        .filter((m): m is NonNullable<typeof m> => m != null),
      bodyParts: exercise.bodyParts
        .map((slug) => allBodyparts.find((bp) => bp.slug === slug))
        .filter((bp): bp is NonNullable<typeof bp> => bp != null),
      equipments: exercise.equipments
        .map((slug) => allEquipments.find((eq) => eq.slug === slug))
        .filter((eq): eq is NonNullable<typeof eq> => eq != null),
      secondaryMuscles: exercise.secondaryMuscles
        ?.map((slug) => allMuscles.find((m) => m.slug === slug))
        .filter((m): m is NonNullable<typeof m> => m != null),
      instructions: exercise.instructions,
      contraindications: exercise.contraindications,
    };
  }
}
