import type { Muscle } from '../../entities/index.js';

export const MUSCLES_REPOSITORY = Symbol('MUSCLES_REPOSITORY');

export interface IMusclesRepository {
  findAll(): Promise<Muscle[]>;
  findBySlug(slug: string): Promise<Muscle | undefined>;
  findAntagonists(slug: string): Promise<Muscle[]>;
}
