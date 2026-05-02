import type { Contraindication } from '../../entities/index.js';

export const CONTRAINDICATIONS_REPOSITORY = Symbol(
  'CONTRAINDICATIONS_REPOSITORY',
);

export interface IContraindicationsRepository {
  findAll(): Promise<Contraindication[]>;
  findBySlug(slug: string): Promise<Contraindication | undefined>;
}
