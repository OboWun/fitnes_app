import { Module } from '@nestjs/common';
import { EquipmentsController } from './equipments.controller.js';
import { EquipmentsService } from './equipments.service.js';
import { EquipmentsJsonRepository } from './equipments-json.repository.js';
import { EQUIPMENTS_REPOSITORY } from '../common/repositories/index.js';

@Module({
  controllers: [EquipmentsController],
  providers: [
    EquipmentsService,
    {
      provide: EQUIPMENTS_REPOSITORY,
      useClass: EquipmentsJsonRepository,
    },
  ],
  exports: [EQUIPMENTS_REPOSITORY],
})
export class EquipmentsModule {}
