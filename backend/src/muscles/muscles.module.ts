import { Module } from '@nestjs/common';
import { MusclesController } from './muscles.controller.js';
import { MusclesService } from './muscles.service.js';
import { MusclesJsonRepository } from './muscles-json.repository.js';
import { MUSCLES_REPOSITORY } from '../common/repositories/index.js';

@Module({
  controllers: [MusclesController],
  providers: [
    MusclesService,
    {
      provide: MUSCLES_REPOSITORY,
      useClass: MusclesJsonRepository,
    },
  ],
  exports: [MUSCLES_REPOSITORY],
})
export class MusclesModule {}
