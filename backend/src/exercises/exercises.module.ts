import { Module } from '@nestjs/common';
import { ExercisesController } from './exercises.controller.js';
import { ExercisesService } from './exercises.service.js';
import { ExercisesSqlRepository } from './exercises-sql.repository.js';
import { EXERCISES_REPOSITORY } from '../common/repositories/index.js';
import { MusclesModule } from '../muscles/muscles.module.js';
import { BodypartsModule } from '../bodyparts/bodyparts.module.js';
import { EquipmentsModule } from '../equipments/equipments.module.js';
import { AuthModule } from '../auth/auth.module.js';

@Module({
  imports: [AuthModule, MusclesModule, BodypartsModule, EquipmentsModule],
  controllers: [ExercisesController],
  providers: [
    ExercisesService,
    {
      provide: EXERCISES_REPOSITORY,
      useClass: ExercisesSqlRepository,
    },
  ],
})
export class ExercisesModule {}
