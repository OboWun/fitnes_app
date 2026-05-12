import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type {
  TrainingBlock,
  TrainingBlockMetadata,
} from '../entities/index.js';
import type { ITrainingBlocksRepository } from '../common/repositories/index.js';

interface TrainingBlockRow {
  id: string;
  user_id: string;
  name: string;
  type: string;
  index: number;
  duration_weeks: number;
  goal: string | null;
  target_muscles: string[] | null;
  metadata: TrainingBlockMetadata | null;
}

function toBlock(row: TrainingBlockRow): TrainingBlock {
  return {
    id: row.id,
    userId: row.user_id,
    name: row.name,
    type: row.type as TrainingBlock['type'],
    index: row.index,
    durationWeeks: row.duration_weeks,
    goal: row.goal ?? undefined,
    targetMuscles: row.target_muscles ?? undefined,
    metadata: row.metadata || undefined,
  };
}

@Injectable()
export class TrainingBlocksSqlRepository implements ITrainingBlocksRepository {
  constructor(private readonly db: DatabaseService) {}

  async findByUserId(userId: string): Promise<TrainingBlock[]> {
    const rows = await this.db.query<TrainingBlockRow>(
      'SELECT id, user_id, name, type, index, duration_weeks, goal, target_muscles, metadata FROM training_blocks WHERE user_id = $1 ORDER BY index',
      [userId],
    );
    return rows.map(toBlock);
  }

  async findById(id: string): Promise<TrainingBlock | undefined> {
    const row = await this.db.queryOne<TrainingBlockRow>(
      'SELECT id, user_id, name, type, index, duration_weeks, goal, target_muscles, metadata FROM training_blocks WHERE id = $1',
      [id],
    );
    if (!row) return undefined;
    return toBlock(row);
  }

  async create(data: Omit<TrainingBlock, 'id'>): Promise<TrainingBlock> {
    const id =
      Date.now().toString(36) + Math.random().toString(36).substring(2, 8);
    const row = await this.db.queryOne<TrainingBlockRow>(
      `INSERT INTO training_blocks (id, user_id, name, type, index, duration_weeks, goal, target_muscles, metadata)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING id, user_id, name, type, index, duration_weeks, goal, target_muscles, metadata`,
      [
        id,
        data.userId,
        data.name,
        data.type,
        data.index,
        data.durationWeeks,
        data.goal ?? null,
        data.targetMuscles ?? null,
        data.metadata ? JSON.stringify(data.metadata) : null,
      ],
    );
    return toBlock(row!);
  }

  async update(
    id: string,
    data: Partial<Omit<TrainingBlock, 'id' | 'userId'>>,
  ): Promise<TrainingBlock | undefined> {
    const existing = await this.findById(id);
    if (!existing) return undefined;

    await this.db.query(
      `UPDATE training_blocks SET name = COALESCE($2, name), type = COALESCE($3, type), index = COALESCE($4, index), duration_weeks = COALESCE($5, duration_weeks), goal = COALESCE($6, goal), target_muscles = COALESCE($7, target_muscles), metadata = COALESCE($8, metadata) WHERE id = $1`,
      [
        id,
        data.name ?? null,
        data.type ?? null,
        data.index ?? null,
        data.durationWeeks ?? null,
        data.goal ?? null,
        data.targetMuscles ?? null,
        data.metadata ? JSON.stringify(data.metadata) : null,
      ],
    );

    return this.findById(id);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.db.query(
      'DELETE FROM training_blocks WHERE id = $1',
      [id],
    );
    return (result as unknown as { rowCount: number }).rowCount > 0;
  }
}
