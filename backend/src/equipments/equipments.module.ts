import { Module } from '@nestjs/common';
import { EquipmentsController } from './equipments.controller.js';
import { EquipmentsService } from './equipments.service.js';
import { EquipmentsSqlRepository } from './equipments-sql.repository.js';
import { EQUIPMENTS_REPOSITORY } from '../common/repositories/index.js';

@Module({
  controllers: [EquipmentsController],
  providers: [
    EquipmentsService,
    {
      provide: EQUIPMENTS_REPOSITORY,
      useClass: EquipmentsSqlRepository,
    },
  ],
  exports: [EQUIPMENTS_REPOSITORY],
})
export class EquipmentsModule {}
