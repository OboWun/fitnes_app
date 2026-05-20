import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type { ChatSession } from '../entities/index.js';
import type { IChatSessionsRepository } from '../common/repositories/index.js';

interface SessionRow {
  id: string;
  user_id: string;
  mode: string;
  dialog_id: string | null;
  title: string | null;
  created_at: Date;
  updated_at: Date;
}

function toSession(row: SessionRow): ChatSession {
  return {
    id: row.id,
    userId: row.user_id,
    mode: row.mode as ChatSession['mode'],
    dialogId: row.dialog_id ?? undefined,
    title: row.title ?? undefined,
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
  };
}

@Injectable()
export class ChatSessionsSqlRepository implements IChatSessionsRepository {
  constructor(private readonly db: DatabaseService) {}

  async findById(id: string): Promise<ChatSession | undefined> {
    const row = await this.db.queryOne<SessionRow>(
      'SELECT id, user_id, mode, dialog_id, title, created_at, updated_at FROM chat_sessions WHERE id = $1',
      [id],
    );
    if (!row) return undefined;
    return toSession(row);
  }

  async findByUserId(userId: string): Promise<ChatSession[]> {
    const rows = await this.db.query<SessionRow>(
      'SELECT id, user_id, mode, dialog_id, title, created_at, updated_at FROM chat_sessions WHERE user_id = $1 ORDER BY created_at DESC',
      [userId],
    );
    return rows.map(toSession);
  }

  async create(data: {
    userId: string;
    mode?: string;
    title?: string;
  }): Promise<ChatSession> {
    const id =
      Date.now().toString(36) + Math.random().toString(36).substring(2, 8);
    const row = await this.db.queryOne<SessionRow>(
      `INSERT INTO chat_sessions (id, user_id, mode, title)
       VALUES ($1, $2, $3, $4)
       RETURNING id, user_id, mode, dialog_id, title, created_at, updated_at`,
      [id, data.userId, data.mode ?? 'chat', data.title ?? null],
    );
    return toSession(row!);
  }

  async update(
    id: string,
    data: Partial<Pick<ChatSession, 'mode' | 'dialogId' | 'title'>>,
  ): Promise<ChatSession | undefined> {
    const sets: string[] = [];
    const params: unknown[] = [id];
    let idx = 2;

    if (data.mode !== undefined) {
      sets.push(`mode = $${idx++}`);
      params.push(data.mode);
    }
    if (data.dialogId !== undefined) {
      sets.push(`dialog_id = $${idx++}`);
      params.push(data.dialogId);
    }
    if (data.title !== undefined) {
      sets.push(`title = $${idx++}`);
      params.push(data.title);
    }

    sets.push(`updated_at = NOW()`);

    if (sets.length === 1) return this.findById(id);

    const row = await this.db.queryOne<SessionRow>(
      `UPDATE chat_sessions SET ${sets.join(', ')} WHERE id = $1
       RETURNING id, user_id, mode, dialog_id, title, created_at, updated_at`,
      params,
    );
    if (!row) return undefined;
    return toSession(row);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.db.query(
      'DELETE FROM chat_sessions WHERE id = $1',
      [id],
    );
    return (result as unknown as { rowCount: number }).rowCount > 0;
  }
}
