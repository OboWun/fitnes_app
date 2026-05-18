import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { WorkoutSessionsController } from './workout-sessions.controller.js';
import { WorkoutSessionsService } from './workout-sessions.service.js';
import { WorkoutSessionsSqlRepository } from './workout-sessions-sql.repository.js';
import { SetPlannerService } from './set-planner.service.js';
import { AutoSkipCron } from './cron/auto-skip.cron.js';
import {
  WORKOUT_SESSIONS_REPOSITORY,
  EXERCISES_REPOSITORY,
  USERS_REPOSITORY,
} from '../common/repositories/index.js';
import { ExercisesSqlRepository } from '../exercises/exercises-sql.repository.js';
import { UsersSqlRepository } from '../users/users-sql.repository.js';

@Module({
  imports: [ScheduleModule.forRoot()],
  controllers: [WorkoutSessionsController],
  providers: [
    WorkoutSessionsService,
    SetPlannerService,
    AutoSkipCron,
    {
      provide: WORKOUT_SESSIONS_REPOSITORY,
      useClass: WorkoutSessionsSqlRepository,
    },
    {
      provide: EXERCISES_REPOSITORY,
      useClass: ExercisesSqlRepository,
    },
    {
      provide: USERS_REPOSITORY,
      useClass: UsersSqlRepository,
    },
  ],
})
export class WorkoutSessionsModule {}
