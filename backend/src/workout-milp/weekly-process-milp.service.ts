import { Inject, Injectable } from '@nestjs/common';
import { WorkoutMilpService } from './workout-milp.service.js';
import type { WorkoutMILPInput, WorkoutMILPOutput } from './workout-milp.service.js';
import { TRAINING_BLOCKS_REPOSITORY, WORKOUT_SESSIONS_REPOSITORY, USERS_REPOSITORY } from '../common/repositories/index.js';
import type { ITrainingBlocksRepository, IWorkoutSessionsRepository, IUsersRepository } from '../common/repositories/index.js';
import type { DayOfWeek } from '../entities/index.js';

// Prior from MILP.md section 3.3
const LAMBDA = 0.345;

const DAY_ORDER: DayOfWeek[] = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

export interface WeeklyProcessInput {
  userId: string;
  availableDays: DayOfWeek[];
  trainingCountPerWeek: number;
  sessionDurationMin: number;
  exerciseCount: number;
  setsPerExercise: number;
  minRestDays: number;
  maxRestDays: number;
  weeklyLoadLimit?: number;
  consecutiveTrainingDaysLimit: number;
  phase?: string;
  weekType?: string;
  availableEquipment: string[];
  mandatoryMuscles?: string[];
  userContraindications?: string[];
}

export interface WeeklyProcessOutput {
  blockId: string;
  sessions: {
    dayOfWeek: DayOfWeek;
    exercises: { exerciseSlug: string; sets: number; order: number }[];
    loadByMuscle: Record<string, number>;
    totalTimeSec: number;
  }[];
  restDays: number[];
  totalWeeklyLoad: number;
}

@Injectable()
export class WeeklyProcessMilpService {
  constructor(
    private readonly workoutMilpService: WorkoutMilpService,
    @Inject(TRAINING_BLOCKS_REPOSITORY)
    private readonly blocksRepository: ITrainingBlocksRepository,
    @Inject(WORKOUT_SESSIONS_REPOSITORY)
    private readonly sessionsRepository: IWorkoutSessionsRepository,
    @Inject(USERS_REPOSITORY)
    private readonly usersRepository: IUsersRepository,
  ) {}

  async generateWeeklyPlan(input: WeeklyProcessInput): Promise<WeeklyProcessOutput> {
    // 1. Select training days respecting constraints
    const trainingDays = this.selectTrainingDays(input);

    // 2. Generate workout for each day with fatigue accumulation
    const fatigueByMuscle: Record<string, number> = {};
    const usedExercises: string[] = [];
    const sessions: WeeklyProcessOutput['sessions'] = [];
    let totalWeeklyLoad = 0;

    for (let i = 0; i < trainingDays.length; i++) {
      const day = trainingDays[i];

      // Calculate rest days since last training (for fatigue decay)
      let restDaysSinceLast = 1;
      if (i > 0) {
        const prevIdx = DAY_ORDER.indexOf(trainingDays[i - 1]);
        const currIdx = DAY_ORDER.indexOf(day);
        restDaysSinceLast = currIdx - prevIdx;
      }

      // Apply fatigue decay: F_m(t+1) = F_m(t) * exp(-lambda * restDays)
      for (const muscle of Object.keys(fatigueByMuscle)) {
        fatigueByMuscle[muscle] *= Math.exp(-LAMBDA * restDaysSinceLast);
      }

      // Generate workout for this day
      const workoutInput: WorkoutMILPInput = {
        userId: input.userId,
        sessionDurationMin: input.sessionDurationMin,
        exerciseCount: input.exerciseCount,
        setsPerExercise: input.setsPerExercise,
        availableEquipment: input.availableEquipment,
        phase: input.phase,
        fatigueByMuscle: { ...fatigueByMuscle },
        usedExercises: [...usedExercises],
        mandatoryMuscles: input.mandatoryMuscles,
        userContraindications: input.userContraindications,
      };

      const result = await this.workoutMilpService.generateWorkout(workoutInput);

      // Update fatigue: add load from this session
      for (const [muscle, load] of Object.entries(result.totalLoadByMuscle)) {
        fatigueByMuscle[muscle] = (fatigueByMuscle[muscle] ?? 0) + load;
      }

      // Track used exercises
      for (const ex of result.exercises) {
        if (!usedExercises.includes(ex.exerciseSlug)) {
          usedExercises.push(ex.exerciseSlug);
        }
      }

      // Track total weekly load
      const sessionLoad = Object.values(result.totalLoadByMuscle).reduce((s, v) => s + v, 0);
      totalWeeklyLoad += sessionLoad;

      // Check weekly load limit
      if (input.weeklyLoadLimit && totalWeeklyLoad > input.weeklyLoadLimit) {
        // Stop generating more sessions
        break;
      }

      sessions.push({
        dayOfWeek: day,
        exercises: result.exercises,
        loadByMuscle: result.totalLoadByMuscle,
        totalTimeSec: result.totalTimeSec,
      });
    }

    // 3. Calculate rest days between sessions
    const restDays: number[] = [];
    for (let i = 1; i < sessions.length; i++) {
      const prevIdx = DAY_ORDER.indexOf(sessions[i - 1].dayOfWeek);
      const currIdx = DAY_ORDER.indexOf(sessions[i].dayOfWeek);
      restDays.push(currIdx - prevIdx - 1);
    }

    // 4. Save as TrainingBlock + WorkoutSessions
    const block = await this.blocksRepository.create({
      userId: input.userId,
      name: `Week Plan ${new Date().toISOString().slice(0, 10)}`,
      type: (input.weekType as 'base' | 'build' | 'taper' | 'recovery') ?? 'base',
      index: 0,
      durationWeeks: 1,
      metadata: {
        phase: input.phase,
        weekType: input.weekType,
        minRestDays: input.minRestDays,
        maxRestDays: input.maxRestDays,
        weeklyLoadLimit: input.weeklyLoadLimit,
        consecutiveTrainingDaysLimit: input.consecutiveTrainingDaysLimit,
      },
    });

    for (const session of sessions) {
      await this.sessionsRepository.create({
        blockId: block.id,
        userId: input.userId,
        dayOfWeek: session.dayOfWeek,
        status: 'planned',
        metadata: {
          sessionDurationMin: input.sessionDurationMin,
          sessionLoadByMuscle: Object.entries(session.loadByMuscle).map(([slug, load]) => ({ slug, load })),
        },
        exercises: session.exercises.map((e) => ({
          exerciseSlug: e.exerciseSlug,
          sets: e.sets,
          order: e.order,
        })),
      });
    }

    return {
      blockId: block.id,
      sessions,
      restDays,
      totalWeeklyLoad,
    };
  }

  private selectTrainingDays(input: WeeklyProcessInput): DayOfWeek[] {
    const available = input.availableDays
      .filter((d) => DAY_ORDER.includes(d))
      .sort((a, b) => DAY_ORDER.indexOf(a) - DAY_ORDER.indexOf(b));

    const N = Math.min(input.trainingCountPerWeek, available.length);
    if (N <= 0) return [];

    // Greedy selection respecting minRestDays and consecutiveLimit
    const selected: DayOfWeek[] = [];
    let consecutive = 0;

    for (const day of available) {
      if (selected.length >= N) break;

      const dayIdx = DAY_ORDER.indexOf(day);

      if (selected.length > 0) {
        const lastIdx = DAY_ORDER.indexOf(selected[selected.length - 1]);
        const gap = dayIdx - lastIdx;

        // Check min rest days
        if (gap - 1 < input.minRestDays) continue;

        // Check consecutive limit
        if (gap === 1) {
          consecutive++;
          if (consecutive >= input.consecutiveTrainingDaysLimit) continue;
        } else {
          consecutive = 0;
        }
      }

      selected.push(day);
    }

    // If we couldn't select enough days with strict constraints, relax and just pick evenly
    if (selected.length < N) {
      return this.evenlySpacedDays(available, N);
    }

    return selected;
  }

  private evenlySpacedDays(available: DayOfWeek[], count: number): DayOfWeek[] {
    if (count >= available.length) return available;
    const step = available.length / count;
    const result: DayOfWeek[] = [];
    for (let i = 0; i < count; i++) {
      result.push(available[Math.floor(i * step)]);
    }
    return result;
  }
}
