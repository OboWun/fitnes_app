import type { User } from '../../entities/index.js';

export const USERS_REPOSITORY = Symbol('USERS_REPOSITORY');

export interface IUsersRepository {
  findByDeviceId(deviceId: string): Promise<User | undefined>;
  findById(id: string): Promise<User | undefined>;
  create(deviceId: string): Promise<User>;
  update(
    id: string,
    data: Partial<Omit<User, 'id' | 'deviceId' | 'createdAt'>>,
  ): Promise<User | undefined>;
}
