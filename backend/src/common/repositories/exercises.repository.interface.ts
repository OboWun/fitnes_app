import type { Exercise } from '../../entities/index.js';

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

export interface IExercisesRepository {
  findPaginated(page: number, limit: number, filters?: ExerciseFilterParams): PaginatedResult<Exercise>;
  findBySlug(slug: string): Exercise | undefined;
  findSimilar(slug: string, page: number, limit: number): PaginatedResult<Exercise>;
  findAntagonist(slug: string, antagonistMuscles: string[], page: number, limit: number): PaginatedResult<Exercise>;
}
