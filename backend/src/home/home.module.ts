import { Module } from '@nestjs/common';
import { HomeController } from './home-data.controller.js';
import { HomeDataService } from './home-data.service.js';
import { TrainingPlansSqlRepository } from '../training-plans/training-plans-sql.repository.js';
import { WorkoutSessionsSqlRepository } from '../workout-sessions/workout-sessions-sql.repository.js';
import {
  TRAINING_PLANS_REPOSITORY,
  WORKOUT_SESSIONS_REPOSITORY,
} from '../common/repositories/index.js';

@Module({
  controllers: [HomeController],
  providers: [
    HomeDataService,
    { provide: TRAINING_PLANS_REPOSITORY, useClass: TrainingPlansSqlRepository },
    { provide: WORKOUT_SESSIONS_REPOSITORY, useClass: WorkoutSessionsSqlRepository },
  ],
})
export class HomeModule {}
