import { Module } from '@nestjs/common';
import { MusclesController } from './muscles.controller.js';
import { MusclesService } from './muscles.service.js';
import { MusclesSqlRepository } from './muscles-sql.repository.js';
import { MUSCLES_REPOSITORY } from '../common/repositories/index.js';

@Module({
  controllers: [MusclesController],
  providers: [
    MusclesService,
    {
      provide: MUSCLES_REPOSITORY,
      useClass: MusclesSqlRepository,
    },
  ],
  exports: [MUSCLES_REPOSITORY],
})
export class MusclesModule {}
