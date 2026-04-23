import { Module } from '@nestjs/common';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { BodypartsModule } from './bodyparts/bodyparts.module.js';
import { EquipmentsModule } from './equipments/equipments.module.js';
import { MusclesModule } from './muscles/muscles.module.js';
import { ExercisesModule } from './exercises/exercises.module.js';

@Module({
  imports: [BodypartsModule, EquipmentsModule, MusclesModule, ExercisesModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
