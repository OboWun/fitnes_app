export interface ChatSession {
  id: string;
  userId: string;
  mode: 'chat' | 'workout';
  dialogId?: string;
  title?: string;
  createdAt: string;
  updatedAt: string;
}
