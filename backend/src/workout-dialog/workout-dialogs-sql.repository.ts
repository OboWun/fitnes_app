import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type { WorkoutDialog } from '../entities/index.js';
import type { IWorkoutDialogsRepository } from '../common/repositories/index.js';

interface DialogRow {
  id: string;
  user_id: string;
  current_step: string;
  plan_type: string | null;
  collected_params: Record<string, unknown> | null;
  created_at: string;
  updated_at: string;
}

function toDialog(row: DialogRow): WorkoutDialog {
  return {
    id: row.id,
    userId: row.user_id,
    currentStep: row.current_step,
    planType: row.plan_type ?? undefined,
    collectedParams: row.collected_params ?? {},
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

@Injectable()
export class WorkoutDialogsSqlRepository implements IWorkoutDialogsRepository {
  constructor(private readonly db: DatabaseService) {}

  async findById(id: string): Promise<WorkoutDialog | undefined> {
    const row = await this.db.queryOne<DialogRow>(
      'SELECT id, user_id, current_step, plan_type, collected_params, created_at, updated_at FROM workout_dialogs WHERE id = $1',
      [id],
    );
    if (!row) return undefined;
    return toDialog(row);
  }

  async findByUserId(userId: string): Promise<WorkoutDialog[]> {
    const rows = await this.db.query<DialogRow>(
      'SELECT id, user_id, current_step, plan_type, collected_params, created_at, updated_at FROM workout_dialogs WHERE user_id = $1 ORDER BY created_at DESC',
      [userId],
    );
    return rows.map(toDialog);
  }

  async create(
    data: Omit<WorkoutDialog, 'id' | 'createdAt' | 'updatedAt'>,
  ): Promise<WorkoutDialog> {
    const id =
      Date.now().toString(36) + Math.random().toString(36).substring(2, 8);
    const row = await this.db.queryOne<DialogRow>(
      `INSERT INTO workout_dialogs (id, user_id, current_step, plan_type, collected_params)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, user_id, current_step, plan_type, collected_params, created_at, updated_at`,
      [
        id,
        data.userId,
        data.currentStep,
        data.planType ?? null,
        JSON.stringify(data.collectedParams),
      ],
    );
    return toDialog(row!);
  }

  async update(
    id: string,
    data: Partial<
      Pick<WorkoutDialog, 'currentStep' | 'planType' | 'collectedParams'>
    >,
  ): Promise<WorkoutDialog | undefined> {
    const sets: string[] = [];
    const params: unknown[] = [id];
    let idx = 2;

    if (data.currentStep !== undefined) {
      sets.push(`current_step = $${idx++}`);
      params.push(data.currentStep);
    }
    if (data.planType !== undefined) {
      sets.push(`plan_type = $${idx++}`);
      params.push(data.planType);
    }
    if (data.collectedParams !== undefined) {
      sets.push(`collected_params = $${idx++}`);
      params.push(JSON.stringify(data.collectedParams));
    }

    sets.push(`updated_at = NOW()`);

    if (sets.length === 1) return this.findById(id);

    const row = await this.db.queryOne<DialogRow>(
      `UPDATE workout_dialogs SET ${sets.join(', ')} WHERE id = $1
       RETURNING id, user_id, current_step, plan_type, collected_params, created_at, updated_at`,
      params,
    );
    if (!row) return undefined;
    return toDialog(row);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.db.query(
      'DELETE FROM workout_dialogs WHERE id = $1',
      [id],
    );
    return (result as unknown as { rowCount: number }).rowCount > 0;
  }
}
