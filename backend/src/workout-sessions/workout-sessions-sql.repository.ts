import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type {
  WorkoutSession,
  WorkoutSessionMetadata,
  WorkoutSessionExercise,
} from '../entities/index.js';
import type { IWorkoutSessionsRepository } from '../common/repositories/index.js';

interface WorkoutSessionRow {
  id: string;
  block_id: string;
  user_id: string;
  day_of_week: string;
  time: string | null;
  status: string | null;
  metadata: WorkoutSessionMetadata | null;
}

interface SessionExerciseRow {
  exercise_slug: string;
  sets: number;
  ordering: number;
  metadata: Record<string, unknown> | null;
}

function toSession(
  row: WorkoutSessionRow,
  exercises: WorkoutSessionExercise[] = [],
): WorkoutSession {
  return {
    id: row.id,
    blockId: row.block_id,
    userId: row.user_id,
    dayOfWeek: row.day_of_week as WorkoutSession['dayOfWeek'],
    time: row.time ?? undefined,
    status: (row.status as WorkoutSession['status']) ?? undefined,
    exercises,
    metadata: row.metadata || undefined,
  };
}

@Injectable()
export class WorkoutSessionsSqlRepository implements IWorkoutSessionsRepository {
  constructor(private readonly db: DatabaseService) {}

  async findByBlockId(blockId: string): Promise<WorkoutSession[]> {
    const rows = await this.db.query<WorkoutSessionRow>(
      'SELECT id, block_id, user_id, day_of_week, time, status, metadata FROM workout_sessions WHERE block_id = $1 ORDER BY day_of_week',
      [blockId],
    );
    return Promise.all(rows.map((r) => this.toSessionWithExercises(r)));
  }

  async findByUserId(userId: string): Promise<WorkoutSession[]> {
    const rows = await this.db.query<WorkoutSessionRow>(
      'SELECT id, block_id, user_id, day_of_week, time, status, metadata FROM workout_sessions WHERE user_id = $1 ORDER BY day_of_week',
      [userId],
    );
    return Promise.all(rows.map((r) => this.toSessionWithExercises(r)));
  }

  async findById(id: string): Promise<WorkoutSession | undefined> {
    const row = await this.db.queryOne<WorkoutSessionRow>(
      'SELECT id, block_id, user_id, day_of_week, time, status, metadata FROM workout_sessions WHERE id = $1',
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
        `INSERT INTO workout_sessions (id, block_id, user_id, day_of_week, time, status, metadata)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         RETURNING id, block_id, user_id, day_of_week, time, status, metadata`,
        [
          id,
          data.blockId,
          data.userId,
          data.dayOfWeek,
          data.time ?? null,
          data.status ?? 'planned',
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
    data: Partial<Omit<WorkoutSession, 'id' | 'userId' | 'blockId'>> & {
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
      `SELECT id, block_id, user_id, day_of_week, time, status, metadata
       FROM workout_sessions
       WHERE user_id = $1
         AND status = 'completed'
       ORDER BY id DESC
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
