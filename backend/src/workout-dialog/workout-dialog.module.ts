import { Module } from '@nestjs/common';
import { WorkoutDialogController } from './workout-dialog.controller.js';
import { WorkoutDialogService } from './workout-dialog.service.js';
import { WorkoutDialogsSqlRepository } from './workout-dialogs-sql.repository.js';
import {
  WORKOUT_DIALOGS_REPOSITORY,
  USERS_REPOSITORY,
  EQUIPMENTS_REPOSITORY,
  EQUIPMENT_PRESETS_REPOSITORY,
} from '../common/repositories/index.js';
import { UsersSqlRepository } from '../users/users-sql.repository.js';
import { EquipmentsSqlRepository } from '../equipments/equipments-sql.repository.js';
import { EquipmentPresetsSqlRepository } from '../equipment-presets/equipment-presets-sql.repository.js';

@Module({
  controllers: [WorkoutDialogController],
  providers: [
    WorkoutDialogService,
    {
      provide: WORKOUT_DIALOGS_REPOSITORY,
      useClass: WorkoutDialogsSqlRepository,
    },
    {
      provide: USERS_REPOSITORY,
      useClass: UsersSqlRepository,
    },
    {
      provide: EQUIPMENTS_REPOSITORY,
      useClass: EquipmentsSqlRepository,
    },
    {
      provide: EQUIPMENT_PRESETS_REPOSITORY,
      useClass: EquipmentPresetsSqlRepository,
    },
  ],
})
export class WorkoutDialogModule {}
