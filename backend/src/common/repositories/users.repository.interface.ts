import type { User, WeightLog } from '../../entities/index.js';

export type WeightHistoryPeriod = 'week' | 'month' | 'all';

export const USERS_REPOSITORY = Symbol('USERS_REPOSITORY');

export interface IUsersRepository {
  findByDeviceId(deviceId: string): Promise<User | undefined>;
  findById(id: string): Promise<User | undefined>;
  create(deviceId: string): Promise<User>;
  update(
    id: string,
    data: Partial<Omit<User, 'id' | 'deviceId' | 'createdAt'>>,
  ): Promise<User | undefined>;
  logWeight(userId: string, weight: number): Promise<WeightLog>;
  getWeightHistory(
    userId: string,
    period: WeightHistoryPeriod,
  ): Promise<WeightLog[]>;
}
