import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type {
  WorkoutSession,
  WorkoutSessionMetadata,
  WorkoutSessionExercise,
  WorkoutSessionSet,
} from '../entities/index.js';
import type {
  IWorkoutSessionsRepository,
  WorkoutSessionsFilter,
} from '../common/repositories/index.js';

interface WorkoutSessionRow {
  id: string;
  plan_session_id: string;
  user_id: string;
  day_of_week: string;
  time: string | null;
  week_number: number | null;
  status: string | null;
  metadata: WorkoutSessionMetadata | null;
}

interface SessionExerciseRow {
  exercise_slug: string;
  sets: number;
  ordering: number;
  metadata: Record<string, unknown> | null;
}

interface SetRow {
  session_id: string;
  exercise_slug: string;
  set_number: number;
  set_type: string;
  planned_weight_kg: number | null;
  planned_reps: number | null;
  planned_duration_sec: number | null;
  planned_distance_m: number | null;
  actual_weight_kg: number | null;
  actual_reps: number | null;
  actual_duration_sec: number | null;
  actual_distance_m: number | null;
  actual_rpe: number | null;
  completed_at: Date | null;
}

function toSet(r: SetRow): WorkoutSessionSet {
  return {
    sessionId: r.session_id,
    exerciseSlug: r.exercise_slug,
    setNumber: r.set_number,
    setType: r.set_type as WorkoutSessionSet['setType'],
    plannedWeightKg: r.planned_weight_kg != null ? Number(r.planned_weight_kg) : undefined,
    plannedReps: r.planned_reps != null ? Number(r.planned_reps) : undefined,
    plannedDurationSec: r.planned_duration_sec != null ? Number(r.planned_duration_sec) : undefined,
    plannedDistanceM: r.planned_distance_m != null ? Number(r.planned_distance_m) : undefined,
    actualWeightKg: r.actual_weight_kg != null ? Number(r.actual_weight_kg) : undefined,
    actualReps: r.actual_reps != null ? Number(r.actual_reps) : undefined,
    actualDurationSec: r.actual_duration_sec != null ? Number(r.actual_duration_sec) : undefined,
    actualDistanceM: r.actual_distance_m != null ? Number(r.actual_distance_m) : undefined,
    actualRpe: r.actual_rpe != null ? Number(r.actual_rpe) : undefined,
    completedAt: r.completed_at ?? undefined,
  };
}

function toSession(
  row: WorkoutSessionRow,
  exercises: WorkoutSessionExercise[] = [],
): WorkoutSession {
  return {
    id: row.id,
    planSessionId: row.plan_session_id,
    userId: row.user_id,
    dayOfWeek: row.day_of_week as WorkoutSession['dayOfWeek'],
    time: row.time ?? undefined,
    weekNumber: row.week_number ?? undefined,
    status: (row.status as WorkoutSession['status']) ?? undefined,
    exercises,
    metadata: row.metadata || undefined,
  };
}

@Injectable()
export class WorkoutSessionsSqlRepository implements IWorkoutSessionsRepository {
  constructor(private readonly db: DatabaseService) {}

  async findByPlanSessionId(planSessionId: string): Promise<WorkoutSession[]> {
    const rows = await this.db.query<WorkoutSessionRow>(
      'SELECT id, plan_session_id, user_id, day_of_week, time, week_number, status, metadata FROM workout_sessions WHERE plan_session_id = $1 ORDER BY day_of_week',
      [planSessionId],
    );
    return Promise.all(rows.map((r) => this.toSessionWithExercises(r)));
  }

  async findByUserId(
    userId: string,
    filter?: WorkoutSessionsFilter,
  ): Promise<WorkoutSession[]> {
    const conditions: string[] = ['user_id = $1'];
    const params: unknown[] = [userId];
    let paramIdx = 2;

    if (filter?.status?.length) {
      conditions.push(`status = ANY($${paramIdx}::text[])`);
      params.push(filter.status);
      paramIdx++;
    }

    const orderBy = filter?.sort === 'id_asc' ? 'ORDER BY id ASC' : 'ORDER BY id DESC';
    const limitClause = filter?.limit ? `LIMIT $${paramIdx}` : '';

    if (filter?.limit) {
      params.push(filter.limit);
    }

    const sql = `SELECT id, plan_session_id, user_id, day_of_week, time, week_number, status, metadata FROM workout_sessions WHERE ${conditions.join(' AND ')} ${orderBy} ${limitClause}`;
    const rows = await this.db.query<WorkoutSessionRow>(sql, params);
    return Promise.all(rows.map((r) => this.toSessionWithExercises(r)));
  }

  async findById(id: string): Promise<WorkoutSession | undefined> {
    const row = await this.db.queryOne<WorkoutSessionRow>(
      'SELECT id, plan_session_id, user_id, day_of_week, time, week_number, status, metadata FROM workout_sessions WHERE id = $1',
      [id],
    );
    if (!row) return undefined;
    return this.toSessionWithExercises(row);
  }

  async create(
    data: Omit<WorkoutSession, 'id'> & { exercises?: WorkoutSessionExercise[] },
  ): Promise<WorkoutSession> {
    const id =
      Date.now().toString(36) + Math.random().toString(36).substring(2, 8);

    const row = await this.db.transaction(async (client) => {
      const result = await client.query<WorkoutSessionRow>(
        `INSERT INTO workout_sessions (id, plan_session_id, user_id, day_of_week, time, status, week_number, metadata)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         RETURNING id, plan_session_id, user_id, day_of_week, time, week_number, status, metadata`,
        [
          id,
          data.planSessionId,
          data.userId,
          data.dayOfWeek,
          data.time ?? null,
          data.status ?? 'planned',
          data.weekNumber ?? 1,
          data.metadata ? JSON.stringify(data.metadata) : null,
        ],
      );

      if (data.exercises?.length) {
        for (const ex of data.exercises) {
          await client.query(
            `INSERT INTO workout_session_exercises (session_id, exercise_slug, sets, ordering, metadata)
             VALUES ($1, $2, $3, $4, $5)`,
            [
              id,
              ex.exerciseSlug,
              ex.sets,
              ex.order,
              ex.metadata ? JSON.stringify(ex.metadata) : null,
            ],
          );
        }
      }

      return result.rows[0];
    });

    return this.findById(row.id) as Promise<WorkoutSession>;
  }

  async update(
    id: string,
    data: Partial<Omit<WorkoutSession, 'id' | 'userId' | 'planSessionId'>> & {
      exercises?: WorkoutSessionExercise[];
    },
  ): Promise<WorkoutSession | undefined> {
    const existing = await this.findById(id);
    if (!existing) return undefined;

    await this.db.transaction(async (client) => {
      await client.query(
        `UPDATE workout_sessions SET day_of_week = COALESCE($2, day_of_week), time = COALESCE($3, time), status = COALESCE($4, status), metadata = COALESCE($5, metadata) WHERE id = $1`,
        [
          id,
          data.dayOfWeek ?? null,
          data.time ?? null,
          data.status ?? null,
          data.metadata ? JSON.stringify(data.metadata) : null,
        ],
      );

      if (data.exercises !== undefined) {
        await client.query(
          'DELETE FROM workout_session_exercises WHERE session_id = $1',
          [id],
        );
        for (const ex of data.exercises) {
          await client.query(
            `INSERT INTO workout_session_exercises (session_id, exercise_slug, sets, ordering, metadata)
             VALUES ($1, $2, $3, $4, $5)`,
            [
              id,
              ex.exerciseSlug,
              ex.sets,
              ex.order,
              ex.metadata ? JSON.stringify(ex.metadata) : null,
            ],
          );
        }
      }
    });

    return this.findById(id);
  }

  async planSets(sessionId: string, sets: WorkoutSessionSet[]): Promise<void> {
    await this.db.transaction(async (client) => {
      await client.query(
        'DELETE FROM workout_session_sets WHERE session_id = $1',
        [sessionId],
      );
      for (const s of sets) {
        await client.query(
          `INSERT INTO workout_session_sets (session_id, exercise_slug, set_number, set_type, planned_weight_kg, planned_reps, planned_duration_sec, planned_distance_m)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
          [
            sessionId,
            s.exerciseSlug,
            s.setNumber,
            s.setType,
            s.plannedWeightKg ?? null,
            s.plannedReps ?? null,
            s.plannedDurationSec ?? null,
            s.plannedDistanceM ?? null,
          ],
        );
      }
    });
  }

  async getSetsBySession(sessionId: string): Promise<WorkoutSessionSet[]> {
    const rows = await this.db.query<SetRow>(
      `SELECT session_id, exercise_slug, set_number, set_type,
              planned_weight_kg, planned_reps, planned_duration_sec, planned_distance_m,
              actual_weight_kg, actual_reps, actual_duration_sec, actual_distance_m, actual_rpe,
              completed_at
       FROM workout_session_sets WHERE session_id = $1 ORDER BY exercise_slug, set_number`,
      [sessionId],
    );
    return rows.map(toSet);
  }

  async getSetsBySessions(sessionIds: string[]): Promise<Map<string, WorkoutSessionSet[]>> {
    const result = new Map<string, WorkoutSessionSet[]>();
    if (!sessionIds.length) return result;
    const rows = await this.db.query<SetRow>(
      `SELECT session_id, exercise_slug, set_number, set_type,
              planned_weight_kg, planned_reps, planned_duration_sec, planned_distance_m,
              actual_weight_kg, actual_reps, actual_duration_sec, actual_distance_m, actual_rpe,
              completed_at
       FROM workout_session_sets WHERE session_id = ANY($1) ORDER BY exercise_slug, set_number`,
      [sessionIds],
    );
    for (const row of rows) {
      const arr = result.get(row.session_id) ?? [];
      arr.push(toSet(row));
      result.set(row.session_id, arr);
    }
    return result;
  }

  async completeSession(
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
  ): Promise<void> {
    await this.db.transaction(async (client) => {
      await client.query(
        `UPDATE workout_sessions SET status = 'completed' WHERE id = $1`,
        [sessionId],
      );
      for (const s of sets) {
        await client.query(
          `UPDATE workout_session_sets
           SET actual_weight_kg = COALESCE($3, actual_weight_kg),
               actual_reps = COALESCE($4, actual_reps),
               actual_duration_sec = COALESCE($5, actual_duration_sec),
               actual_distance_m = COALESCE($6, actual_distance_m),
               actual_rpe = COALESCE($7, actual_rpe),
               completed_at = NOW()
           WHERE session_id = $1 AND exercise_slug = $2 AND set_number = $8`,
          [
            sessionId,
            s.exerciseSlug,
            s.actualWeightKg ?? null,
            s.actualReps ?? null,
            s.actualDurationSec ?? null,
            s.actualDistanceM ?? null,
            s.actualRpe ?? null,
            s.setNumber,
          ],
        );
      }
    });
  }

  async findNextPlannedByUserId(
    userId: string,
    excludeSessionId?: string,
  ): Promise<WorkoutSession | undefined> {
    const conditions = ['user_id = $1', "status = 'planned'"];
    const params: unknown[] = [userId];
    if (excludeSessionId) {
      params.push(excludeSessionId);
      conditions.push(`id != $${params.length}`);
    }
    const row = await this.db.queryOne<WorkoutSessionRow>(
      `SELECT id, plan_session_id, user_id, day_of_week, time, week_number, status, metadata
       FROM workout_sessions WHERE ${conditions.join(' AND ')}
       ORDER BY id ASC LIMIT 1`,
      params,
    );
    if (!row) return undefined;
    return this.toSessionWithExercises(row);
  }

  async findStalePlanned(): Promise<WorkoutSession[]> {
    const now = new Date();
    const dayOrder = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    const jsDay = now.getDay();
    const todayIdx = jsDay === 0 ? 6 : jsDay - 1;
    if (todayIdx < 0) return [];

    const staleDays = dayOrder.slice(0, todayIdx);
    const rows = await this.db.query<WorkoutSessionRow>(
      `SELECT id, plan_session_id, user_id, day_of_week, time, week_number, status, metadata
       FROM workout_sessions
       WHERE status = 'planned' AND day_of_week = ANY($1)`,
      [staleDays],
    );
    return Promise.all(rows.map((r) => this.toSessionWithExercises(r)));
  }

  async skipSession(sessionId: string, autoSkipped = false): Promise<void> {
    await this.db.transaction(async (client) => {
      await client.query(
        `UPDATE workout_sessions SET status = 'skipped' WHERE id = $1`,
        [sessionId],
      );
      if (autoSkipped) {
        const existing = await client.query<{ metadata: string }>(
          'SELECT metadata FROM workout_sessions WHERE id = $1',
          [sessionId],
        );
        const meta = existing.rows[0]?.metadata
          ? (typeof existing.rows[0].metadata === 'string'
              ? JSON.parse(existing.rows[0].metadata)
              : existing.rows[0].metadata)
          : {};
        meta.autoSkipped = true;
        await client.query(
          'UPDATE workout_sessions SET metadata = $2 WHERE id = $1',
          [sessionId, JSON.stringify(meta)],
        );
      }
    });
  }

  async findExerciseHistory(
    userId: string,
    exerciseSlug: string,
    limit = 5,
  ): Promise<WorkoutSessionSet[]> {
    const rows = await this.db.query<SetRow>(
      `SELECT s.session_id, s.exercise_slug, s.set_number, s.set_type,
              s.planned_weight_kg, s.planned_reps, s.planned_duration_sec, s.planned_distance_m,
              s.actual_weight_kg, s.actual_reps, s.actual_duration_sec, s.actual_distance_m, s.actual_rpe,
              s.completed_at
       FROM workout_session_sets s
       JOIN workout_sessions ws ON ws.id = s.session_id
       WHERE ws.user_id = $1
         AND s.exercise_slug = $2
         AND ws.status = 'completed'
         AND s.actual_weight_kg IS NOT NULL
         AND s.set_type = 'working'
       ORDER BY s.completed_at DESC
       LIMIT $3`,
      [userId, exerciseSlug, limit],
    );
    return rows.map(toSet);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.db.query(
      'DELETE FROM workout_sessions WHERE id = $1',
      [id],
    );
    return (result as unknown as { rowCount: number }).rowCount > 0;
  }

  async findRecentCompletedByUserId(
    userId: string,
    _daysBack: number,
  ): Promise<WorkoutSession[]> {
    const rows = await this.db.query<WorkoutSessionRow>(
      `SELECT ws.id, ws.plan_session_id, ws.user_id, ws.day_of_week, ws.time, ws.week_number, ws.status, ws.metadata
       FROM workout_sessions ws
       WHERE ws.user_id = $1
         AND ws.status = 'completed'
       ORDER BY ws.id DESC
       LIMIT 50`,
      [userId],
    );
    return Promise.all(rows.map((r) => this.toSessionWithExercises(r)));
  }

  private async loadExercises(
    sessionId: string,
  ): Promise<WorkoutSessionExercise[]> {
    const rows = await this.db.query<SessionExerciseRow>(
      'SELECT exercise_slug, sets, ordering, metadata FROM workout_session_exercises WHERE session_id = $1 ORDER BY ordering',
      [sessionId],
    );
    return rows.map((r) => ({
      sessionId,
      exerciseSlug: r.exercise_slug,
      sets: r.sets,
      order: r.ordering,
      metadata: (r.metadata as WorkoutSessionExercise['metadata']) || undefined,
    }));
  }

  private async toSessionWithExercises(
    row: WorkoutSessionRow,
  ): Promise<WorkoutSession> {
    const exercises = await this.loadExercises(row.id);
    return toSession(row, exercises);
  }
}
