import type { Bodypart } from '../../entities/index.js';

export const BODYPARTS_REPOSITORY = Symbol('BODYPARTS_REPOSITORY');

export interface IBodypartsRepository {
  findAll(): Bodypart[];
}
