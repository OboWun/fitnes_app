import { Injectable } from '@nestjs/common';
import * as path from 'path';
import * as fs from 'fs';
import type { User } from '../entities/index.js';
import type { IUsersRepository } from '../common/repositories/index.js';

@Injectable()
export class UsersJsonRepository implements IUsersRepository {
  private readonly filePath: string;
  private users: User[];

  constructor() {
    this.filePath = path.join(__dirname, '..', '..', 'data', 'users.json');
    if (fs.existsSync(this.filePath)) {
      const raw = fs.readFileSync(this.filePath, 'utf-8');
      this.users = JSON.parse(raw) as User[];
    } else {
      this.users = [];
    }
  }

  private save(): void {
    fs.writeFileSync(
      this.filePath,
      JSON.stringify(this.users, null, 2) + '\n',
      'utf-8',
    );
  }

  findByDeviceId(deviceId: string): User | undefined {
    return this.users.find((u) => u.deviceId === deviceId);
  }

  findById(id: string): User | undefined {
    return this.users.find((u) => u.id === id);
  }

  create(deviceId: string): User {
    const user: User = {
      id: this.generateId(),
      deviceId,
      createdAt: new Date().toISOString(),
    };
    this.users.push(user);
    this.save();
    return user;
  }

  update(
    id: string,
    data: Partial<Omit<User, 'id' | 'deviceId' | 'createdAt'>>,
  ): User | undefined {
    const index = this.users.findIndex((u) => u.id === id);
    if (index === -1) return undefined;
    this.users[index] = { ...this.users[index], ...data };
    this.save();
    return this.users[index];
  }

  private generateId(): string {
    return Date.now().toString(36) + Math.random().toString(36).substring(2, 8);
  }
}
