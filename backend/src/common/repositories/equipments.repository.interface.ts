import type { Equipment } from '../../entities/index.js';

export const EQUIPMENTS_REPOSITORY = Symbol('EQUIPMENTS_REPOSITORY');

export interface IEquipmentsRepository {
  findAll(): Equipment[];
}
