import { Module } from '@nestjs/common';
import { WorkoutMilpController } from './workout-milp.controller.js';
import { WorkoutMilpService } from './workout-milp.service.js';
import { WeeklyProcessMilpService } from './weekly-process-milp.service.js';
import {
  EXERCISES_REPOSITORY,
  WORKOUT_TEMPLATES_REPOSITORY,
  USERS_REPOSITORY,
  TRAINING_BLOCKS_REPOSITORY,
  WORKOUT_SESSIONS_REPOSITORY,
  EQUIPMENT_PRESETS_REPOSITORY,
} from '../common/repositories/index.js';
import { ExercisesSqlRepository } from '../exercises/exercises-sql.repository.js';
import { WorkoutTemplatesSqlRepository } from '../workout-templates/workout-templates-sql.repository.js';
import { UsersSqlRepository } from '../users/users-sql.repository.js';
import { TrainingBlocksSqlRepository } from '../training-blocks/training-blocks-sql.repository.js';
import { WorkoutSessionsSqlRepository } from '../workout-sessions/workout-sessions-sql.repository.js';
import { EquipmentPresetsSqlRepository } from '../equipment-presets/equipment-presets-sql.repository.js';

@Module({
  controllers: [WorkoutMilpController],
  providers: [
    WorkoutMilpService,
    WeeklyProcessMilpService,
    {
      provide: EXERCISES_REPOSITORY,
      useClass: ExercisesSqlRepository,
    },
    {
      provide: WORKOUT_TEMPLATES_REPOSITORY,
      useClass: WorkoutTemplatesSqlRepository,
    },
    {
      provide: USERS_REPOSITORY,
      useClass: UsersSqlRepository,
    },
    {
      provide: TRAINING_BLOCKS_REPOSITORY,
      useClass: TrainingBlocksSqlRepository,
    },
    {
      provide: WORKOUT_SESSIONS_REPOSITORY,
      useClass: WorkoutSessionsSqlRepository,
    },
    {
      provide: EQUIPMENT_PRESETS_REPOSITORY,
      useClass: EquipmentPresetsSqlRepository,
    },
  ],
  exports: [WorkoutMilpService, WeeklyProcessMilpService],
})
export class WorkoutMilpModule {}
