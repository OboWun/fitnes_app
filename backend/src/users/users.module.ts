import { Module } from '@nestjs/common';
import { UsersController } from './users.controller.js';
import { UsersService } from './users.service.js';
import { UsersJsonRepository } from './users-json.repository.js';
import { USERS_REPOSITORY } from '../common/repositories/index.js';

@Module({
  controllers: [UsersController],
  providers: [
    UsersService,
    {
      provide: USERS_REPOSITORY,
      useClass: UsersJsonRepository,
    },
  ],
  exports: [UsersService],
})
export class UsersModule {}
