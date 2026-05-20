import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { TrainingPlansController } from './training-plans.controller.js';
import { TrainingPlansService } from './training-plans.service.js';
import { TrainingPlansSqlRepository } from './training-plans-sql.repository.js';
import { SetPlannerService } from '../workout-sessions/set-planner.service.js';
import {
  TRAINING_PLANS_REPOSITORY,
  EXERCISES_REPOSITORY,
  USERS_REPOSITORY,
  WORKOUT_SESSIONS_REPOSITORY,
  WORKOUT_TEMPLATES_REPOSITORY,
} from '../common/repositories/index.js';
import { ExercisesSqlRepository } from '../exercises/exercises-sql.repository.js';
import { UsersSqlRepository } from '../users/users-sql.repository.js';
import { WorkoutSessionsSqlRepository } from '../workout-sessions/workout-sessions-sql.repository.js';
import { WorkoutTemplatesSqlRepository } from '../workout-templates/workout-templates-sql.repository.js';

@Module({
  imports: [ScheduleModule.forRoot()],
  controllers: [TrainingPlansController],
  providers: [
    TrainingPlansService,
    SetPlannerService,
    {
      provide: TRAINING_PLANS_REPOSITORY,
      useClass: TrainingPlansSqlRepository,
    },
    {
      provide: EXERCISES_REPOSITORY,
      useClass: ExercisesSqlRepository,
    },
    {
      provide: USERS_REPOSITORY,
      useClass: UsersSqlRepository,
    },
    {
      provide: WORKOUT_SESSIONS_REPOSITORY,
      useClass: WorkoutSessionsSqlRepository,
    },
    {
      provide: WORKOUT_TEMPLATES_REPOSITORY,
      useClass: WorkoutTemplatesSqlRepository,
    },
  ],
  exports: [TrainingPlansService],
})
export class TrainingPlansModule {}
