import { Injectable, Logger } from '@nestjs/common';
import { Inject } from '@nestjs/common';
import {
  EXERCISES_REPOSITORY,
  USERS_REPOSITORY,
  WORKOUT_SESSIONS_REPOSITORY,
  type IExercisesRepository,
  type IUsersRepository,
  type IWorkoutSessionsRepository,
} from '../common/repositories/index.js';
import type {
  WorkoutSession,
  WorkoutSessionSet,
} from '../entities/index.js';
import {
  isCompoundExercise,
  getMeasurementType,
} from '../entities/workout-session-set.entity.js';

const BAR_WEIGHT = 20;

const EXPERIENCE_MULTIPLIER: Record<string, number> = {
  beginner: 0.6,
  intermediate: 1.0,
  advanced: 1.4,
};

const DEFAULT_WEIGHT_BY_PATTERN: Record<string, number> = {
  squat: 40,
  hinge: 40,
  press: 30,
  row: 30,
  pull: 30,
  lunge: 20,
  curl: 15,
  extension: 15,
  adduction: 15,
  abduction: 15,
  flexion: 0,
  carry: 16,
  cardio: 0,
  locomotion: 0,
};

const FALLBACK_DEFAULT_WEIGHT = 20;

const PROGRESSION_UPPER = 2.5;
const PROGRESSION_LOWER = 5;

const WARMUP_THRESHOLD_KG = 30;

interface ExerciseMeta {
  movementPattern?: string;
  exerciseType?: string;
  equipments?: string[];
}

@Injectable()
export class SetPlannerService {
  private readonly logger = new Logger(SetPlannerService.name);

  constructor(
    @Inject(EXERCISES_REPOSITORY)
    private readonly exercisesRepo: IExercisesRepository,
    @Inject(USERS_REPOSITORY)
    private readonly usersRepo: IUsersRepository,
    @Inject(WORKOUT_SESSIONS_REPOSITORY)
    private readonly sessionsRepo: IWorkoutSessionsRepository,
  ) {}

  async planSetsForSession(session: WorkoutSession): Promise<void> {
    if (!session.exercises?.length) return;

    const user = await this.usersRepo.findById(session.userId);
    const bodyweightKg = user?.weight ?? 70;
    const experienceLevel =
      (user?.metadata as Record<string, unknown>)?.experienceLevel as string ??
      'intermediate';
    const userBmi = user?.weight && user?.height && user.height > 0
      ? user.weight / ((user.height / 100) ** 2)
      : null;

    const allSets: WorkoutSessionSet[] = [];

    for (const ex of session.exercises) {
      const exMeta = await this.loadExerciseMeta(ex.exerciseSlug);
      const measurementType = getMeasurementType(exMeta.movementPattern, exMeta.exerciseType);
      const compound = isCompoundExercise(exMeta.movementPattern);
      const isBodyweight = this.isBodyweightExercise(exMeta.equipments);
      const repsPerSet = this.getRepsPerSet(session);

      if (measurementType === 'duration_distance') {
        allSets.push(
          ...this.planCardioSets(session.id, ex.exerciseSlug, experienceLevel),
        );
      } else if (isBodyweight) {
        allSets.push(
          ...this.planBodyweightSets(
            session.id,
            ex.exerciseSlug,
            ex.sets,
            repsPerSet,
            bodyweightKg,
          ),
        );
      } else {
        const workingWeight = await this.predictWorkingWeight(
          session.userId,
          ex.exerciseSlug,
          experienceLevel,
          bodyweightKg,
          session,
          userBmi,
          exMeta,
        );

        const warmupSets = compound && workingWeight > WARMUP_THRESHOLD_KG
          ? this.planWarmupSets(session.id, ex.exerciseSlug, workingWeight)
          : [];

        const workingSets: WorkoutSessionSet[] = [];
        for (let i = 0; i < ex.sets; i++) {
          workingSets.push({
            sessionId: session.id,
            exerciseSlug: ex.exerciseSlug,
            setNumber: warmupSets.length + i + 1,
            setType: 'working',
            plannedWeightKg: workingWeight,
            plannedReps: repsPerSet,
          });
        }

        allSets.push(...warmupSets, ...workingSets);
      }
    }

    if (allSets.length) {
      await this.sessionsRepo.planSets(session.id, allSets);
      this.logger.log(
        `Planned ${allSets.length} sets for session ${session.id}`,
      );
    }
  }

  private async predictWorkingWeight(
    userId: string,
    exerciseSlug: string,
    experienceLevel: string,
    bodyweightKg: number,
    session: WorkoutSession,
    bmi?: number | null,
    exMeta?: ExerciseMeta,
  ): Promise<number> {
    const history = await this.sessionsRepo.findExerciseHistory(
      userId,
      exerciseSlug,
      5,
    );

    if (!history.length) {
      return this.getDefaultWeight(experienceLevel, bodyweightKg, bmi, exMeta);
    }

    const bestSet = this.findBestSet(history);
    if (!bestSet) {
      return this.getDefaultWeight(experienceLevel, bodyweightKg, bmi, exMeta);
    }

    let workingWeight = bestSet.actualWeightKg ?? bestSet.plannedWeightKg ?? BAR_WEIGHT;

    const allRpeLow = history.every(
      (s) => (s.actualRpe ?? 5) <= 7,
    );
    const anyRpeHigh = history.some(
      (s) => (s.actualRpe ?? 5) >= 9,
    );

    if (allRpeLow && !anyRpeHigh) {
      const progression = this.isLowerBody(exerciseSlug)
        ? PROGRESSION_LOWER
        : PROGRESSION_UPPER;
      workingWeight += progression;
    } else if (anyRpeHigh) {
      workingWeight = Math.max(
        workingWeight - (this.isLowerBody(exerciseSlug) ? 2.5 : 1.25),
        BAR_WEIGHT,
      );
    }

    workingWeight = await this.applyFatigueAdjustment(workingWeight, userId, session);

    return workingWeight;
  }

  private async applyFatigueAdjustment(
    weight: number,
    _userId: string,
    _session: WorkoutSession,
  ): Promise<number> {
    return weight;
  }

  private planWarmupSets(
    sessionId: string,
    exerciseSlug: string,
    workingWeight: number,
  ): WorkoutSessionSet[] {
    const sets: WorkoutSessionSet[] = [];

    sets.push({
      sessionId,
      exerciseSlug,
      setNumber: 1,
      setType: 'warmup',
      plannedWeightKg: BAR_WEIGHT,
      plannedReps: 15,
    });

    if (workingWeight > WARMUP_THRESHOLD_KG) {
      sets.push({
        sessionId,
        exerciseSlug,
        setNumber: 2,
        setType: 'warmup',
        plannedWeightKg: Math.round(workingWeight * 0.5),
        plannedReps: 10,
      });

      sets.push({
        sessionId,
        exerciseSlug,
        setNumber: 3,
        setType: 'warmup',
        plannedWeightKg: Math.round(workingWeight * 0.75),
        plannedReps: 8,
      });
    }

    return sets;
  }

  private planBodyweightSets(
    sessionId: string,
    exerciseSlug: string,
    totalSets: number,
    repsPerSet: number,
    bodyweightKg: number,
  ): WorkoutSessionSet[] {
    const sets: WorkoutSessionSet[] = [];
    for (let i = 0; i < totalSets; i++) {
      sets.push({
        sessionId,
        exerciseSlug,
        setNumber: i + 1,
        setType: 'working',
        plannedWeightKg: bodyweightKg,
        plannedReps: repsPerSet,
      });
    }
    return sets;
  }

  private planCardioSets(
    sessionId: string,
    exerciseSlug: string,
    experienceLevel: string,
  ): WorkoutSessionSet[] {
    const durationByLevel: Record<string, number> = {
      beginner: 15 * 60,
      intermediate: 20 * 60,
      advanced: 30 * 60,
    };
    const distanceByLevel: Record<string, number> = {
      beginner: 2000,
      intermediate: 3000,
      advanced: 5000,
    };
    return [
      {
        sessionId,
        exerciseSlug,
        setNumber: 1,
        setType: 'working',
        plannedDurationSec: durationByLevel[experienceLevel] ?? 20 * 60,
        plannedDistanceM: distanceByLevel[experienceLevel] ?? 3000,
      },
    ];
  }

  private findBestSet(
    history: WorkoutSessionSet[],
  ): WorkoutSessionSet | undefined {
    let best: WorkoutSessionSet | undefined;
    let bestE1rm = 0;
    for (const s of history) {
      const w = s.actualWeightKg ?? 0;
      const r = s.actualReps ?? 0;
      if (w <= 0 || r <= 0) continue;
      const e1rm = w * (1 + r / 30);
      if (e1rm > bestE1rm) {
        bestE1rm = e1rm;
        best = s;
      }
    }
    return best;
  }

  private getDefaultWeight(
    experienceLevel: string,
    bodyweightKg: number,
    bmi?: number | null,
    exMeta?: ExerciseMeta,
  ): number {
    const pattern = exMeta?.movementPattern ?? '';
    let base = DEFAULT_WEIGHT_BY_PATTERN[pattern] ?? FALLBACK_DEFAULT_WEIGHT;

    if (base === 0) return bodyweightKg;

    const multiplier = EXPERIENCE_MULTIPLIER[experienceLevel] ?? 1.0;
    base = Math.round(base * multiplier);

    if (bmi && bmi > 30) base = Math.round(base * 1.15);
    if (bmi && bmi < 18.5) base = Math.round(base * 0.85);

    return base;
  }

  private getRepsPerSet(session: WorkoutSession): number {
    return session.metadata?.repsPerSet ?? 10;
  }

  private isLowerBody(exerciseSlug: string): boolean {
    const lowerKeywords = [
      'squat',
      'leg',
      'deadlift',
      'lunge',
      'calf',
      'glute',
      'hamstring',
      'thigh',
      'hip',
      'adduction',
      'abduction',
    ];
    return lowerKeywords.some((k) => exerciseSlug.includes(k));
  }

  private isBodyweightExercise(equipments?: string[]): boolean {
    if (!equipments?.length) return false;
    return equipments.every(
      (e) =>
        e === 'body weight' ||
        e === 'bodyweight' ||
        e === 'body-weight' ||
        e === 'no equipment' ||
        e === 'собственный вес',
    );
  }

  private async loadExerciseMeta(slug: string): Promise<ExerciseMeta> {
    try {
      const ex = await this.exercisesRepo.findBySlug(slug);
      if (!ex) return {};
      return {
        movementPattern: ex.movementPattern,
        exerciseType: ex.exerciseType,
        equipments: ex.equipments,
      };
    } catch {
      return {};
    }
  }
}
