import { Module } from '@nestjs/common';
import { BodypartsController } from './bodyparts.controller.js';
import { BodypartsService } from './bodyparts.service.js';
import { BodypartsJsonRepository } from './bodyparts-json.repository.js';
import { BODYPARTS_REPOSITORY } from '../common/repositories/index.js';

@Module({
  controllers: [BodypartsController],
  providers: [
    BodypartsService,
    {
      provide: BODYPARTS_REPOSITORY,
      useClass: BodypartsJsonRepository,
    },
  ],
  exports: [BODYPARTS_REPOSITORY],
})
export class BodypartsModule {}
