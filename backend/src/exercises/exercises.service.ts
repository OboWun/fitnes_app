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
import type { Exercise, User } from '../entities/index.js';
import type { ExerciseShortResponseDto } from './dto/exercise-short-response.dto.js';
import type { ExerciseDetailResponseDto } from './dto/exercise-detail-response.dto.js';
import type { Muscle } from '../entities/index.js';
import type { Bodypart } from '../entities/index.js';
import type { Equipment } from '../entities/index.js';

type ContraindicationLevel =
  | 'forbidden'
  | 'not_recommended'
  | 'low_weight';

const SEVERITY_ORDER: Record<ContraindicationLevel, number> = {
  low_weight: 1,
  not_recommended: 2,
  forbidden: 3,
};

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
    user?: User,
    isPersonal?: boolean,
  ): Promise<PaginatedResponseDto<ExerciseShortResponseDto>> {
    const userContra = isPersonal
      ? (user?.contraindications ?? [])
      : [];

    const result = await this.exercisesRepository.findPaginated(
      page,
      limit,
      filters,
    );

    let exercises = await Promise.all(
      result.data.map((e) => this.toShortDto(e, userContra)),
    );

    if (isPersonal && userContra.length > 0) {
      exercises = this.sortByAccessibility(exercises);
    }

    return new PaginatedResponseDto(exercises, result.total, page, limit);
  }

  async findOne(slug: string, user?: User): Promise<ExerciseDetailResponseDto> {
    const exercise = await this.exercisesRepository.findBySlug(slug);
    if (!exercise) {
      throw new NotFoundException(`Exercise with slug "${slug}" not found`);
    }

    await this.ensureCache();

    const userContraSlugs = new Set(user?.contraindications ?? []);

    const userContraindications =
      exercise.contraindications?.filter((c) => userContraSlugs.has(c.slug)) ??
      [];

    const similarResult = await this.exercisesRepository.findSimilar(slug, 1, 5);
    const userContra = user?.contraindications ?? [];
    const similarExercises = await Promise.all(
      similarResult.data.map((e) => this.toShortDto(e, userContra)),
    );

    return {
      slug: exercise.slug,
      name: exercise.name,
      imageUrl: this.resolveGifUrl(exercise.gifUrl),
      description: exercise.description,
      exerciseType: exercise.exerciseType,
      difficulty: exercise.difficulty,
      movementPattern: exercise.movementPattern,
      confidence: exercise.confidence,
      instructions: exercise.instructions,
      targetMuscles: this.resolveMuscles(exercise.targetMuscles),
      secondaryMuscles: exercise.secondaryMuscles
        ? this.resolveMuscles(exercise.secondaryMuscles)
        : undefined,
      bodyParts: this.resolveBodyparts(exercise.bodyParts),
      equipments: this.resolveEquipments(exercise.equipments),
      variations: exercise.variations,
      alias: exercise.alias,
      metadata: exercise.metadata,
      userContraindications:
        userContraindications.length > 0 ? userContraindications : undefined,
      similarExercises,
    };
  }

  async findSimilar(
    slug: string,
    page: number,
    limit: number,
    user?: User,
  ): Promise<PaginatedResponseDto<ExerciseShortResponseDto>> {
    const exercise = await this.exercisesRepository.findBySlug(slug);
    if (!exercise) {
      throw new NotFoundException(`Exercise with slug "${slug}" not found`);
    }

    const result = await this.exercisesRepository.findSimilar(
      slug,
      page,
      limit,
    );
    const userContra = user?.contraindications ?? [];
    return new PaginatedResponseDto(
      await Promise.all(result.data.map((e) => this.toShortDto(e, userContra))),
      result.total,
      page,
      limit,
    );
  }

  async findAntagonist(
    slug: string,
    page: number,
    limit: number,
    user?: User,
  ): Promise<PaginatedResponseDto<ExerciseShortResponseDto>> {
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
    const userContra = user?.contraindications ?? [];
    return new PaginatedResponseDto(
      await Promise.all(result.data.map((e) => this.toShortDto(e, userContra))),
      result.total,
      page,
      limit,
    );
  }

  private computeAccessibility(
    exercise: Exercise,
    userContraindications: string[],
  ): ContraindicationLevel | null {
    if (!userContraindications.length || !exercise.contraindications?.length) {
      return null;
    }
    const userSet = new Set(userContraindications);
    let worst: ContraindicationLevel | null = null;
    let worstScore = 0;
    for (const c of exercise.contraindications) {
      if (userSet.has(c.slug)) {
        const score = SEVERITY_ORDER[c.severity] ?? 0;
        if (score > worstScore) {
          worstScore = score;
          worst = c.severity;
        }
      }
    }
    return worst;
  }

  private sortByAccessibility(
    exercises: ExerciseShortResponseDto[],
  ): ExerciseShortResponseDto[] {
    return exercises.sort((a, b) => {
      const aScore = a.contraindication
        ? SEVERITY_ORDER[a.contraindication] ?? 0
        : 0;
      const bScore = b.contraindication
        ? SEVERITY_ORDER[b.contraindication] ?? 0
        : 0;
      return aScore - bScore;
    });
  }

  private async toShortDto(
    exercise: Exercise,
    userContraindications: string[],
  ): Promise<ExerciseShortResponseDto> {
    await this.ensureCache();
    return {
      slug: exercise.slug,
      name: exercise.name,
      imageUrl: this.resolveGifUrl(exercise.gifUrl),
      description: exercise.description,
      equipments: this.resolveEquipments(exercise.equipments),
      contraindication:
        userContraindications.length > 0
          ? this.computeAccessibility(exercise, userContraindications)
          : null,
    };
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

  private resolveMuscles(slugs: string[]) {
    return slugs
      .map((slug) => this.musclesCache!.find((m) => m.slug === slug))
      .filter((m): m is NonNullable<typeof m> => m != null);
  }

  private resolveBodyparts(slugs: string[]) {
    return slugs
      .map((slug) => this.bodypartsCache!.find((bp) => bp.slug === slug))
      .filter((bp): bp is NonNullable<typeof bp> => bp != null);
  }

  private resolveEquipments(slugs: string[]) {
    return slugs
      .map((slug) => this.equipmentsCache!.find((eq) => eq.slug === slug))
      .filter((eq): eq is NonNullable<typeof eq> => eq != null);
  }
}
