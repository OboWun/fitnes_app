import type {
  WorkoutSession,
  WorkoutSessionExercise,
  WorkoutSessionSet,
} from '../../entities/index.js';

export const WORKOUT_SESSIONS_REPOSITORY = Symbol(
  'WORKOUT_SESSIONS_REPOSITORY',
);

export interface WorkoutSessionsFilter {
  limit?: number;
  status?: string[];
  sort?: 'id_desc' | 'id_asc';
}

export interface IWorkoutSessionsRepository {
  findByBlockId(blockId: string): Promise<WorkoutSession[]>;
  findByUserId(userId: string, filter?: WorkoutSessionsFilter): Promise<WorkoutSession[]>;
  findById(id: string): Promise<WorkoutSession | undefined>;
  create(
    data: Omit<WorkoutSession, 'id'> & { exercises?: WorkoutSessionExercise[] },
  ): Promise<WorkoutSession>;
  update(
    id: string,
    data: Partial<Omit<WorkoutSession, 'id' | 'userId' | 'blockId'>> & {
      exercises?: WorkoutSessionExercise[];
    },
  ): Promise<WorkoutSession | undefined>;
  delete(id: string): Promise<boolean>;
  findRecentCompletedByUserId(
    userId: string,
    daysBack: number,
  ): Promise<WorkoutSession[]>;

  planSets(sessionId: string, sets: WorkoutSessionSet[]): Promise<void>;
  getSetsBySession(sessionId: string): Promise<WorkoutSessionSet[]>;
  getSetsBySessions(sessionIds: string[]): Promise<Map<string, WorkoutSessionSet[]>>;
  completeSession(
    sessionId: string,
    sets: Array<{
      exerciseSlug: string;
      setNumber: number;
      actualWeightKg?: number;
      actualReps?: number;
      actualDurationSec?: number;
      actualDistanceM?: number;
      actualRpe?: number;
    }>,
  ): Promise<void>;
  findNextPlannedByUserId(userId: string, excludeSessionId?: string): Promise<WorkoutSession | undefined>;
  findStalePlanned(): Promise<WorkoutSession[]>;
  skipSession(sessionId: string, autoSkipped?: boolean): Promise<void>;
  findExerciseHistory(
    userId: string,
    exerciseSlug: string,
    limit?: number,
  ): Promise<WorkoutSessionSet[]>;
}
