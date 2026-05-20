import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type {
  TrainingPlan,
  TrainingPlanScheduleItem,
  TrainingPlanSession,
} from '../entities/index.js';
import type { ITrainingPlansRepository } from '../common/repositories/index.js';

interface PlanRow {
  id: string;
  user_id: string;
  name: string;
  is_active: boolean;
  source: string | null;
  created_at: Date;
}

interface ScheduleRow {
  day_of_week: string;
  workout_template_id: string;
  time: string | null;
  name: string | null;
  sort_order: number;
}

interface PlanSessionRow {
  id: string;
  plan_id: string;
  user_id: string;
  started_at: Date;
  current_week: number;
  status: string;
  created_at: Date;
}

function toPlan(row: PlanRow, schedule: TrainingPlanScheduleItem[] = []): TrainingPlan {
  return {
    id: row.id,
    userId: row.user_id,
    name: row.name,
    isActive: row.is_active,
    source: (row.source as TrainingPlan['source']) ?? undefined,
    schedule,
    createdAt: row.created_at.toISOString(),
  };
}

function toScheduleItem(r: ScheduleRow): TrainingPlanScheduleItem {
  return {
    dayOfWeek: r.day_of_week as TrainingPlanScheduleItem['dayOfWeek'],
    workoutTemplateId: r.workout_template_id,
    time: r.time ?? undefined,
    name: r.name ?? undefined,
    sortOrder: r.sort_order,
  };
}

function toPlanSession(r: PlanSessionRow): TrainingPlanSession {
  return {
    id: r.id,
    planId: r.plan_id,
    userId: r.user_id,
    startedAt: r.started_at.toISOString().slice(0, 10),
    currentWeek: r.current_week,
    status: r.status as TrainingPlanSession['status'],
    createdAt: r.created_at.toISOString(),
  };
}

@Injectable()
export class TrainingPlansSqlRepository implements ITrainingPlansRepository {
  constructor(private readonly db: DatabaseService) {}

  async findByUserId(userId: string): Promise<TrainingPlan[]> {
    const rows = await this.db.query<PlanRow>(
      'SELECT id, user_id, name, is_active, source, created_at FROM training_plans WHERE user_id = $1 ORDER BY created_at DESC',
      [userId],
    );
    return Promise.all(rows.map((r) => this.toPlanWithSchedule(r)));
  }

  async findById(id: string): Promise<TrainingPlan | undefined> {
    const row = await this.db.queryOne<PlanRow>(
      'SELECT id, user_id, name, is_active, source, created_at FROM training_plans WHERE id = $1',
      [id],
    );
    if (!row) return undefined;
    return this.toPlanWithSchedule(row);
  }

  async findActiveByUserId(userId: string): Promise<TrainingPlan | undefined> {
    const row = await this.db.queryOne<PlanRow>(
      'SELECT id, user_id, name, is_active, source, created_at FROM training_plans WHERE user_id = $1 AND is_active = true LIMIT 1',
      [userId],
    );
    if (!row) return undefined;
    return this.toPlanWithSchedule(row);
  }

  async create(
    data: Omit<TrainingPlan, 'id' | 'createdAt'> & {
      schedule?: TrainingPlan['schedule'];
    },
  ): Promise<TrainingPlan> {
    const id = Date.now().toString(36) + Math.random().toString(36).substring(2, 8);

    await this.db.transaction(async (client) => {
      await client.query(
        `INSERT INTO training_plans (id, user_id, name, is_active, source) VALUES ($1, $2, $3, $4, $5)`,
        [id, data.userId, data.name, data.isActive, data.source ?? null],
      );

      if (data.schedule?.length) {
        for (let i = 0; i < data.schedule.length; i++) {
          const s = data.schedule[i];
          await client.query(
            `INSERT INTO training_plan_schedule (plan_id, day_of_week, workout_template_id, time, name, sort_order) VALUES ($1, $2, $3, $4, $5, $6)`,
            [id, s.dayOfWeek, s.workoutTemplateId, s.time ?? null, s.name ?? null, i],
          );
        }
      }
    });

    return this.findById(id) as Promise<TrainingPlan>;
  }

  async update(
    id: string,
    data: Partial<Omit<TrainingPlan, 'id' | 'userId' | 'createdAt'>> & {
      schedule?: TrainingPlan['schedule'];
    },
  ): Promise<TrainingPlan | undefined> {
    const existing = await this.findById(id);
    if (!existing) return undefined;

    await this.db.transaction(async (client) => {
      if (data.name !== undefined || data.isActive !== undefined) {
        await client.query(
          `UPDATE training_plans SET name = COALESCE($2, name), is_active = COALESCE($3, is_active) WHERE id = $1`,
          [id, data.name ?? null, data.isActive !== undefined ? data.isActive : null],
        );
      }

      if (data.schedule !== undefined) {
        await client.query(
          'DELETE FROM training_plan_schedule WHERE plan_id = $1',
          [id],
        );
        for (let i = 0; i < data.schedule.length; i++) {
          const s = data.schedule[i];
          await client.query(
            `INSERT INTO training_plan_schedule (plan_id, day_of_week, workout_template_id, time, name, sort_order) VALUES ($1, $2, $3, $4, $5, $6)`,
            [id, s.dayOfWeek, s.workoutTemplateId, s.time ?? null, s.name ?? null, i],
          );
        }
      }
    });

    return this.findById(id);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.db.query(
      'DELETE FROM training_plans WHERE id = $1',
      [id],
    );
    return (result as unknown as { rowCount: number }).rowCount > 0;
  }

  async activate(id: string): Promise<void> {
    await this.db.query(
      'UPDATE training_plans SET is_active = true WHERE id = $1',
      [id],
    );
  }

  async deactivateByUserId(userId: string): Promise<void> {
    await this.db.query(
      'UPDATE training_plans SET is_active = false WHERE user_id = $1 AND is_active = true',
      [userId],
    );
  }

  async assignTemplate(
    planId: string,
    dayOfWeek: string,
    workoutTemplateId: string,
    time?: string,
    name?: string,
  ): Promise<void> {
    await this.db.query(
      `INSERT INTO training_plan_schedule (plan_id, day_of_week, workout_template_id, time, name, sort_order)
       VALUES ($1, $2, $3, $4, $5, 0)
       ON CONFLICT (plan_id, day_of_week) DO UPDATE SET workout_template_id = $3, time = $4, name = $5`,
      [planId, dayOfWeek, workoutTemplateId, time ?? null, name ?? null],
    );
  }

  async unassignTemplate(planId: string, dayOfWeek: string): Promise<void> {
    await this.db.query(
      'DELETE FROM training_plan_schedule WHERE plan_id = $1 AND day_of_week = $2',
      [planId, dayOfWeek],
    );
  }

  async createPlanSession(
    data: Omit<TrainingPlanSession, 'id' | 'createdAt'>,
  ): Promise<TrainingPlanSession> {
    const id = Date.now().toString(36) + Math.random().toString(36).substring(2, 8);
    const row = await this.db.queryOne<PlanSessionRow>(
      `INSERT INTO training_plan_sessions (id, plan_id, user_id, started_at, current_week, status)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, plan_id, user_id, started_at, current_week, status, created_at`,
      [id, data.planId, data.userId, data.startedAt, data.currentWeek, data.status],
    );
    return toPlanSession(row!);
  }

  async findActivePlanSession(userId: string): Promise<TrainingPlanSession | undefined> {
    const row = await this.db.queryOne<PlanSessionRow>(
      `SELECT ps.id, ps.plan_id, ps.user_id, ps.started_at, ps.current_week, ps.status, ps.created_at
       FROM training_plan_sessions ps
       JOIN training_plans p ON ps.plan_id = p.id
       WHERE ps.user_id = $1 AND ps.status = 'active' AND p.is_active = true
       LIMIT 1`,
      [userId],
    );
    if (!row) return undefined;
    return toPlanSession(row);
  }

  async updatePlanSessionWeek(sessionId: string, week: number): Promise<void> {
    await this.db.query(
      'UPDATE training_plan_sessions SET current_week = $2 WHERE id = $1',
      [sessionId, week],
    );
  }

  async archivePlanSession(sessionId: string): Promise<void> {
    await this.db.query(
      "UPDATE training_plan_sessions SET status = 'archived' WHERE id = $1",
      [sessionId],
    );
  }

  private async loadSchedule(planId: string): Promise<TrainingPlanScheduleItem[]> {
    const rows = await this.db.query<ScheduleRow>(
      'SELECT day_of_week, workout_template_id, time, name, sort_order FROM training_plan_schedule WHERE plan_id = $1 ORDER BY sort_order',
      [planId],
    );
    return rows.map(toScheduleItem);
  }

  private async toPlanWithSchedule(row: PlanRow): Promise<TrainingPlan> {
    const schedule = await this.loadSchedule(row.id);
    return toPlan(row, schedule);
  }
}
