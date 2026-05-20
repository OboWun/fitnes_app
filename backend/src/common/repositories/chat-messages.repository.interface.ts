import type { ChatMessage } from '../../entities/index.js';

export const CHAT_MESSAGES_REPOSITORY = Symbol('CHAT_MESSAGES_REPOSITORY');

export interface IChatMessagesRepository {
  findBySessionId(sessionId: string): Promise<ChatMessage[]>;
  create(data: {
    sessionId: string;
    role: string;
    content: string;
    metadata?: Record<string, unknown>;
  }): Promise<ChatMessage>;
  deleteBySessionId(sessionId: string): Promise<void>;
}
