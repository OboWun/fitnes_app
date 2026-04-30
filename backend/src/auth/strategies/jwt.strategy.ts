import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import type { User } from '../../entities/index.js';
import { AuthService } from '../auth.service.js';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly authService: AuthService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey:
        process.env.JWT_SECRET ??
        'fitness-app-default-secret-change-in-production',
    });
  }

  validate(payload: { sub: string }): User {
    const user = this.authService.validateUser(payload.sub);
    if (!user) {
      throw new Error('User not found');
    }
    return user;
  }
}
