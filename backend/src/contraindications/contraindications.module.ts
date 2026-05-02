import { Module } from '@nestjs/common';
import { ContraindicationsController } from './contraindications.controller.js';
import { ContraindicationsService } from './contraindications.service.js';
import { ContraindicationsSqlRepository } from './contraindications-sql.repository.js';
import { CONTRAINDICATIONS_REPOSITORY } from '../common/repositories/index.js';

@Module({
  controllers: [ContraindicationsController],
  providers: [
    ContraindicationsService,
    {
      provide: CONTRAINDICATIONS_REPOSITORY,
      useClass: ContraindicationsSqlRepository,
    },
  ],
  exports: [ContraindicationsService],
})
export class ContraindicationsModule {}
