import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service.js';
import type { User } from '../entities/index.js';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async authenticate(
    deviceId: string,
  ): Promise<{ accessToken: string; user: User }> {
    let user = await this.usersService.findByDeviceId(deviceId);
    if (!user) {
      user = await this.usersService.create(deviceId);
    }

    const payload = { sub: user.id, deviceId: user.deviceId };
    const accessToken = this.jwtService.sign(payload);

    return { accessToken, user };
  }

  async validateUser(id: string): Promise<User | undefined> {
    return this.usersService.findById(id);
  }
}
