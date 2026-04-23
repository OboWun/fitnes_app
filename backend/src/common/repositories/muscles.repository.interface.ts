import type { Muscle } from '../../entities/index.js';

export const MUSCLES_REPOSITORY = Symbol('MUSCLES_REPOSITORY');

export interface IMusclesRepository {
  findAll(): Muscle[];
  findBySlug(slug: string): Muscle | undefined;
  findAntagonists(slug: string): Muscle[];
}
