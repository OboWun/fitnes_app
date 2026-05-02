import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type {
  WorkoutTemplate,
  WorkoutExercise,
  ScheduledWorkout,
} from '../entities/index.js';
import type {
  IWorkoutTemplatesRepository,
  IScheduledWorkoutsRepository,
} from '../common/repositories/index.js';

@Injectable()
export class WorkoutTemplatesSqlRepository
  implements IWorkoutTemplatesRepository
{
  constructor(private readonly db: DatabaseService) {}

  async findByUserId(userId: string): Promise<WorkoutTemplate[]> {
    const rows = await this.db.query<{
      id: string;
      user_id: string;
      name: string;
      description: string | null;
      created_at: Date;
      updated_at: Date;
    }>(
      'SELECT id, user_id, name, description, created_at, updated_at FROM workout_templates WHERE user_id = $1 ORDER BY created_at DESC',
      [userId],
    );
    return Promise.all(rows.map((r) => this.toTemplate(r)));
  }

  async findById(id: string): Promise<WorkoutTemplate | undefined> {
    const row = await this.db.queryOne<{
      id: string;
      user_id: string;
      name: string;
      description: string | null;
      created_at: Date;
      updated_at: Date;
    }>(
      'SELECT id, user_id, name, description, created_at, updated_at FROM workout_templates WHERE id = $1',
      [id],
    );
    if (!row) return undefined;
    return this.toTemplate(row);
  }

  async create(
    data: Omit<WorkoutTemplate, 'id' | 'createdAt' | 'updatedAt'>,
  ): Promise<WorkoutTemplate> {
    const id =
      Date.now().toString(36) + Math.random().toString(36).substring(2, 8);

    const row = await this.db.transaction(async (client) => {
      const result = await client.query<{
        id: string;
        user_id: string;
        name: string;
        description: string | null;
        created_at: Date;
        updated_at: Date;
      }>(
        `INSERT INTO workout_templates (id, user_id, name, description)
         VALUES ($1, $2, $3, $4)
         RETURNING id, user_id, name, description, created_at, updated_at`,
        [id, data.userId, data.name, data.description ?? null],
      );

      if (data.exercises?.length) {
        for (const ex of data.exercises) {
          await client.query(
            `INSERT INTO workout_exercises (template_id, exercise_slug, sets, reps, rest_between_sets, rest_after_exercise, sort_order)
             VALUES ($1, $2, $3, $4, $5, $6, $7)`,
            [
              id,
              ex.exerciseSlug,
              ex.sets,
              ex.reps ?? null,
              ex.restBetweenSets ?? null,
              ex.restAfterExercise ?? null,
              ex.order,
            ],
          );
        }
      }

      return result.rows[0];
    });

    return this.toTemplate(row);
  }

  async update(
    id: string,
    data: Partial<
      Omit<WorkoutTemplate, 'id' | 'userId' | 'createdAt' | 'updatedAt'>
    >,
  ): Promise<WorkoutTemplate | undefined> {
    const existing = await this.findById(id);
    if (!existing) return undefined;

    await this.db.transaction(async (client) => {
      await client.query(
        `UPDATE workout_templates SET name = COALESCE($2, name), description = COALESCE($3, description), updated_at = NOW() WHERE id = $1`,
        [id, data.name ?? null, data.description ?? null],
      );

      if (data.exercises !== undefined) {
        await client.query(
          'DELETE FROM workout_exercises WHERE template_id = $1',
          [id],
        );
        for (const ex of data.exercises) {
          await client.query(
            `INSERT INTO workout_exercises (template_id, exercise_slug, sets, reps, rest_between_sets, rest_after_exercise, sort_order)
             VALUES ($1, $2, $3, $4, $5, $6, $7)`,
            [
              id,
              ex.exerciseSlug,
              ex.sets,
              ex.reps ?? null,
              ex.restBetweenSets ?? null,
              ex.restAfterExercise ?? null,
              ex.order,
            ],
          );
        }
      }
    });

    return this.findById(id);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.db.query(
      'DELETE FROM workout_templates WHERE id = $1',
      [id],
    );
    return (result as unknown as { rowCount: number }).rowCount > 0;
  }

  private async toTemplate(row: {
    id: string;
    user_id: string;
    name: string;
    description: string | null;
    created_at: Date;
    updated_at: Date;
  }): Promise<WorkoutTemplate> {
    const exRows = await this.db.query<{
      exercise_slug: string;
      sets: number;
      reps: number | null;
      rest_between_sets: number | null;
      rest_after_exercise: number | null;
      sort_order: number;
    }>(
      'SELECT exercise_slug, sets, reps, rest_between_sets, rest_after_exercise, sort_order FROM workout_exercises WHERE template_id = $1 ORDER BY sort_order',
      [row.id],
    );

    return {
      id: row.id,
      userId: row.user_id,
      name: row.name,
      description: row.description ?? undefined,
      exercises: exRows.map((e) => ({
        exerciseSlug: e.exercise_slug,
        sets: e.sets,
        reps: e.reps ?? undefined,
        restBetweenSets: e.rest_between_sets ?? undefined,
        restAfterExercise: e.rest_after_exercise ?? undefined,
        order: e.sort_order,
      })),
      createdAt: new Date(row.created_at).toISOString(),
      updatedAt: new Date(row.updated_at).toISOString(),
    };
  }
}

@Injectable()
export class ScheduledWorkoutsSqlRepository
  implements IScheduledWorkoutsRepository
{
  constructor(private readonly db: DatabaseService) {}

  async findByUserId(userId: string): Promise<ScheduledWorkout[]> {
    const rows = await this.db.query<{
      id: string;
      template_id: string;
      user_id: string;
      day_of_week: string;
      time: string;
      created_at: Date;
    }>(
      'SELECT id, template_id, user_id, day_of_week, time, created_at FROM scheduled_workouts WHERE user_id = $1 ORDER BY day_of_week, time',
      [userId],
    );
    return rows.map((r) => ({
      id: r.id,
      templateId: r.template_id,
      userId: r.user_id,
      dayOfWeek: r.day_of_week as ScheduledWorkout['dayOfWeek'],
      time: r.time,
      createdAt: new Date(r.created_at).toISOString(),
    }));
  }

  async findById(id: string): Promise<ScheduledWorkout | undefined> {
    const row = await this.db.queryOne<{
      id: string;
      template_id: string;
      user_id: string;
      day_of_week: string;
      time: string;
      created_at: Date;
    }>(
      'SELECT id, template_id, user_id, day_of_week, time, created_at FROM scheduled_workouts WHERE id = $1',
      [id],
    );
    if (!row) return undefined;
    return {
      id: row.id,
      templateId: row.template_id,
      userId: row.user_id,
      dayOfWeek: row.day_of_week as ScheduledWorkout['dayOfWeek'],
      time: row.time,
      createdAt: new Date(row.created_at).toISOString(),
    };
  }

  async findByUserIdAndDay(
    userId: string,
    dayOfWeek: string,
  ): Promise<ScheduledWorkout[]> {
    const rows = await this.db.query<{
      id: string;
      template_id: string;
      user_id: string;
      day_of_week: string;
      time: string;
      created_at: Date;
    }>(
      'SELECT id, template_id, user_id, day_of_week, time, created_at FROM scheduled_workouts WHERE user_id = $1 AND day_of_week = $2 ORDER BY time',
      [userId, dayOfWeek],
    );
    return rows.map((r) => ({
      id: r.id,
      templateId: r.template_id,
      userId: r.user_id,
      dayOfWeek: r.day_of_week as ScheduledWorkout['dayOfWeek'],
      time: r.time,
      createdAt: new Date(r.created_at).toISOString(),
    }));
  }

  async create(
    data: Omit<ScheduledWorkout, 'id' | 'createdAt'>,
  ): Promise<ScheduledWorkout> {
    const id =
      Date.now().toString(36) + Math.random().toString(36).substring(2, 8);
    const row = await this.db.queryOne<{
      id: string;
      template_id: string;
      user_id: string;
      day_of_week: string;
      time: string;
      created_at: Date;
    }>(
      `INSERT INTO scheduled_workouts (id, template_id, user_id, day_of_week, time)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, template_id, user_id, day_of_week, time, created_at`,
      [id, data.templateId, data.userId, data.dayOfWeek, data.time],
    );
    return {
      id: row!.id,
      templateId: row!.template_id,
      userId: row!.user_id,
      dayOfWeek: row!.day_of_week as ScheduledWorkout['dayOfWeek'],
      time: row!.time,
      createdAt: new Date(row!.created_at).toISOString(),
    };
  }

  async update(
    id: string,
    data: Partial<Omit<ScheduledWorkout, 'id' | 'userId' | 'createdAt'>>,
  ): Promise<ScheduledWorkout | undefined> {
    const existing = await this.findById(id);
    if (!existing) return undefined;

    await this.db.query(
      `UPDATE scheduled_workouts SET template_id = COALESCE($2, template_id), day_of_week = COALESCE($3, day_of_week), time = COALESCE($4, time) WHERE id = $1`,
      [id, data.templateId ?? null, data.dayOfWeek ?? null, data.time ?? null],
    );

    return this.findById(id);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.db.query(
      'DELETE FROM scheduled_workouts WHERE id = $1',
      [id],
    );
    return (result as unknown as { rowCount: number }).rowCount > 0;
  }
}
