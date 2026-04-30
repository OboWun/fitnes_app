import type { Contraindication } from '../../entities/index.js';

export const CONTRAINDICATIONS_REPOSITORY = Symbol(
  'CONTRAINDICATIONS_REPOSITORY',
);

export interface IContraindicationsRepository {
  findAll(): Contraindication[];
  findBySlug(slug: string): Contraindication | undefined;
}
