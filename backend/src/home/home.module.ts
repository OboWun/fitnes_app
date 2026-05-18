import { Module } from '@nestjs/common';
import { HomeController } from './home-data.controller.js';
import { HomeDataService } from './home-data.service.js';
import { TrainingBlocksSqlRepository } from '../training-blocks/training-blocks-sql.repository.js';
import { WorkoutSessionsSqlRepository } from '../workout-sessions/workout-sessions-sql.repository.js';
import {
  TRAINING_BLOCKS_REPOSITORY,
  WORKOUT_SESSIONS_REPOSITORY,
} from '../common/repositories/index.js';

@Module({
  controllers: [HomeController],
  providers: [
    HomeDataService,
    { provide: TRAINING_BLOCKS_REPOSITORY, useClass: TrainingBlocksSqlRepository },
    { provide: WORKOUT_SESSIONS_REPOSITORY, useClass: WorkoutSessionsSqlRepository },
  ],
})
export class HomeModule {}
