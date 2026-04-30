import type { User } from '../../entities/index.js';

export const USERS_REPOSITORY = Symbol('USERS_REPOSITORY');

export interface IUsersRepository {
  findByDeviceId(deviceId: string): User | undefined;
  findById(id: string): User | undefined;
  create(deviceId: string): User;
  update(
    id: string,
    data: Partial<Omit<User, 'id' | 'deviceId' | 'createdAt'>>,
  ): User | undefined;
}
