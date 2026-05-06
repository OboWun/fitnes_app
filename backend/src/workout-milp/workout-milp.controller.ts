import {
  Controller,
  Post,
  Body,
  UseGuards,
  UsePipes,
  ValidationPipe,
  Inject,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import type { User, DayOfWeek } from '../entities/index.js';
import { WorkoutMilpService } from './workout-milp.service.js';
import { WeeklyProcessMilpService } from './weekly-process-milp.service.js';
import { GenerateWorkoutDto } from './dto/generate-workout.dto.js';
import { GenerateWorkoutResponseDto } from './dto/generate-workout-response.dto.js';
import { GenerateWeeklyPlanDto } from './dto/generate-weekly-plan.dto.js';
import { GenerateWeeklyPlanResponseDto } from './dto/generate-weekly-plan-response.dto.js';
import {
  WORKOUT_TEMPLATES_REPOSITORY,
  USERS_REPOSITORY,
} from '../common/repositories/index.js';
import type {
  IWorkoutTemplatesRepository,
  IUsersRepository,
} from '../common/repositories/index.js';

@ApiTags('Workout MILP')
@ApiBearerAuth()
@Controller('workout-milp')
@UseGuards(JwtAuthGuard)
export class WorkoutMilpController {
  constructor(
    private readonly milpService: WorkoutMilpService,
    private readonly weeklyService: WeeklyProcessMilpService,
    @Inject(WORKOUT_TEMPLATES_REPOSITORY)
    private readonly templatesRepository: IWorkoutTemplatesRepository,
    @Inject(USERS_REPOSITORY)
    private readonly usersRepository: IUsersRepository,
  ) {}

  @Post('generate')
  @ApiOperation({ summary: 'Generate a workout using MILP optimization' })
  @ApiCreatedResponse({ type: GenerateWorkoutResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async generate(
    @CurrentUser() user: User,
    @Body() dto: GenerateWorkoutDto,
  ): Promise<GenerateWorkoutResponseDto> {
    const fullUser = await this.usersRepository.findById(user.id);

    const { fatigueByMuscle, usedExercises } = await this.milpService.computeFatigueAndHistory(user.id);

    const input = {
      userId: user.id,
      sessionDurationMin: dto.sessionDurationMin,
      exerciseCount: dto.exerciseCount,
      setsPerExercise: dto.setsPerExercise,
      restBetweenSetsSec: dto.restBetweenSetsSec,
      availableEquipment:
        dto.availableEquipment ??
        fullUser?.metadata?.availableEquipment ??
        [],
      phase: dto.phase,
      fatigueByMuscle,
      usedExercises,
      mandatoryMuscles: dto.mandatoryMuscles,
      userContraindications: fullUser?.contraindications ?? [],
    };

    const result = await this.milpService.generateWorkout(input);

    const template = await this.templatesRepository.create({
      userId: user.id,
      name: `Generated ${new Date().toISOString().slice(0, 10)}`,
      exercises: result.exercises.map((e) => ({
        exerciseSlug: e.exerciseSlug,
        sets: e.sets,
        order: e.order,
      })),
      metadata: {
        sessionDurationMin: dto.sessionDurationMin,
        phase: dto.phase,
      },
    });

    return {
      exercises: result.exercises,
      totalTimeSec: result.totalTimeSec,
      totalLoadByMuscle: result.totalLoadByMuscle,
      templateId: template.id,
      usedFallback: result.usedFallback,
      partialCoverage: result.partialCoverage,
      unmetMandatory: result.unmetMandatory,
    };
  }

  @Post('weekly-plan')
  @ApiOperation({ summary: 'Generate a weekly training plan using MILP optimization' })
  @ApiCreatedResponse({ type: GenerateWeeklyPlanResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async generateWeeklyPlan(
    @CurrentUser() user: User,
    @Body() dto: GenerateWeeklyPlanDto,
  ): Promise<GenerateWeeklyPlanResponseDto> {
    const fullUser = await this.usersRepository.findById(user.id);

    const result = await this.weeklyService.generateWeeklyPlan({
      userId: user.id,
      availableDays: dto.availableDays as DayOfWeek[],
      trainingCountPerWeek: dto.trainingCountPerWeek,
      sessionDurationMin: dto.sessionDurationMin,
      exerciseCount: dto.exerciseCount ?? 5,
      setsPerExercise: dto.setsPerExercise ?? 3,
      minRestDays: dto.minRestDays ?? 1,
      maxRestDays: dto.maxRestDays ?? 3,
      weeklyLoadLimit: dto.weeklyLoadLimit,
      consecutiveTrainingDaysLimit: dto.consecutiveTrainingDaysLimit ?? 2,
      phase: dto.phase,
      weekType: dto.weekType,
      availableEquipment:
        dto.availableEquipment ??
        fullUser?.metadata?.availableEquipment ??
        [],
      mandatoryMuscles: dto.mandatoryMuscles,
      userContraindications: fullUser?.contraindications ?? [],
    });

    return {
      blockId: result.blockId,
      sessions: result.sessions.map((s) => ({
        dayOfWeek: s.dayOfWeek,
        exercises: s.exercises,
        loadByMuscle: s.loadByMuscle,
        totalTimeSec: s.totalTimeSec,
      })),
      restDays: result.restDays,
      totalWeeklyLoad: result.totalWeeklyLoad,
    };
  }
}
