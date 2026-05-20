import { Inject, Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import {
  TRAINING_PLANS_REPOSITORY,
  WORKOUT_SESSIONS_REPOSITORY,
  WORKOUT_TEMPLATES_REPOSITORY,
  USERS_REPOSITORY,
  type ITrainingPlansRepository,
  type IWorkoutSessionsRepository,
  type IWorkoutTemplatesRepository,
  type IUsersRepository,
} from '../common/repositories/index.js';
import type {
  TrainingPlan,
  TrainingPlanScheduleItem,
  TrainingPlanSession,
  WorkoutSession,
  WorkoutSessionExercise,
  WorkoutSessionExerciseMetadata,
} from '../entities/index.js';
import { SetPlannerService } from '../workout-sessions/set-planner.service.js';
import type { CreateTrainingPlanDto } from './dto/create-plan.dto.js';
import type { UpdateTrainingPlanDto } from './dto/update-plan.dto.js';
import type { TrainingPlanResponseDto, ScheduleItemResponseDto } from './dto/plan-response.dto.js';
import type { AssignTemplateDto } from './dto/assign-template.dto.js';
import type { ReplaceSessionDto } from './dto/replace-session.dto.js';
import type { WorkoutSessionResponseDto } from '../workout-sessions/dto/workout-session-response.dto.js';

const PLAN_DURATION_WEEKS = 4;
const DAY_ORDER = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

@Injectable()
export class TrainingPlansService {
  private readonly logger = new Logger(TrainingPlansService.name);

  constructor(
    @Inject(TRAINING_PLANS_REPOSITORY)
    private readonly plansRepo: ITrainingPlansRepository,
    @Inject(WORKOUT_SESSIONS_REPOSITORY)
    private readonly sessionsRepo: IWorkoutSessionsRepository,
    @Inject(WORKOUT_TEMPLATES_REPOSITORY)
    private readonly templatesRepo: IWorkoutTemplatesRepository,
    @Inject(USERS_REPOSITORY)
    private readonly usersRepo: IUsersRepository,
    private readonly setPlanner: SetPlannerService,
  ) {}

  async findAll(userId: string): Promise<TrainingPlanResponseDto[]> {
    const plans = await this.plansRepo.findByUserId(userId);
    return plans.map((p) => this.toResponseDto(p));
  }

  async findOne(userId: string, id: string): Promise<TrainingPlanResponseDto> {
    const plan = await this.plansRepo.findById(id);
    if (!plan || plan.userId !== userId) {
      throw new NotFoundException(`Training plan "${id}" not found`);
    }
    return this.toResponseDto(plan);
  }

  async create(userId: string, dto: CreateTrainingPlanDto): Promise<TrainingPlanResponseDto> {
    const plan = await this.plansRepo.create({
      userId,
      name: dto.name,
      isActive: false,
      source: 'manual',
      schedule: dto.schedule?.map((s, i) => ({
        dayOfWeek: s.dayOfWeek as TrainingPlanScheduleItem['dayOfWeek'],
        workoutTemplateId: s.workoutTemplateId,
        time: s.time,
        name: s.name,
        sortOrder: i,
      })),
    });
    return this.toResponseDto(plan);
  }

  async update(
    userId: string,
    id: string,
    dto: UpdateTrainingPlanDto,
  ): Promise<TrainingPlanResponseDto> {
    const plan = await this.plansRepo.findById(id);
    if (!plan || plan.userId !== userId) {
      throw new NotFoundException(`Training plan "${id}" not found`);
    }

    const updateData: Parameters<ITrainingPlansRepository['update']>[1] = {};
    if (dto.name !== undefined) updateData.name = dto.name;
    if (dto.schedule !== undefined) {
      updateData.schedule = dto.schedule.map((s, i) => ({
        dayOfWeek: s.dayOfWeek as TrainingPlanScheduleItem['dayOfWeek'],
        workoutTemplateId: s.workoutTemplateId,
        time: s.time,
        name: s.name,
        sortOrder: i,
      }));
    }

    const updated = await this.plansRepo.update(id, updateData);

    if (plan.isActive && dto.schedule !== undefined && updated?.schedule?.length) {
      const planSession = await this.plansRepo.findActivePlanSession(userId);
      if (planSession) {
        const existingSessions = await this.sessionsRepo.findByPlanSessionId(planSession.id);
        for (const s of existingSessions) {
          if (s.status === 'planned') {
            await this.sessionsRepo.delete(s.id);
          }
        }
        const sessions = await this.createAllWeekSessions(updated, planSession);
        const nearest = this.findNearestUpcomingSession(sessions);
        if (nearest) {
          await this.runSetPlanner(nearest);
        }
        this.logger.log(`Recreated ${sessions.length} planned sessions for active plan ${id} after schedule update`);
      }
    }

    return this.toResponseDto(updated!);
  }

  async delete(userId: string, id: string): Promise<void> {
    const plan = await this.plansRepo.findById(id);
    if (!plan || plan.userId !== userId) {
      throw new NotFoundException(`Training plan "${id}" not found`);
    }
    if (plan.isActive) {
      throw new BadRequestException('Cannot delete an active plan. Archive it first.');
    }

    if (plan.schedule?.length) {
      for (const item of plan.schedule) {
        try {
          await this.templatesRepo.delete(item.workoutTemplateId);
        } catch {}
      }
    }

    await this.plansRepo.delete(id);
  }

  async activate(userId: string, id: string): Promise<TrainingPlanResponseDto> {
    const plan = await this.plansRepo.findById(id);
    if (!plan || plan.userId !== userId) {
      throw new NotFoundException(`Training plan "${id}" not found`);
    }
    if (plan.isActive) {
      throw new BadRequestException('Plan is already active.');
    }
    if (!plan.schedule?.length) {
      throw new BadRequestException('Plan has no schedule. Assign templates first.');
    }

    const oldSession = await this.plansRepo.findActivePlanSession(userId);
    if (oldSession) {
      await this.plansRepo.archivePlanSession(oldSession.id);
    }

    await this.plansRepo.deactivateByUserId(userId);
    await this.plansRepo.activate(id);

    const today = new Date().toISOString().slice(0, 10);
    const planSession = await this.plansRepo.createPlanSession({
      planId: id,
      userId,
      startedAt: today,
      currentWeek: 1,
      status: 'active',
    });

    const sessions = await this.createAllWeekSessions(plan, planSession);
    const nearest = this.findNearestUpcomingSession(sessions);
    if (nearest) {
      await this.runSetPlanner(nearest);
    }

    const activated = await this.plansRepo.findById(id);
    this.logger.log(`Activated plan "${id}", session ${planSession.id}, created ${sessions.length} workout sessions`);
    return this.toResponseDto(activated!);
  }

  async archive(userId: string, id: string): Promise<TrainingPlanResponseDto> {
    const plan = await this.plansRepo.findById(id);
    if (!plan || plan.userId !== userId) {
      throw new NotFoundException(`Training plan "${id}" not found`);
    }

    await this.plansRepo.deactivateByUserId(userId);

    const activeSession = await this.plansRepo.findActivePlanSession(userId);
    if (activeSession) {
      await this.plansRepo.archivePlanSession(activeSession.id);
    }

    const updated = await this.plansRepo.findById(id);
    this.logger.log(`Archived plan "${id}"`);
    return this.toResponseDto(updated!);
  }

  async assignTemplate(
    userId: string,
    id: string,
    dto: AssignTemplateDto,
  ): Promise<TrainingPlanResponseDto> {
    const plan = await this.plansRepo.findById(id);
    if (!plan || plan.userId !== userId) {
      throw new NotFoundException(`Training plan "${id}" not found`);
    }

    await this.plansRepo.assignTemplate(
      id,
      dto.dayOfWeek,
      dto.workoutTemplateId,
      dto.time,
      dto.name,
    );

    const updated = await this.plansRepo.findById(id);
    return this.toResponseDto(updated!);
  }

  async unassignTemplate(
    userId: string,
    id: string,
    dayOfWeek: string,
  ): Promise<TrainingPlanResponseDto> {
    const plan = await this.plansRepo.findById(id);
    if (!plan || plan.userId !== userId) {
      throw new NotFoundException(`Training plan "${id}" not found`);
    }

    await this.plansRepo.unassignTemplate(id, dayOfWeek);

    const updated = await this.plansRepo.findById(id);
    return this.toResponseDto(updated!);
  }

  async replaceWorkout(
    userId: string,
    sessionId: string,
    dto: ReplaceSessionDto,
  ): Promise<void> {
    const session = await this.sessionsRepo.findById(sessionId);
    if (!session || session.userId !== userId) {
      throw new NotFoundException(`Session "${sessionId}" not found`);
    }
    if (session.status !== 'planned') {
      throw new BadRequestException('Can only replace a planned session.');
    }

    const planSession = await this.plansRepo.findActivePlanSession(userId);
    if (!planSession) return;

    await this.sessionsRepo.delete(sessionId);
    await this.plansRepo.assignTemplate(
      planSession.planId,
      session.dayOfWeek as string,
      dto.workoutTemplateId,
      undefined,
      dto.name,
    );

    const plan = await this.plansRepo.findById(planSession.planId);
    if (!plan) return;

    const scheduleItem = plan.schedule?.find((s) => s.dayOfWeek === session.dayOfWeek);
    if (scheduleItem) {
      await this.createWorkoutSessionFromSchedule(plan, planSession, scheduleItem);
    }
  }

  async advanceAfterComplete(userId: string, completedSessionId: string): Promise<void> {
    const completed = await this.sessionsRepo.findById(completedSessionId);
    if (!completed) return;

    const planSession = await this.plansRepo.findActivePlanSession(userId);
    if (!planSession) return;

    const plan = await this.plansRepo.findById(planSession.planId);
    if (!plan?.schedule?.length) return;

    const nextDay = this.findNextDay(plan.schedule, completed.dayOfWeek as string);
    const currentDayIdx = DAY_ORDER.indexOf(completed.dayOfWeek as string);
    const nextDayIdx = nextDay ? DAY_ORDER.indexOf(nextDay.dayOfWeek) : -1;
    const crossedWeek = nextDayIdx <= currentDayIdx;

    if (!nextDay || crossedWeek) {
      const newWeek = planSession.currentWeek + 1;
      if (newWeek > PLAN_DURATION_WEEKS) {
        await this.plansRepo.archivePlanSession(planSession.id);
        this.logger.log(`Plan session ${planSession.id} completed (4 weeks)`);
        return;
      }
      await this.plansRepo.updatePlanSessionWeek(planSession.id, newWeek);
      const newPlanSession = { ...planSession, currentWeek: newWeek };
      const sessions = await this.createAllWeekSessions(plan, newPlanSession);
      const target = nextDay
        ? sessions.find((s) => s.dayOfWeek === nextDay.dayOfWeek)
        : sessions[0];
      if (target) {
        await this.runSetPlanner(target);
      }
      this.logger.log(`Advanced to week ${newWeek}, created ${sessions.length} sessions`);
      return;
    }

    const allSessions = await this.sessionsRepo.findByPlanSessionId(planSession.id);
    const nextSession = allSessions.find(
      (s) => s.dayOfWeek === nextDay.dayOfWeek && s.status === 'planned',
    );
    if (nextSession) {
      await this.runSetPlanner(nextSession);
      this.logger.log(`SetPlanner ran for next session ${nextSession.id} (${nextDay.dayOfWeek})`);
    } else {
      this.logger.warn(`No planned session found for ${nextDay.dayOfWeek}, creating new`);
      await this.createWorkoutSessionFromSchedule(plan, planSession, nextDay);
    }
  }

  private async createWorkoutSessionFromSchedule(
    plan: TrainingPlan,
    planSession: TrainingPlanSession,
    scheduleItem: NonNullable<TrainingPlan['schedule']>[number],
    runSetPlanner = true,
  ): Promise<WorkoutSession> {
    const template = await this.templatesRepo.findById(scheduleItem.workoutTemplateId);

    const exercises: WorkoutSessionExercise[] = template?.exercises?.map((e) => ({
      exerciseSlug: e.exerciseSlug,
      sets: e.sets,
      order: e.order,
      metadata: {
        restBetweenSets: e.restBetweenSets ?? undefined,
        restAfterExercise: e.restAfterExercise ?? undefined,
      } as WorkoutSessionExerciseMetadata | undefined,
    })) ?? [];

    const session = await this.sessionsRepo.create({
      userId: plan.userId,
      planSessionId: planSession.id,
      dayOfWeek: scheduleItem.dayOfWeek as WorkoutSession['dayOfWeek'],
      time: scheduleItem.time,
      status: 'planned',
      weekNumber: planSession.currentWeek,
      metadata: {
        sessionType: scheduleItem.name ?? undefined,
      } as Record<string, unknown>,
      exercises,
    });

    if (runSetPlanner) {
      await this.runSetPlanner(session);
    }

    this.logger.log(`Created workout session ${session.id} from template ${scheduleItem.workoutTemplateId} (${scheduleItem.dayOfWeek}, week ${planSession.currentWeek}), ${exercises.length} exercises, setPlanner=${runSetPlanner}`);
    return session;
  }

  private async createAllWeekSessions(
    plan: TrainingPlan,
    planSession: TrainingPlanSession,
  ): Promise<WorkoutSession[]> {
    if (!plan.schedule?.length) return [];
    const sessions: WorkoutSession[] = [];
    for (const item of plan.schedule) {
      const session = await this.createWorkoutSessionFromSchedule(plan, planSession, item, false);
      sessions.push(session);
    }
    return sessions;
  }

  private findNearestUpcomingSession(sessions: WorkoutSession[]): WorkoutSession | undefined {
    const jsDay = new Date().getDay();
    const todayIdx = jsDay === 0 ? 6 : jsDay - 1;
    let best: WorkoutSession | undefined;
    let bestDistance = Infinity;
    for (const s of sessions) {
      const sessionIdx = DAY_ORDER.indexOf(s.dayOfWeek as string);
      let distance = sessionIdx - todayIdx;
      if (distance < 0) distance += 7;
      if (distance < bestDistance) {
        bestDistance = distance;
        best = s;
      }
    }
    return best;
  }

  private async runSetPlanner(session: WorkoutSession): Promise<void> {
    try {
      await this.setPlanner.planSetsForSession(session);
    } catch (e) {
      this.logger.warn(`SetPlanner failed for session ${session.id}: ${(e as Error).message}`);
    }
  }

  private findNextDay(
    schedule: NonNullable<TrainingPlan['schedule']>,
    completedDay: string,
  ): NonNullable<TrainingPlan['schedule']>[number] | null {
    const currentIdx = DAY_ORDER.indexOf(completedDay);
    for (let offset = 1; offset <= 7; offset++) {
      const candidateIdx = (currentIdx + offset) % 7;
      const day = DAY_ORDER[candidateIdx];
      const found = schedule.find((s) => s.dayOfWeek === day);
      if (found) return found;
    }
    return null;
  }

  private toResponseDto(plan: TrainingPlan): TrainingPlanResponseDto {
    return {
      id: plan.id,
      userId: plan.userId,
      name: plan.name,
      isActive: plan.isActive,
      source: plan.source,
      schedule: plan.schedule?.map(
        (s): ScheduleItemResponseDto => ({
          dayOfWeek: s.dayOfWeek,
          workoutTemplateId: s.workoutTemplateId,
          time: s.time,
          name: s.name,
          sortOrder: s.sortOrder,
        }),
      ) ?? [],
      createdAt: plan.createdAt,
    };
  }
}
