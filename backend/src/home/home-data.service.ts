import { Inject, Injectable } from '@nestjs/common';
import {
  TRAINING_BLOCKS_REPOSITORY,
  WORKOUT_SESSIONS_REPOSITORY,
  type ITrainingBlocksRepository,
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
  return d.toISOString().slice(0, 10);
}

@Injectable()
export class HomeDataService {
  constructor(
    @Inject(TRAINING_BLOCKS_REPOSITORY)
    private readonly blocksRepo: ITrainingBlocksRepository,
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

    const blocks = await this.blocksRepo.findByUserId(userId);
    const activeBlock = blocks.length > 0 ? blocks[blocks.length - 1] : null;

    if (!activeBlock) {
      return {
        activeBlock: null,
        weekSessions: [],
        weekStart: toISODate(weekStartDate),
        weekEnd: toISODate(weekEndDate),
        todaySession: null,
      };
    }

    const allSessions = await this.sessionsRepo.findByBlockId(activeBlock.id);
    const weekSessions = allSessions.filter((s) => {
      const dayIdx = DAY_ORDER[s.dayOfWeek] ?? 0;
      const sessionDate = addDays(weekStartDate, dayIdx);
      return sessionDate >= weekStartDate && sessionDate <= weekEndDate;
    });

    const todayDayName = DAY_NAMES[new Date().getDay() === 0 ? 6 : new Date().getDay() - 1];
    const todaySessionEntity = weekSessions.find(
      (s) => s.dayOfWeek === todayDayName,
    );

    const currentWeek = this.computeCurrentWeek(activeBlock.id);

    const activeBlockDto: ActiveBlockDto = {
      id: activeBlock.id,
      name: activeBlock.name,
      type: activeBlock.type,
      durationWeeks: activeBlock.durationWeeks,
      goal: activeBlock.goal,
      splitName: activeBlock.metadata?.splitName,
      currentWeek,
    };

    const mappedSessions: WeekSessionDto[] = weekSessions.map((s) => {
      const dayIdx = DAY_ORDER[s.dayOfWeek] ?? 0;
      const sessionDate = addDays(weekStartDate, dayIdx);
      const sessionType = s.metadata?.sessionType;
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
      const st = todaySessionEntity.metadata?.sessionType;
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

  private computeCurrentWeek(blockId: string): number {
    const createdMs = parseInt(blockId.slice(0, 7), 36);
    const now = Date.now();
    const diffDays = Math.floor((now - createdMs) / (1000 * 60 * 60 * 24));
    return Math.floor(diffDays / 7) + 1;
  }
}
