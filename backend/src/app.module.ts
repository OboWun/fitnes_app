import { Module } from '@nestjs/common';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { DatabaseModule } from './common/database/database.module.js';
import { BodypartsModule } from './bodyparts/bodyparts.module.js';
import { EquipmentsModule } from './equipments/equipments.module.js';
import { MusclesModule } from './muscles/muscles.module.js';
import { ExercisesModule } from './exercises/exercises.module.js';
import { ContraindicationsModule } from './contraindications/contraindications.module.js';
import { UsersModule } from './users/users.module.js';
import { AuthModule } from './auth/auth.module.js';
import { WorkoutTemplatesModule } from './workout-templates/workout-templates.module.js';
import { TrainingBlocksModule } from './training-blocks/training-blocks.module.js';
import { WorkoutSessionsModule } from './workout-sessions/workout-sessions.module.js';
import { WorkoutMilpModule } from './workout-milp/workout-milp.module.js';
import { WorkoutDialogModule } from './workout-dialog/workout-dialog.module.js';
import { EquipmentPresetsModule } from './equipment-presets/equipment-presets.module.js';

@Module({
  imports: [
    DatabaseModule,
    BodypartsModule,
    EquipmentsModule,
    MusclesModule,
    ExercisesModule,
    ContraindicationsModule,
    UsersModule,
    AuthModule,
    WorkoutTemplatesModule,
    TrainingBlocksModule,
    WorkoutSessionsModule,
    WorkoutMilpModule,
    WorkoutDialogModule,
    EquipmentPresetsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
