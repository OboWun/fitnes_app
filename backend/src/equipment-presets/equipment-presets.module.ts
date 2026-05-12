import { Module } from '@nestjs/common';
import { EquipmentPresetsController } from './equipment-presets.controller.js';
import { EquipmentPresetsService } from './equipment-presets.service.js';
import { EquipmentPresetsSqlRepository } from './equipment-presets-sql.repository.js';
import { EquipmentsSqlRepository } from '../equipments/equipments-sql.repository.js';
import {
  EQUIPMENT_PRESETS_REPOSITORY,
  EQUIPMENTS_REPOSITORY,
} from '../common/repositories/index.js';

@Module({
  controllers: [EquipmentPresetsController],
  providers: [
    EquipmentPresetsService,
    {
      provide: EQUIPMENT_PRESETS_REPOSITORY,
      useClass: EquipmentPresetsSqlRepository,
    },
    {
      provide: EQUIPMENTS_REPOSITORY,
      useClass: EquipmentsSqlRepository,
    },
  ],
  exports: [EquipmentPresetsService, EQUIPMENT_PRESETS_REPOSITORY],
})
export class EquipmentPresetsModule {}
