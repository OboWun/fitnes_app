import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { EXERCISES_REPOSITORY } from '../common/repositories/index.js';
import type {
  IExercisesRepository,
  ExerciseFilterParams,
} from '../common/repositories/index.js';
import { MUSCLES_REPOSITORY } from '../common/repositories/index.js';
import type { IMusclesRepository } from '../common/repositories/index.js';
import { BODYPARTS_REPOSITORY } from '../common/repositories/index.js';
import type { IBodypartsRepository } from '../common/repositories/index.js';
import { EQUIPMENTS_REPOSITORY } from '../common/repositories/index.js';
import type { IEquipmentsRepository } from '../common/repositories/index.js';
import { PaginatedResponseDto } from '../common/dto/index.js';
import type { Exercise } from '../entities/index.js';
import type { ExerciseResponseDto } from './dto/exercise-response.dto.js';
import type { Muscle } from '../entities/index.js';
import type { Bodypart } from '../entities/index.js';
import type { Equipment } from '../entities/index.js';

@Injectable()
export class ExercisesService {
  private musclesCache: Muscle[] | null = null;
  private bodypartsCache: Bodypart[] | null = null;
  private equipmentsCache: Equipment[] | null = null;

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

  async findAll(
    page: number,
    limit: number,
    filters: ExerciseFilterParams,
  ): Promise<PaginatedResponseDto<ExerciseResponseDto>> {
    const result = await this.exercisesRepository.findPaginated(
      page,
      limit,
      filters,
    );
    return new PaginatedResponseDto(
      await Promise.all(result.data.map((e) => this.toResponseDto(e))),
      result.total,
      page,
      limit,
    );
  }

  async findSimilar(
    slug: string,
    page: number,
    limit: number,
  ): Promise<PaginatedResponseDto<ExerciseResponseDto>> {
    const exercise = await this.exercisesRepository.findBySlug(slug);
    if (!exercise) {
      throw new NotFoundException(`Exercise with slug "${slug}" not found`);
    }

    const result = await this.exercisesRepository.findSimilar(
      slug,
      page,
      limit,
    );
    return new PaginatedResponseDto(
      await Promise.all(result.data.map((e) => this.toResponseDto(e))),
      result.total,
      page,
      limit,
    );
  }

  async findAntagonist(
    slug: string,
    page: number,
    limit: number,
  ): Promise<PaginatedResponseDto<ExerciseResponseDto>> {
    const exercise = await this.exercisesRepository.findBySlug(slug);
    if (!exercise) {
      throw new NotFoundException(`Exercise with slug "${slug}" not found`);
    }

    const antagonistSlugs: string[] = [];
    for (const muscleSlug of exercise.targetMuscles) {
      const antagonists =
        await this.musclesRepository.findAntagonists(muscleSlug);
      for (const ant of antagonists) {
        if (!antagonistSlugs.includes(ant.slug)) {
          antagonistSlugs.push(ant.slug);
        }
      }
    }

    const result = await this.exercisesRepository.findAntagonist(
      slug,
      antagonistSlugs,
      page,
      limit,
    );
    return new PaginatedResponseDto(
      await Promise.all(result.data.map((e) => this.toResponseDto(e))),
      result.total,
      page,
      limit,
    );
  }

  private async ensureCache(): Promise<void> {
    if (!this.musclesCache) {
      this.musclesCache = await this.musclesRepository.findAll();
    }
    if (!this.bodypartsCache) {
      this.bodypartsCache = await this.bodypartsRepository.findAll();
    }
    if (!this.equipmentsCache) {
      this.equipmentsCache = await this.equipmentsRepository.findAll();
    }
  }

  private resolveGifUrl(gifUrl: string): string {
    if (gifUrl.startsWith('http')) return gifUrl;
    const base = `${process.env.APP_URL ?? `http://localhost:${process.env.PORT ?? 3000}`}`;
    return `${base}${gifUrl.startsWith('/') ? '' : '/'}${gifUrl}`;
  }

  private async toResponseDto(
    exercise: Exercise,
  ): Promise<ExerciseResponseDto> {
    await this.ensureCache();

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
      gifUrl: this.resolveGifUrl(exercise.gifUrl),
      targetMuscles: exercise.targetMuscles
        .map((slug) => this.musclesCache!.find((m) => m.slug === slug))
        .filter((m): m is NonNullable<typeof m> => m != null),
      bodyParts: exercise.bodyParts
        .map((slug) => this.bodypartsCache!.find((bp) => bp.slug === slug))
        .filter((bp): bp is NonNullable<typeof bp> => bp != null),
      equipments: exercise.equipments
        .map((slug) => this.equipmentsCache!.find((eq) => eq.slug === slug))
        .filter((eq): eq is NonNullable<typeof eq> => eq != null),
      secondaryMuscles: exercise.secondaryMuscles
        ?.map((slug) => this.musclesCache!.find((m) => m.slug === slug))
        .filter((m): m is NonNullable<typeof m> => m != null),
      instructions: exercise.instructions,
      contraindications: exercise.contraindications,
      metadata: exercise.metadata,
    };
  }
}
