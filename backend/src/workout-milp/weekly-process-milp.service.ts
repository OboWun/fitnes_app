import { Inject, Injectable, Logger } from '@nestjs/common';
import { WorkoutMilpService } from './workout-milp.service.js';
import type {
  WorkoutMILPInput,
  WorkoutMILPOutput,
} from './workout-milp.service.js';
import {
  TRAINING_PLANS_REPOSITORY,
  WORKOUT_TEMPLATES_REPOSITORY,
  USERS_REPOSITORY,
} from '../common/repositories/index.js';
import type {
  ITrainingPlansRepository,
  IWorkoutTemplatesRepository,
  IUsersRepository,
} from '../common/repositories/index.js';
import type { DayOfWeek, WorkoutExercise } from '../entities/index.js';

type SessionSlot = 'full_body' | 'upper' | 'lower' | 'push' | 'pull' | 'legs';

interface SplitStrategy {
  name: string;
  sessions: SessionSlot[];
}

interface SessionMuscleFocus {
  primary: string[];
  secondary: string[];
}

const LAMBDA = 0.345;

const DAY_ORDER: DayOfWeek[] = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

const SESSION_MUSCLE_FOCUS: Record<SessionSlot, SessionMuscleFocus> = {
  full_body: {
    primary: ['chest', 'back', 'legs'],
    secondary: ['shoulders', 'arms', 'core'],
  },
  upper: {
    primary: ['chest', 'back'],
    secondary: ['shoulders', 'arms'],
  },
  lower: {
    primary: ['quads', 'hamstrings', 'glutes'],
    secondary: ['calves', 'core'],
  },
  push: {
    primary: ['chest', 'shoulders'],
    secondary: ['triceps'],
  },
  pull: {
    primary: ['back', 'lats'],
    secondary: ['biceps', 'rear_delts'],
  },
  legs: {
    primary: ['quads', 'hamstrings', 'glutes'],
    secondary: ['calves', 'adductors'],
  },
};

const SPLIT_STRATEGIES: Record<string, SplitStrategy> = {
  '2-beginner': { name: 'full_body', sessions: ['full_body', 'full_body'] },
  '2-intermediate': { name: 'upper_lower', sessions: ['upper', 'lower'] },
  '2-advanced': { name: 'upper_lower', sessions: ['upper', 'lower'] },
  '3-beginner': {
    name: 'full_body',
    sessions: ['full_body', 'full_body', 'full_body'],
  },
  '3-intermediate': { name: 'ppl', sessions: ['push', 'pull', 'legs'] },
  '3-advanced': { name: 'ppl', sessions: ['push', 'pull', 'legs'] },
  '4-beginner': {
    name: 'upper_lower',
    sessions: ['upper', 'lower', 'full_body', 'full_body'],
  },
  '4-intermediate': {
    name: 'upper_lower',
    sessions: ['upper', 'lower', 'upper', 'lower'],
  },
  '4-advanced': {
    name: 'ppl_plus',
    sessions: ['push', 'pull', 'legs', 'full_body'],
  },
  '5-intermediate': {
    name: 'ppl_ul',
    sessions: ['push', 'pull', 'legs', 'upper', 'lower'],
  },
  '5-advanced': {
    name: 'ppl_pp',
    sessions: ['push', 'pull', 'legs', 'push', 'pull'],
  },
  '6-intermediate': {
    name: 'ppl_ppl',
    sessions: ['push', 'pull', 'legs', 'push', 'pull', 'legs'],
  },
  '6-advanced': {
    name: 'ppl_ppl',
    sessions: ['push', 'pull', 'legs', 'push', 'pull', 'legs'],
  },
};

const GOALS_PREFER_FULL_BODY = new Set([
  'weight_loss',
  'endurance',
  'rehab',
  'mobility',
]);
const GOALS_FORCE_FULL_BODY = new Set(['rehab', 'mobility']);

const OPTIMAL_FREQUENCY: Record<string, Record<string, number>> = {
  beginner: { default: 3 },
  intermediate: { strength: 4, hypertrophy: 4, glute_growth: 4, recomposition: 3, default: 3 },
  advanced: { strength: 5, hypertrophy: 5, glute_growth: 5, recomposition: 4, default: 4 },
};

const ALL_DAYS: DayOfWeek[] = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

const SPLIT_TYPE_SESSIONS: Record<string, SessionSlot[]> = {
  full_body: ['full_body', 'full_body', 'full_body'],
  upper_lower: ['upper', 'lower', 'upper', 'lower'],
  ppl: ['push', 'pull', 'legs'],
};

const ACTIVITY_VOLUME_SCALE: Record<string, number> = {
  sedentary: 0.7,
  light: 0.85,
  moderate: 1.0,
  active: 1.1,
};

const DEFAULT_SESSION_DURATION: Record<string, Record<string, number>> = {
  beginner: { default: 45 },
  intermediate: { strength: 60, hypertrophy: 60, glute_growth: 60, recomposition: 60, default: 45 },
  advanced: { strength: 75, hypertrophy: 75, glute_growth: 75, recomposition: 75, default: 60 },
};

const MUSCLE_GROUP_EXPANSION: Record<string, string[]> = {
  chest: ['chest'],
  back: [
    'lats',
    'upper_back',
    'traps',
    'rhomboids',
    'rear_delts',
    'lower_back',
  ],
  legs: ['quads', 'hamstrings', 'glutes', 'calves', 'adductors', 'abductors'],
  shoulders: ['front_delts', 'side_delts', 'rear_delts', 'shoulders'],
  arms: ['biceps', 'triceps', 'forearms'],
  core: ['abs', 'obliques', 'lower_back'],
  quads: ['quads'],
  hamstrings: ['hamstrings'],
  glutes: ['glutes'],
  calves: ['calves'],
  adductors: ['adductors'],
  lats: ['lats'],
  rear_delts: ['rear_delts'],
  triceps: ['triceps'],
  biceps: ['biceps'],
};

const MUSCLE_WEEKLY_VOLUME_TARGETS: Record<
  string,
  { min: number; max: number }
> = {
  quads: { min: 12, max: 18 },
  glutes: { min: 14, max: 20 },
  hamstrings: { min: 10, max: 14 },
  lats: { min: 12, max: 16 },
  upper_back: { min: 8, max: 12 },
  traps: { min: 6, max: 10 },
  chest: { min: 12, max: 16 },
  shoulders: { min: 8, max: 12 },
  side_delts: { min: 6, max: 10 },
  front_delts: { min: 4, max: 8 },
  rear_delts: { min: 6, max: 10 },
  biceps: { min: 8, max: 12 },
  triceps: { min: 10, max: 14 },
  forearms: { min: 4, max: 8 },
  calves: { min: 8, max: 12 },
  abs: { min: 6, max: 10 },
  obliques: { min: 4, max: 6 },
  lower_back: { min: 4, max: 8 },
  adductors: { min: 4, max: 8 },
};

const EXPERIENCE_WEEKLY_SCALE: Record<string, number> = {
  beginner: 0.6,
  intermediate: 1.0,
  advanced: 1.4,
};

const SETS_BY_ROLE: Record<string, { compound: number; isolation: number }> = {
  beginner: { compound: 3, isolation: 2 },
  intermediate: { compound: 4, isolation: 3 },
  advanced: { compound: 4, isolation: 3 },
};

const SETS_GOAL_MODIFIER: Record<
  string,
  { compound: number; isolation: number }
> = {
  strength: { compound: 1, isolation: 0 },
  hypertrophy: { compound: 0, isolation: 1 },
  endurance: { compound: 0, isolation: 1 },
  weight_loss: { compound: 0, isolation: 0 },
  general_health: { compound: 0, isolation: 0 },
  rehab: { compound: -1, isolation: 0 },
  mobility: { compound: -1, isolation: 0 },
};

const GOAL_REST_SEC: Record<string, number> = {
  strength: 180,
  hypertrophy: 90,
  endurance: 45,
  weight_loss: 60,
  general_health: 90,
  rehab: 120,
  mobility: 45,
};

export interface WeeklyProcessInput {
  userId: string;
  availableDays: DayOfWeek[] | null;
  trainingCountPerWeek: number | null;
  sessionDurationMin: number | null;
  experienceLevel: string;
  goal: string;
  gender: string;
  availableEquipment: string[];
  phase?: string;
  userContraindications?: string[];
  splitType?: string;
  activityLevel?: string;
  cardioPreference?: string;
  primaryLifts?: string[];
  enduranceType?: string;
  targetWeightKg?: number;
  age?: number;
  heightCm?: number;
  weightKg?: number;
}

export interface WeeklyProcessOutput {
  planId: string;
  splitName: string;
  sessions: {
    dayOfWeek: DayOfWeek;
    sessionType: SessionSlot;
    exercises: {
      exerciseSlug: string;
      sets: number;
      repsPerSet: number;
      order: number;
      restBetweenSetsSec?: number;
      restAfterExerciseSec?: number;
    }[];
    loadByMuscle: Record<string, number>;
    totalTimeSec: number;
    usedFallback?: boolean;
    repsPerSet: number;
  }[];
  totalWeeklyLoad: number;
  weeklyVolumeByMuscle: Record<string, number>;
}

@Injectable()
export class WeeklyProcessMilpService {
  private readonly logger = new Logger(WeeklyProcessMilpService.name);

  constructor(
    private readonly workoutMilpService: WorkoutMilpService,
    @Inject(TRAINING_PLANS_REPOSITORY)
    private readonly plansRepository: ITrainingPlansRepository,
    @Inject(WORKOUT_TEMPLATES_REPOSITORY)
    private readonly templatesRepository: IWorkoutTemplatesRepository,
    @Inject(USERS_REPOSITORY)
    private readonly usersRepository: IUsersRepository,
  ) {}

  async generateWeeklyPlan(
    input: WeeklyProcessInput,
  ): Promise<WeeklyProcessOutput> {
    this.logger.log(`Generating weekly plan for user ${input.userId}, goal=${input.goal}, level=${input.experienceLevel}`);

    const level = input.experienceLevel;
    const goal = input.goal;

    const trainingCountPerWeek = this.resolveFrequency(
      input.trainingCountPerWeek,
      level,
      goal,
    );

    const sessionDurationMin = this.resolveSessionDuration(
      input.sessionDurationMin,
      level,
      goal,
    );

    const availableDays = input.availableDays?.length
      ? input.availableDays
      : [...ALL_DAYS];

    const strategy = input.splitType && input.splitType !== 'auto'
      ? this.buildStrategyFromSplitType(input.splitType, trainingCountPerWeek, goal, level)
      : this.selectSplit(trainingCountPerWeek, level, goal);

    const assignedDays = this.assignDays(
      availableDays,
      strategy.sessions.length,
    );

    const weeklyBudget = this.computeWeeklyVolumeBudget(level, input.activityLevel, input.age);
    const sessionsPerMuscle = this.computeSessionsPerMuscle(strategy.sessions);

    const accumulatedVolume: Record<string, number> = {};
    const fatigueByMuscle: Record<string, number> = {};
    const usedExercises: string[] = [];
    const sessions: WeeklyProcessOutput['sessions'] = [];
    let totalWeeklyLoad = 0;

    const compoundSets = this.getCompoundSets(
      input.experienceLevel,
      input.goal,
    );
    const isolationSets = this.getIsolationSets(
      input.experienceLevel,
      input.goal,
    );
    const restSec = GOAL_REST_SEC[input.goal] ?? 90;

    for (let i = 0; i < strategy.sessions.length; i++) {
      const slot = strategy.sessions[i];
      const day = assignedDays[i];

      let restDaysSinceLast = 1;
      if (i > 0) {
        const prevIdx = DAY_ORDER.indexOf(assignedDays[i - 1]);
        const currIdx = DAY_ORDER.indexOf(day);
        restDaysSinceLast = currIdx - prevIdx;
      }

      for (const muscle of Object.keys(fatigueByMuscle)) {
        fatigueByMuscle[muscle] *= Math.exp(-LAMBDA * restDaysSinceLast);
      }

      const sessionParams = this.deriveSessionParams(
        slot,
        weeklyBudget,
        sessionsPerMuscle,
        accumulatedVolume,
        sessionDurationMin,
        compoundSets,
        isolationSets,
        restSec,
        input.gender,
        goal,
      );

      const workoutInput: WorkoutMILPInput = {
        userId: input.userId,
        sessionDurationMin,
        experienceLevel: input.experienceLevel,
        goal: input.goal,
        focusMuscles: sessionParams.focusMuscles,
        specificMuscles: sessionParams.specificMuscles,
        exerciseCount: sessionParams.exerciseCount,
        compoundSets,
        isolationSets,
        restBetweenSetsSec: restSec,
        availableEquipment: input.availableEquipment,
        phase: input.phase,
        fatigueByMuscle: { ...fatigueByMuscle },
        usedExercises: [...usedExercises],
        mandatoryMuscles: sessionParams.mandatoryMuscles,
        userContraindications: input.userContraindications ?? [],
        gender: input.gender,
        weeklyVolumeByMuscle: { ...accumulatedVolume },
        activityLevel: input.activityLevel,
        cardioPreference: input.cardioPreference,
        primaryLifts: input.primaryLifts,
        enduranceType: input.enduranceType,
        age: input.age,
        heightCm: input.heightCm,
        weightKg: input.weightKg,
      };

      const result =
        await this.workoutMilpService.generateWorkout(workoutInput);

      this.logger.log(`Session ${i + 1}/${strategy.sessions.length}: ${slot} on ${day}, ${result.exercises.length} exercises, fallback=${result.usedFallback}`);

      for (const [muscle, load] of Object.entries(result.totalLoadByMuscle)) {
        fatigueByMuscle[muscle] = (fatigueByMuscle[muscle] ?? 0) + load;
      }

      for (const ex of result.exercises) {
        if (!usedExercises.includes(ex.exerciseSlug)) {
          usedExercises.push(ex.exerciseSlug);
        }
      }

      this.accumulateVolume(accumulatedVolume, result);

      const sessionLoad = Object.values(result.totalLoadByMuscle).reduce(
        (s, v) => s + v,
        0,
      );
      totalWeeklyLoad += sessionLoad;

      const repsPerSet = result.exercises[0]?.repsPerSet ?? 10;
      sessions.push({
        dayOfWeek: day,
        sessionType: slot,
        exercises: result.exercises,
        loadByMuscle: result.totalLoadByMuscle,
        totalTimeSec: result.totalTimeSec,
        usedFallback: result.usedFallback,
        repsPerSet,
      });
    }

    const scheduleEntries: { dayOfWeek: string; templateId: string; name: string; sortOrder: number }[] = [];

    for (const session of sessions) {
      const exercises: WorkoutExercise[] = session.exercises.map((e) => ({
        exerciseSlug: e.exerciseSlug,
        sets: e.sets,
        reps: e.repsPerSet,
        order: e.order,
        restBetweenSets: e.restBetweenSetsSec,
        restAfterExercise: e.restAfterExerciseSec,
      }));

      const template = await this.templatesRepository.create({
        userId: input.userId,
        name: `${strategy.name} — ${session.sessionType} (${session.dayOfWeek})`,
        description: `Auto-generated ${session.sessionType} session`,
        exercises,
        metadata: {
          sessionDurationMin,
          trainingGoal: input.goal,
          blockType: session.sessionType,
        },
      });

      scheduleEntries.push({
        dayOfWeek: session.dayOfWeek,
        templateId: template.id,
        name: session.sessionType,
        sortOrder: scheduleEntries.length,
      });

      this.logger.log(`Created template ${template.id} for ${session.dayOfWeek} (${session.sessionType}), ${exercises.length} exercises`);
    }

    const plan = await this.plansRepository.create({
      userId: input.userId,
      name: `MILP ${strategy.name} ${new Date().toISOString().slice(0, 10)}`,
      isActive: false,
      source: 'milp',
      schedule: scheduleEntries.map((s) => ({
        dayOfWeek: s.dayOfWeek as DayOfWeek,
        workoutTemplateId: s.templateId,
        name: s.name,
        sortOrder: s.sortOrder,
      })),
    });

    this.logger.log(`Created plan ${plan.id} (${strategy.name}) with ${scheduleEntries.length} scheduled days for user ${input.userId}`);

    return {
      planId: plan.id,
      splitName: strategy.name,
      sessions,
      totalWeeklyLoad,
      weeklyVolumeByMuscle: { ...accumulatedVolume },
    };
  }

  private selectSplit(
    count: number,
    level: string,
    goal: string,
  ): SplitStrategy {
    let effectiveCount = count;

    if (level === 'beginner' && count > 3) {
      effectiveCount = 3;
    }

    const key = `${effectiveCount}-${level}`;
    let strategy =
      SPLIT_STRATEGIES[key] ??
      SPLIT_STRATEGIES[`${effectiveCount}-intermediate`] ??
      SPLIT_STRATEGIES['3-intermediate'];

    if (GOALS_FORCE_FULL_BODY.has(goal)) {
      strategy = {
        name: 'full_body',
        sessions: Array(effectiveCount).fill('full_body') as SessionSlot[],
      };
    } else if (
      GOALS_PREFER_FULL_BODY.has(goal) &&
      strategy.sessions.length >= 3
    ) {
      const modified = [...strategy.sessions];
      const halfLen = Math.ceil(modified.length / 2);
      for (let i = 1; i < modified.length && i < halfLen; i += 2) {
        modified[i] = 'full_body';
      }
      strategy = {
        name: strategy.name + '_fb',
        sessions: modified,
      };
    }

    return strategy;
  }

  private resolveFrequency(
    count: number | null,
    level: string,
    goal: string,
  ): number {
    if (count != null) return count;
    const levelFreqs = OPTIMAL_FREQUENCY[level] ?? OPTIMAL_FREQUENCY.intermediate;
    return levelFreqs[goal] ?? levelFreqs.default ?? 3;
  }

  private resolveSessionDuration(
    duration: number | null,
    level: string,
    goal: string,
  ): number {
    if (duration != null) return duration;
    const levelDurations = DEFAULT_SESSION_DURATION[level] ?? DEFAULT_SESSION_DURATION.intermediate;
    return levelDurations[goal] ?? levelDurations.default ?? 60;
  }

  private buildStrategyFromSplitType(
    splitType: string,
    count: number,
    goal: string,
    level: string,
  ): SplitStrategy {
    const baseSessions = SPLIT_TYPE_SESSIONS[splitType] ?? SPLIT_TYPE_SESSIONS.full_body;
    let sessions = [...baseSessions];

    if (GOALS_FORCE_FULL_BODY.has(goal)) {
      sessions = Array(count).fill('full_body') as SessionSlot[];
      return { name: 'full_body', sessions };
    }

    while (sessions.length < count) {
      sessions = [...sessions, ...baseSessions];
    }
    sessions = sessions.slice(0, count);

    if (level === 'beginner' && count > 3) {
      sessions = sessions.slice(0, 3);
    }

    return { name: splitType, sessions };
  }

  private assignDays(
    availableDays: DayOfWeek[],
    sessionCount: number,
  ): DayOfWeek[] {
    const sorted = availableDays
      .filter((d) => DAY_ORDER.includes(d))
      .sort((a, b) => DAY_ORDER.indexOf(a) - DAY_ORDER.indexOf(b));

    if (sorted.length < sessionCount) {
      return this.evenlySpacedDays(sorted, sessionCount);
    }

    if (sorted.length === sessionCount) {
      return sorted;
    }

    return this.bestSpacedSubset(sorted, sessionCount);
  }

  private evenlySpacedDays(available: DayOfWeek[], count: number): DayOfWeek[] {
    if (available.length === 0) return [];
    if (count <= available.length) {
      if (count >= available.length) return available;
      const step = available.length / count;
      const result: DayOfWeek[] = [];
      for (let i = 0; i < count; i++) {
        result.push(available[Math.floor(i * step)]);
      }
      return result;
    }

    const result: DayOfWeek[] = [];
    for (let i = 0; i < count; i++) {
      result.push(available[i % available.length]);
    }
    return result;
  }

  private bestSpacedSubset(available: DayOfWeek[], count: number): DayOfWeek[] {
    if (count >= available.length) return available;
    if (count <= 1) return available.slice(0, count);

    const n = available.length;
    const indices = Array.from({ length: n }, (_, i) => i);

    const combinations = this.generateCombinations(indices, count);

    let bestCombo = combinations[0];
    let bestScore = -Infinity;

    for (const combo of combinations) {
      let score = 0;
      for (let i = 1; i < combo.length; i++) {
        const gap =
          DAY_ORDER.indexOf(available[combo[i]]) -
          DAY_ORDER.indexOf(available[combo[i - 1]]);
        score += gap * gap;
      }
      if (score > bestScore) {
        bestScore = score;
        bestCombo = combo;
      }
    }

    return bestCombo.map((i) => available[i]);
  }

  private generateCombinations(arr: number[], k: number): number[][] {
    if (k === 0) return [[]];
    if (arr.length < k) return [];
    const [first, ...rest] = arr;
    const withFirst = this.generateCombinations(rest, k - 1).map((c) => [
      first,
      ...c,
    ]);
    const withoutFirst = this.generateCombinations(rest, k);
    return [...withFirst, ...withoutFirst];
  }

  private computeWeeklyVolumeBudget(level: string, activityLevel?: string, age?: number): Record<string, number> {
    let scale = EXPERIENCE_WEEKLY_SCALE[level] ?? 1.0;
    if (activityLevel) {
      scale *= ACTIVITY_VOLUME_SCALE[activityLevel] ?? 1.0;
    }
    if (age) {
      const ageBucket = age < 25 ? 1.1 : age <= 40 ? 1.0 : age <= 55 ? 0.85 : 0.7;
      scale *= ageBucket;
    }
    const budget: Record<string, number> = {};
    for (const [muscle, target] of Object.entries(
      MUSCLE_WEEKLY_VOLUME_TARGETS,
    )) {
      budget[muscle] = Math.round(target.min * scale);
    }
    return budget;
  }

  private computeSessionsPerMuscle(
    sessions: SessionSlot[],
  ): Record<string, number> {
    const counts: Record<string, number> = {};
    for (const slot of sessions) {
      const focus = SESSION_MUSCLE_FOCUS[slot];
      const groups = [...focus.primary, ...focus.secondary];
      for (const group of groups) {
        const muscles = MUSCLE_GROUP_EXPANSION[group] ?? [group];
        for (const muscle of muscles) {
          counts[muscle] = (counts[muscle] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  private deriveSessionParams(
    slot: SessionSlot,
    weeklyBudget: Record<string, number>,
    sessionsPerMuscle: Record<string, number>,
    accumulatedVolume: Record<string, number>,
    sessionDurationMin: number,
    compoundSets: number,
    isolationSets: number,
    restSec: number,
    gender: string,
    goal: string,
  ): {
    focusMuscles: string[];
    specificMuscles: string[];
    exerciseCount: number;
    mandatoryMuscles: string[];
  } {
    const focus = SESSION_MUSCLE_FOCUS[slot];
    const focusMuscles = [...focus.primary];
    const specificMuscles = [...focus.secondary];

    const mandatoryMuscles: string[] = [];
    let totalExercises = 0;

    for (const group of focus.primary) {
      const muscles = MUSCLE_GROUP_EXPANSION[group] ?? [group];

      let totalTargetSets = 0;
      for (const muscle of muscles) {
        const budget = weeklyBudget[muscle] ?? 0;
        const sessions = sessionsPerMuscle[muscle] ?? 1;
        const targetPerSession = Math.max(2, Math.round(budget / sessions));

        const done = accumulatedVolume[muscle] ?? 0;
        const remaining = Math.max(0, budget - done);

        if (remaining > 0) {
          totalTargetSets += Math.min(targetPerSession, remaining);
          mandatoryMuscles.push(...muscles);
        }
      }

      const avgSetsPerExercise = (compoundSets + isolationSets) / 2;
      const count = Math.max(
        1,
        Math.round(totalTargetSets / avgSetsPerExercise),
      );
      totalExercises += count;
    }

    totalExercises += focus.secondary.length;

    const avgSets = (compoundSets + isolationSets) / 2;
    const estTimePerExercise = 40 * avgSets + restSec * (avgSets - 1);
    const maxByTime = Math.floor(
      (sessionDurationMin * 60) / estTimePerExercise,
    );
    totalExercises = Math.min(totalExercises, Math.max(2, maxByTime));

    if (gender === 'female' && ['lower', 'legs', 'full_body'].includes(slot)) {
      const femaleExtra = ['glutes', 'hamstrings'];
      for (const m of femaleExtra) {
        if (!mandatoryMuscles.includes(m)) {
          mandatoryMuscles.push(m);
        }
      }
    }

    if (goal === 'glute_growth') {
      const gluteExtra = ['glutes', 'hamstrings', 'adductors'];
      if (['lower', 'legs', 'full_body'].includes(slot)) {
        gluteExtra.push('abductors');
      }
      for (const m of gluteExtra) {
        if (!mandatoryMuscles.includes(m)) {
          mandatoryMuscles.push(m);
        }
      }
      if (!focusMuscles.includes('legs')) {
        focusMuscles.push('legs');
      }
    }

    return {
      focusMuscles,
      specificMuscles,
      exerciseCount: totalExercises,
      mandatoryMuscles: [...new Set(mandatoryMuscles)],
    };
  }

  private accumulateVolume(
    acc: Record<string, number>,
    result: WorkoutMILPOutput,
  ): void {
    for (const ex of result.exercises) {
      const sets = ex.sets;
      const volumeKey = ex.exerciseSlug;
      acc[volumeKey] = (acc[volumeKey] ?? 0) + sets;
    }
  }

  private getCompoundSets(level: string, goal: string): number {
    const roleDefaults = SETS_BY_ROLE[level] ?? SETS_BY_ROLE.intermediate;
    const goalMod = SETS_GOAL_MODIFIER[goal] ?? { compound: 0, isolation: 0 };
    return Math.max(2, roleDefaults.compound + goalMod.compound);
  }

  private getIsolationSets(level: string, goal: string): number {
    const roleDefaults = SETS_BY_ROLE[level] ?? SETS_BY_ROLE.intermediate;
    const goalMod = SETS_GOAL_MODIFIER[goal] ?? { compound: 0, isolation: 0 };
    return Math.max(2, roleDefaults.isolation + goalMod.isolation);
  }
}
