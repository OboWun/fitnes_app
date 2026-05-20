import type { ChatSession } from '../../entities/index.js';

export const CHAT_SESSIONS_REPOSITORY = Symbol('CHAT_SESSIONS_REPOSITORY');

export interface IChatSessionsRepository {
  findById(id: string): Promise<ChatSession | undefined>;
  findByUserId(userId: string): Promise<ChatSession[]>;
  create(data: {
    userId: string;
    mode?: string;
    title?: string;
  }): Promise<ChatSession>;
  update(
    id: string,
    data: Partial<Pick<ChatSession, 'mode' | 'dialogId' | 'title'>>,
  ): Promise<ChatSession | undefined>;
  delete(id: string): Promise<boolean>;
}
