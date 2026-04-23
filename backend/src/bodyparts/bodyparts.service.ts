import { Inject, Injectable } from '@nestjs/common';
import { BODYPARTS_REPOSITORY } from '../common/repositories/index.js';
import type { IBodypartsRepository } from '../common/repositories/index.js';
import type { Bodypart } from '../entities/index.js';

@Injectable()
export class BodypartsService {
  constructor(
    @Inject(BODYPARTS_REPOSITORY)
    private readonly bodypartsRepository: IBodypartsRepository,
  ) {}

  findAll(): Bodypart[] {
    return this.bodypartsRepository.findAll();
  }
}
