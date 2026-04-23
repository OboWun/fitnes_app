import { Inject, Injectable } from '@nestjs/common';
import { MUSCLES_REPOSITORY } from '../common/repositories/index.js';
import type { IMusclesRepository } from '../common/repositories/index.js';
import type { Muscle } from '../entities/index.js';

@Injectable()
export class MusclesService {
  constructor(
    @Inject(MUSCLES_REPOSITORY)
    private readonly musclesRepository: IMusclesRepository,
  ) {}

  findAll(): Muscle[] {
    return this.musclesRepository.findAll();
  }

  findAntagonists(slug: string): Muscle[] {
    return this.musclesRepository.findAntagonists(slug);
  }
}
