import { Module } from '@nestjs/common';
import { ExercisesController } from './exercises.controller.js';
import { ExercisesService } from './exercises.service.js';
import { ExercisesJsonRepository } from './exercises-json.repository.js';
import { EXERCISES_REPOSITORY } from '../common/repositories/index.js';
import { MusclesModule } from '../muscles/muscles.module.js';
import { BodypartsModule } from '../bodyparts/bodyparts.module.js';
import { EquipmentsModule } from '../equipments/equipments.module.js';

@Module({
  imports: [MusclesModule, BodypartsModule, EquipmentsModule],
  controllers: [ExercisesController],
  providers: [
    ExercisesService,
    {
      provide: EXERCISES_REPOSITORY,
      useClass: ExercisesJsonRepository,
    },
  ],
})
export class ExercisesModule {}
