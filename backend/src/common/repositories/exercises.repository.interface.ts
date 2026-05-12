import type { Exercise, ExerciseMetadata } from '../../entities/index.js';

export const EXERCISES_REPOSITORY = Symbol('EXERCISES_REPOSITORY');

export interface ExerciseFilterParams {
  contraindications?: string[];
  equipments?: string[];
  targetMuscles?: string[];
  search?: string;
}

export interface PaginatedResult<T> {
  data: T[];
  total: number;
}

export interface ExerciseMILPData {
  slug: string;
  exerciseType: string | null;
  movementPattern: string | null;
  equipments: string[];
  contraindications: { slug: string; severity: string }[];
  metadata: ExerciseMetadata | null;
}

export interface IExercisesRepository {
  findPaginated(
    page: number,
    limit: number,
    filters?: ExerciseFilterParams,
  ): Promise<PaginatedResult<Exercise>>;
  findBySlug(slug: string): Promise<Exercise | undefined>;
  findSimilar(
    slug: string,
    page: number,
    limit: number,
  ): Promise<PaginatedResult<Exercise>>;
  findAntagonist(
    slug: string,
    antagonistMuscles: string[],
    page: number,
    limit: number,
  ): Promise<PaginatedResult<Exercise>>;
  findForMILP(
    page: number,
    limit: number,
  ): Promise<PaginatedResult<ExerciseMILPData>>;
}
