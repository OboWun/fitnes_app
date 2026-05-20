import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type { ChatMessage } from '../entities/index.js';
import type { IChatMessagesRepository } from '../common/repositories/index.js';

interface MessageRow {
  id: string;
  session_id: string;
  role: string;
  content: string;
  metadata: Record<string, unknown> | null;
  created_at: Date;
}

function toMessage(row: MessageRow): ChatMessage {
  return {
    id: row.id,
    sessionId: row.session_id,
    role: row.role as ChatMessage['role'],
    content: row.content,
    metadata: row.metadata ?? undefined,
    createdAt: row.created_at.toISOString(),
  };
}

@Injectable()
export class ChatMessagesSqlRepository implements IChatMessagesRepository {
  constructor(private readonly db: DatabaseService) {}

  async findBySessionId(sessionId: string): Promise<ChatMessage[]> {
    const rows = await this.db.query<MessageRow>(
      'SELECT id, session_id, role, content, metadata, created_at FROM chat_messages WHERE session_id = $1 ORDER BY created_at ASC',
      [sessionId],
    );
    return rows.map(toMessage);
  }

  async create(data: {
    sessionId: string;
    role: string;
    content: string;
    metadata?: Record<string, unknown>;
  }): Promise<ChatMessage> {
    const id =
      Date.now().toString(36) + Math.random().toString(36).substring(2, 8);
    const row = await this.db.queryOne<MessageRow>(
      `INSERT INTO chat_messages (id, session_id, role, content, metadata)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, session_id, role, content, metadata, created_at`,
      [
        id,
        data.sessionId,
        data.role,
        data.content,
        data.metadata ? JSON.stringify(data.metadata) : null,
      ],
    );
    return toMessage(row!);
  }

  async deleteBySessionId(sessionId: string): Promise<void> {
    await this.db.query('DELETE FROM chat_messages WHERE session_id = $1', [
      sessionId,
    ]);
  }
}
