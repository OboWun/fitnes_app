import { Module } from '@nestjs/common';
import { TrainingBlocksController } from './training-blocks.controller.js';
import { TrainingBlocksService } from './training-blocks.service.js';
import { TrainingBlocksSqlRepository } from './training-blocks-sql.repository.js';
import { TRAINING_BLOCKS_REPOSITORY } from '../common/repositories/index.js';

@Module({
  controllers: [TrainingBlocksController],
  providers: [
    TrainingBlocksService,
    {
      provide: TRAINING_BLOCKS_REPOSITORY,
      useClass: TrainingBlocksSqlRepository,
    },
  ],
})
export class TrainingBlocksModule {}
