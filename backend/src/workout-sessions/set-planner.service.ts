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

const DEFAULT_WEIGHTS_BY_EXPERIENCE: Record<string, number> = {
  beginner: BAR_WEIGHT,
  intermediate: 40,
  advanced: 60,
};

const PROGRESSION_UPPER = 2.5;
const PROGRESSION_LOWER = 5;

const WARMUP_THRESHOLD_KG = 40;

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

    const allSets: WorkoutSessionSet[] = [];

    for (const ex of session.exercises) {
      const exMeta = await this.loadExerciseMeta(ex.exerciseSlug);
      const measurementType = getMeasurementType(exMeta.movementPattern);
      const compound = isCompoundExercise(exMeta.movementPattern);
      const isBodyweight = this.isBodyweightExercise(exMeta.equipments);
      const repsPerSet = this.getRepsPerSet(session);

      if (measurementType === 'duration_distance') {
        allSets.push(
          ...this.planCardioSets(session.id, ex.exerciseSlug, experienceLevel),
        );
      } else {
        const workingWeight = await this.predictWorkingWeight(
          session.userId,
          ex.exerciseSlug,
          experienceLevel,
          bodyweightKg,
          isBodyweight,
          session,
        );

        if (compound && workingWeight > WARMUP_THRESHOLD_KG) {
          allSets.push(
            ...this.planWarmupSets(
              session.id,
              ex.exerciseSlug,
              workingWeight,
              repsPerSet,
            ),
          );
        }

        const startSet = compound && workingWeight > WARMUP_THRESHOLD_KG ? 1 : 1;
        for (let i = 0; i < ex.sets; i++) {
          allSets.push({
            sessionId: session.id,
            exerciseSlug: ex.exerciseSlug,
            setNumber: startSet + i,
            setType: 'working',
            plannedWeightKg: isBodyweight ? bodyweightKg : workingWeight,
            plannedReps: repsPerSet,
          });
        }
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
    isBodyweight: boolean,
    session: WorkoutSession,
  ): Promise<number> {
    const history = await this.sessionsRepo.findExerciseHistory(
      userId,
      exerciseSlug,
      5,
    );

    if (!history.length) {
      return this.getDefaultWeight(experienceLevel, isBodyweight, bodyweightKg);
    }

    const bestSet = this.findBestSet(history);
    if (!bestSet) {
      return this.getDefaultWeight(experienceLevel, isBodyweight, bodyweightKg);
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
    _targetReps: number,
  ): WorkoutSessionSet[] {
    const sets: WorkoutSessionSet[] = [];
    let num = 0;

    sets.push({
      sessionId,
      exerciseSlug,
      setNumber: ++num,
      setType: 'warmup',
      plannedWeightKg: BAR_WEIGHT,
      plannedReps: 15,
    });

    if (workingWeight > WARMUP_THRESHOLD_KG) {
      sets.push({
        sessionId,
        exerciseSlug,
        setNumber: ++num,
        setType: 'warmup',
        plannedWeightKg: Math.round(workingWeight * 0.5),
        plannedReps: 10,
      });

      sets.push({
        sessionId,
        exerciseSlug,
        setNumber: ++num,
        setType: 'warmup',
        plannedWeightKg: Math.round(workingWeight * 0.75),
        plannedReps: 8,
      });
    }

    return sets;
  }

  private planCardioSets(
    sessionId: string,
    exerciseSlug: string,
    _experienceLevel: string,
  ): WorkoutSessionSet[] {
    return [
      {
        sessionId,
        exerciseSlug,
        setNumber: 1,
        setType: 'working',
        plannedDurationSec: 20 * 60,
        plannedDistanceM: 3000,
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
    isBodyweight: boolean,
    bodyweightKg: number,
  ): number {
    if (isBodyweight) return bodyweightKg;
    return DEFAULT_WEIGHTS_BY_EXPERIENCE[experienceLevel] ?? 40;
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
        e === 'no equipment',
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
