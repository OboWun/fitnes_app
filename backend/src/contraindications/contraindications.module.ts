import { Module } from '@nestjs/common';
import { ContraindicationsController } from './contraindications.controller.js';
import { ContraindicationsService } from './contraindications.service.js';
import { ContraindicationsJsonRepository } from './contraindications-json.repository.js';
import { CONTRAINDICATIONS_REPOSITORY } from '../common/repositories/index.js';

@Module({
  controllers: [ContraindicationsController],
  providers: [
    ContraindicationsService,
    {
      provide: CONTRAINDICATIONS_REPOSITORY,
      useClass: ContraindicationsJsonRepository,
    },
  ],
  exports: [ContraindicationsService],
})
export class ContraindicationsModule {}
