import { Inject, Injectable } from '@nestjs/common';
import { EQUIPMENTS_REPOSITORY } from '../common/repositories/index.js';
import type { IEquipmentsRepository } from '../common/repositories/index.js';
import type { Equipment } from '../entities/index.js';

@Injectable()
export class EquipmentsService {
  constructor(
    @Inject(EQUIPMENTS_REPOSITORY)
    private readonly equipmentsRepository: IEquipmentsRepository,
  ) {}

  findAll(): Equipment[] {
    return this.equipmentsRepository.findAll();
  }
}
