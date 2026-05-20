import { Inject, Injectable, Logger } from '@nestjs/common';
import {
  TRAINING_PLANS_REPOSITORY,
  WORKOUT_SESSIONS_REPOSITORY,
  type ITrainingPlansRepository,
  type IWorkoutSessionsRepository,
} from '../common/repositories/index.js';
import type {
  ActiveBlockDto,
  WeekSessionDto,
  TodaySessionDto,
  HomeDataResponseDto,
} from './dto/home-data.dto.js';

const SESSION_TYPE_DESCRIPTIONS: Record<string, string> = {
  push: 'Грудь + плечи + трицепс',
  pull: 'Спина + бицепс',
  legs: 'Ноги',
  upper: 'Верх тела',
  lower: 'Низ тела',
  full_body: 'Все тело',
};

const DAY_ORDER: Record<string, number> = {
  monday: 0,
  tuesday: 1,
  wednesday: 2,
  thursday: 3,
  friday: 4,
  saturday: 5,
  sunday: 6,
};

const DAY_NAMES = Object.keys(DAY_ORDER);

function getMonday(d: Date): Date {
  const date = new Date(d);
  const day = date.getDay();
  const diff = date.getDate() - day + (day === 0 ? -6 : 1);
  date.setDate(diff);
  date.setHours(0, 0, 0, 0);
  return date;
}

function addDays(d: Date, days: number): Date {
  const date = new Date(d);
  date.setDate(date.getDate() + days);
  return date;
}

function toISODate(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

@Injectable()
export class HomeDataService {
  private readonly logger = new Logger(HomeDataService.name);

  constructor(
    @Inject(TRAINING_PLANS_REPOSITORY)
    private readonly plansRepo: ITrainingPlansRepository,
    @Inject(WORKOUT_SESSIONS_REPOSITORY)
    private readonly sessionsRepo: IWorkoutSessionsRepository,
  ) {}

  async getHomeData(
    userId: string,
    weekStartParam?: string,
  ): Promise<HomeDataResponseDto> {
    const weekStartDate = weekStartParam
      ? new Date(weekStartParam + 'T00:00:00')
      : getMonday(new Date());
    const weekEndDate = addDays(weekStartDate, 6);

    const activePlan = await this.plansRepo.findActiveByUserId(userId);

    if (!activePlan) {
      this.logger.log(`No active plan for user ${userId}`);
      return {
        activeBlock: null,
        weekSessions: [],
        weekStart: toISODate(weekStartDate),
        weekEnd: toISODate(weekEndDate),
        todaySession: null,
      };
    }

    const planSession = await this.plansRepo.findActivePlanSession(userId);

    if (!planSession) {
      this.logger.warn(`Active plan ${activePlan.id} found but no active plan session for user ${userId}`);
    }

    const allSessions = planSession
      ? await this.sessionsRepo.findByPlanSessionId(planSession.id)
      : [];

    const currentWeek = planSession?.currentWeek ?? 1;
    const thisMonday = getMonday(new Date());
    const weekDiff = Math.round(
      (weekStartDate.getTime() - thisMonday.getTime()) / (7 * 24 * 60 * 60 * 1000),
    );
    const targetWeek = currentWeek + weekDiff;
    const weekSessions = allSessions.filter((s) => (s.weekNumber ?? 1) === targetWeek);

    this.logger.log(`Home data for user ${userId}: plan=${activePlan.id}, planSession=${planSession?.id ?? 'none'}, allSessions=${allSessions.length}, weekSessions=${weekSessions.length}`);

    const todayDayName = DAY_NAMES[new Date().getDay() === 0 ? 6 : new Date().getDay() - 1];
    const todaySessionEntity = weekDiff === 0
      ? weekSessions.find(
          (s) => s.dayOfWeek === todayDayName && s.status === 'planned',
        )
      : undefined;

    const activeBlockDto: ActiveBlockDto = {
      id: activePlan.id,
      name: activePlan.name,
      type: activePlan.source ?? 'manual',
      durationWeeks: 4,
      goal: undefined,
      splitName: undefined,
      currentWeek: planSession?.currentWeek ?? 1,
    };

    const mappedSessions: WeekSessionDto[] = weekSessions.map((s) => {
      const dayIdx = DAY_ORDER[s.dayOfWeek] ?? 0;
      const sessionDate = addDays(weekStartDate, dayIdx);
      const sessionType = s.metadata?.sessionType as string | undefined;
      return {
        id: s.id,
        dayOfWeek: s.dayOfWeek,
        date: toISODate(sessionDate),
        status: s.status ?? 'planned',
        sessionType,
        description: sessionType
          ? SESSION_TYPE_DESCRIPTIONS[sessionType] ?? sessionType
          : undefined,
        exerciseCount: s.exercises?.length,
        time: s.time,
      };
    });

    let todaySession: TodaySessionDto | null = null;
    if (todaySessionEntity) {
      const st = todaySessionEntity.metadata?.sessionType as string | undefined;
      todaySession = {
        id: todaySessionEntity.id,
        sessionType: st,
        description: st
          ? SESSION_TYPE_DESCRIPTIONS[st] ?? st
          : undefined,
        time: todaySessionEntity.time,
        exerciseCount: todaySessionEntity.exercises?.length,
      };
    }

    return {
      activeBlock: activeBlockDto,
      weekSessions: mappedSessions,
      weekStart: toISODate(weekStartDate),
      weekEnd: toISODate(weekEndDate),
      todaySession,
    };
  }
}
