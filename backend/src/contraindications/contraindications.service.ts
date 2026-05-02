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

  findAll(): Promise<Contraindication[]> {
    return this.repository.findAll();
  }

  async findBySlug(slug: string): Promise<Contraindication | undefined> {
    return this.repository.findBySlug(slug);
  }

  async isValidSlug(slug: string): Promise<boolean> {
    const result = await this.repository.findBySlug(slug);
    return result !== undefined;
  }
}
