import { Module } from '@nestjs/common';
import { WorkoutSessionsController } from './workout-sessions.controller.js';
import { WorkoutSessionsService } from './workout-sessions.service.js';
import { WorkoutSessionsSqlRepository } from './workout-sessions-sql.repository.js';
import { WORKOUT_SESSIONS_REPOSITORY } from '../common/repositories/index.js';

@Module({
  controllers: [WorkoutSessionsController],
  providers: [
    WorkoutSessionsService,
    {
      provide: WORKOUT_SESSIONS_REPOSITORY,
      useClass: WorkoutSessionsSqlRepository,
    },
  ],
})
export class WorkoutSessionsModule {}
