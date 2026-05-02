import { Inject, Injectable } from '@nestjs/common';
import type { User } from '../entities/index.js';
import { USERS_REPOSITORY, type IUsersRepository } from '../common/repositories/index.js';

@Injectable()
export class UsersService {
  constructor(@Inject(USERS_REPOSITORY) private readonly usersRepository: IUsersRepository) {}

  findById(id: string): User | undefined {
    return this.usersRepository.findById(id);
  }

  findByDeviceId(deviceId: string): User | undefined {
    return this.usersRepository.findByDeviceId(deviceId);
  }

  create(deviceId: string): User {
    return this.usersRepository.create(deviceId);
  }

  update(
    id: string,
    data: Partial<Omit<User, 'id' | 'deviceId' | 'createdAt'>>,
  ): User | undefined {
    return this.usersRepository.update(id, data);
  }
}
