import { Inject, Injectable, Logger, NotFoundException } from '@nestjs/common';
import {
  CHAT_SESSIONS_REPOSITORY,
  CHAT_MESSAGES_REPOSITORY,
  WORKOUT_DIALOGS_REPOSITORY,
  USERS_REPOSITORY,
  EQUIPMENTS_REPOSITORY,
  EQUIPMENT_PRESETS_REPOSITORY,
  type IChatSessionsRepository,
  type IChatMessagesRepository,
  type IWorkoutDialogsRepository,
  type IUsersRepository,
  type IEquipmentsRepository,
  type IEquipmentPresetsRepository,
} from '../common/repositories/index.js';
import type { User as UserType } from '../entities/index.js';
import type { ChatSession, ChatMessage } from '../entities/index.js';
import { LLM_PROVIDER, type ILLMProvider } from './llm/llm-provider.interface.js';
import { WorkoutDialogService } from '../workout-dialog/workout-dialog.service.js';

@Injectable()
export class ChatService {
  private readonly logger = new Logger(ChatService.name);

  constructor(
    @Inject(CHAT_SESSIONS_REPOSITORY)
    private readonly sessionsRepo: IChatSessionsRepository,
    @Inject(CHAT_MESSAGES_REPOSITORY)
    private readonly messagesRepo: IChatMessagesRepository,
    @Inject(USERS_REPOSITORY)
    private readonly usersRepo: IUsersRepository,
    @Inject(LLM_PROVIDER)
    private readonly llmProvider: ILLMProvider,
    private readonly dialogService: WorkoutDialogService,
  ) {}

  async createSession(
    userId: string,
    data: { mode?: string; title?: string },
  ): Promise<ChatSession> {
    const session = await this.sessionsRepo.create({
      userId,
      mode: data.mode ?? 'chat',
      title: data.title,
    });

    if (session.mode === 'workout') {
      const dialogResult = await this.dialogService.startDialog(userId);
      await this.sessionsRepo.update(session.id, {
        dialogId: dialogResult.dialog.id,
      });

      await this.messagesRepo.create({
        sessionId: session.id,
        role: 'assistant',
        content: dialogResult.question,
        metadata: {
          type: 'dialog_step',
          step: dialogResult.step,
          inputType: dialogResult.inputType,
          options: dialogResult.options,
          canSkip: dialogResult.canSkip,
        },
      });

      const updated = await this.sessionsRepo.findById(session.id);
      return updated!;
    }

    return session;
  }

  async getSessions(userId: string): Promise<ChatSession[]> {
    return this.sessionsRepo.findByUserId(userId);
  }

  async getSession(
    userId: string,
    sessionId: string,
  ): Promise<ChatSession & { messages: ChatMessage[] }> {
    const session = await this.sessionsRepo.findById(sessionId);
    if (!session || session.userId !== userId) {
      throw new NotFoundException('Session not found');
    }
    const messages = await this.messagesRepo.findBySessionId(sessionId);
    return { ...session, messages };
  }

  async deleteSession(userId: string, sessionId: string): Promise<void> {
    const session = await this.sessionsRepo.findById(sessionId);
    if (!session || session.userId !== userId) {
      throw new NotFoundException('Session not found');
    }
    await this.sessionsRepo.delete(sessionId);
  }

  async switchMode(
    userId: string,
    sessionId: string,
    mode: 'chat' | 'workout',
  ): Promise<ChatSession> {
    const session = await this.sessionsRepo.findById(sessionId);
    if (!session || session.userId !== userId) {
      throw new NotFoundException('Session not found');
    }

    const updates: Partial<Pick<ChatSession, 'mode' | 'dialogId'>> = {
      mode,
    };

    if (mode === 'workout' && !session.dialogId) {
      const dialogResult = await this.dialogService.startDialog(userId);
      updates.dialogId = dialogResult.dialog.id;

      await this.messagesRepo.create({
        sessionId,
        role: 'system',
        content: 'Режим переключён на создание тренировки',
      });

      await this.messagesRepo.create({
        sessionId,
        role: 'assistant',
        content: dialogResult.question,
        metadata: {
          type: 'dialog_step',
          step: dialogResult.step,
          inputType: dialogResult.inputType,
          options: dialogResult.options,
          canSkip: dialogResult.canSkip,
        },
      });
    }

    if (mode === 'chat' && session.dialogId) {
      updates.dialogId = undefined as unknown as string;
    }

    await this.sessionsRepo.update(sessionId, updates);
    const updated = await this.sessionsRepo.findById(sessionId);
    return updated!;
  }

  async sendMessage(
    userId: string,
    sessionId: string,
    content: string,
  ): Promise<{
    userMessage: ChatMessage;
    assistantMessage: ChatMessage;
    mode: string;
    dialogCompleted?: boolean;
    workoutResult?: Record<string, unknown>;
  }> {
    const session = await this.sessionsRepo.findById(sessionId);
    if (!session || session.userId !== userId) {
      throw new NotFoundException('Session not found');
    }

    if (!session.title) {
      const title =
        content.length > 50 ? content.substring(0, 50) + '...' : content;
      await this.sessionsRepo.update(sessionId, { title });
    }

    const userMessage = await this.messagesRepo.create({
      sessionId,
      role: 'user',
      content,
    });

    let assistantMessage: ChatMessage;
    let dialogCompleted: boolean | undefined;
    let workoutResult: Record<string, unknown> | undefined;

    if (session.mode === 'workout' && session.dialogId) {
      let result;
      try {
        result = await this.dialogService.answerStep(
          session.dialogId,
          content,
        );
      } catch (e) {
        const err = e as Error;
        this.logger.error(`Dialog answerStep failed for session ${sessionId}: ${err.message}`, err.stack);
        assistantMessage = await this.messagesRepo.create({
          sessionId,
          role: 'assistant',
          content: 'Произошла ошибка при обработке ответа. Попробуйте ещё раз.',
        });
        return {
          userMessage,
          assistantMessage,
          mode: session.mode,
        };
      }

      if (result.completed) {
        dialogCompleted = true;
        const params = result.params;
        const planType = result.planType;

        workoutResult = {
          type: 'workout_params',
          planType,
          params,
        };

        assistantMessage = await this.messagesRepo.create({
          sessionId,
          role: 'assistant',
          content:
            'Супер, все параметры собраны! 💪 Могу прямо сейчас составить тебе программу на основе этих данных. Создаём?',
          metadata: {
            type: 'dialog_complete',
            planType,
            params,
          },
        });
      } else {
        assistantMessage = await this.messagesRepo.create({
          sessionId,
          role: 'assistant',
          content: result.question,
          metadata: {
            type: 'dialog_step',
            step: result.step,
            inputType: result.inputType,
            options: result.options,
            canSkip: result.canSkip,
          },
        });
      }
    } else {
      const history = await this.messagesRepo.findBySessionId(sessionId);
      const user = await this.usersRepo.findById(userId);
      const userContext = user ? this.buildUserContext(user) : undefined;

      const response = await this.llmProvider.generateResponse({
        messages: history
          .filter((m) => m.role !== 'system')
          .map((m) => ({
            role: m.role,
            content: m.content,
          })),
        userContext,
      });

      assistantMessage = await this.messagesRepo.create({
        sessionId,
        role: 'assistant',
        content: response.content,
      });
    }

    return {
      userMessage,
      assistantMessage,
      mode: session.mode,
      dialogCompleted,
      workoutResult,
    };
  }

  private buildUserContext(user: UserType): string {
    const meta = user.metadata;
    const lines: string[] = ['## Контекст пользователя'];

    if (user.name) lines.push(`Имя: ${user.name}`);
    if (user.gender) lines.push(`Пол: ${user.gender === 'male' ? 'мужской' : 'женский'}`);
    if (user.age) lines.push(`Возраст: ${user.age}`);
    if (user.weight) lines.push(`Вес: ${user.weight} кг`);
    if (user.height) lines.push(`Рост: ${user.height} см`);
    if (meta?.goal) lines.push(`Цель: ${meta.goal}`);
    if (meta?.experienceLevel) lines.push(`Уровень подготовки: ${meta.experienceLevel}`);
    if (meta?.injuryHistory?.length) lines.push(`Травмы: ${meta.injuryHistory.join(', ')}`);
    if (user.contraindications?.length) lines.push(`Противопоказания: ${user.contraindications.join(', ')}`);

    return lines.join('\n');
  }
}
