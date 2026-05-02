import { Module } from '@nestjs/common';
import { WorkoutTemplatesController } from './workout-templates.controller.js';
import { WorkoutTemplatesService } from './workout-templates.service.js';
import {
  WorkoutTemplatesJsonRepository,
  ScheduledWorkoutsJsonRepository,
} from './workout-templates-json.repository.js';
import {
  WORKOUT_TEMPLATES_REPOSITORY,
  SCHEDULED_WORKOUTS_REPOSITORY,
} from '../common/repositories/index.js';

@Module({
  controllers: [WorkoutTemplatesController],
  providers: [
    WorkoutTemplatesService,
    {
      provide: WORKOUT_TEMPLATES_REPOSITORY,
      useClass: WorkoutTemplatesJsonRepository,
    },
    {
      provide: SCHEDULED_WORKOUTS_REPOSITORY,
      useClass: ScheduledWorkoutsJsonRepository,
    },
  ],
})
export class WorkoutTemplatesModule {}
