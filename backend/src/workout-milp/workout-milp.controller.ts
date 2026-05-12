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
  ApiOkResponse,
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
  WorkoutMetricsInputDto,
  WorkoutMetricsResponseDto,
} from './dto/workout-metrics.dto.js';
import {
  WORKOUT_TEMPLATES_REPOSITORY,
  USERS_REPOSITORY,
  EQUIPMENT_PRESETS_REPOSITORY,
} from '../common/repositories/index.js';
import type {
  IWorkoutTemplatesRepository,
  IUsersRepository,
  IEquipmentPresetsRepository,
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
    @Inject(EQUIPMENT_PRESETS_REPOSITORY)
    private readonly presetsRepository: IEquipmentPresetsRepository,
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

    const { fatigueByMuscle, usedExercises } =
      await this.milpService.computeFatigueAndHistory(user.id);

    const weeklyVolumeByMuscle = await this.milpService.computeWeeklyVolume(
      user.id,
    );

    const availableEquipment = await this.resolveEquipment(
      dto.equipmentPresetId,
      dto.availableEquipment,
      user.id,
      fullUser?.metadata?.availableEquipment ?? undefined,
    );

    const input = {
      userId: user.id,
      sessionDurationMin: dto.sessionDurationMin,
      experienceLevel: dto.experienceLevel,
      goal: dto.goal,
      focusMuscles: dto.focusMuscles,
      specificMuscles: dto.specificMuscles,
      availableEquipment,
      phase: dto.phase,
      fatigueByMuscle,
      usedExercises,
      userContraindications: fullUser?.contraindications ?? [],
      gender: fullUser?.gender,
      weeklyVolumeByMuscle,
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

    const metrics = await this.milpService.computeMetrics({
      exercises: result.exercises,
      goal: dto.goal,
      bodyweightKg: fullUser?.weight,
    });

    return {
      exercises: result.exercises,
      totalTimeSec: result.totalTimeSec,
      totalLoadByMuscle: result.totalLoadByMuscle,
      templateId: template.id,
      usedFallback: result.usedFallback,
      partialCoverage: result.partialCoverage,
      unmetMandatory: result.unmetMandatory,
      metrics,
    };
  }

  @Post('metrics')
  @ApiOperation({ summary: 'Compute workout metrics for given exercises' })
  @ApiOkResponse({ type: WorkoutMetricsResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async getMetrics(
    @Body() dto: WorkoutMetricsInputDto,
  ): Promise<WorkoutMetricsResponseDto> {
    return this.milpService.computeMetrics({
      exercises: dto.exercises,
      restBetweenSetsSec: dto.restBetweenSetsSec,
      bodyweightKg: dto.bodyweightKg,
      goal: dto.goal,
    });
  }

  @Post('weekly-plan')
  @ApiOperation({
    summary: 'Generate a weekly training plan using MILP optimization',
  })
  @ApiCreatedResponse({ type: GenerateWeeklyPlanResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async generateWeeklyPlan(
    @CurrentUser() user: User,
    @Body() dto: GenerateWeeklyPlanDto,
  ): Promise<GenerateWeeklyPlanResponseDto> {
    const fullUser = await this.usersRepository.findById(user.id);

    const availableEquipment = await this.resolveEquipment(
      dto.equipmentPresetId,
      dto.availableEquipment,
      user.id,
      fullUser?.metadata?.availableEquipment ?? undefined,
    );

    const result = await this.weeklyService.generateWeeklyPlan({
      userId: user.id,
      availableDays: dto.availableDays as DayOfWeek[],
      trainingCountPerWeek: dto.trainingCountPerWeek,
      sessionDurationMin: dto.sessionDurationMin,
      experienceLevel: dto.experienceLevel ?? 'intermediate',
      goal: dto.goal ?? 'general_health',
      gender: fullUser?.gender ?? 'male',
      availableEquipment,
      phase: dto.phase,
      userContraindications: fullUser?.contraindications ?? [],
    });

    return {
      blockId: result.blockId,
      splitName: result.splitName,
      sessions: result.sessions.map((s) => ({
        dayOfWeek: s.dayOfWeek,
        sessionType: s.sessionType,
        exercises: s.exercises,
        loadByMuscle: s.loadByMuscle,
        totalTimeSec: s.totalTimeSec,
        repsPerSet: s.repsPerSet,
      })),
      totalWeeklyLoad: result.totalWeeklyLoad,
      weeklyVolumeByMuscle: result.weeklyVolumeByMuscle,
      usedFallback: result.sessions.some((s) => s.usedFallback),
    };
  }

  private async resolveEquipment(
    presetId: string | undefined,
    explicit: string[] | undefined,
    userId: string,
    profileEquipment: string[] | undefined,
  ): Promise<string[]> {
    if (presetId) {
      const preset = await this.presetsRepository.findById(presetId);
      if (preset && (preset.isSystem || preset.userId === userId)) {
        return preset.equipmentSlugs;
      }
    }
    return explicit ?? profileEquipment ?? [];
  }
}
