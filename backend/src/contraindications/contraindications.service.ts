import { Inject, Injectable } from '@nestjs/common';
import { CONTRAINDICATIONS_REPOSITORY } from '../common/repositories/index.js';
import type { IContraindicationsRepository } from '../common/repositories/index.js';
import type { Contraindication } from '../entities/index.js';

@Injectable()
export class ContraindicationsService {
  constructor(
    @Inject(CONTRAINDICATIONS_REPOSITORY)
    private readonly repository: IContraindicationsRepository,
  ) {}

  findAll(): Contraindication[] {
    return this.repository.findAll();
  }

  findBySlug(slug: string): Contraindication | undefined {
    return this.repository.findBySlug(slug);
  }

  isValidSlug(slug: string): boolean {
    return this.repository.findBySlug(slug) !== undefined;
  }
}
