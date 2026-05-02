import { Module } from '@nestjs/common';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { BodypartsModule } from './bodyparts/bodyparts.module.js';
import { EquipmentsModule } from './equipments/equipments.module.js';
import { MusclesModule } from './muscles/muscles.module.js';
import { ExercisesModule } from './exercises/exercises.module.js';
import { ContraindicationsModule } from './contraindications/contraindications.module.js';
import { UsersModule } from './users/users.module.js';
import { AuthModule } from './auth/auth.module.js';
import { WorkoutTemplatesModule } from './workout-templates/workout-templates.module.js';

@Module({
  imports: [
    BodypartsModule,
    EquipmentsModule,
    MusclesModule,
    ExercisesModule,
    ContraindicationsModule,
    UsersModule,
    AuthModule,
    WorkoutTemplatesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
