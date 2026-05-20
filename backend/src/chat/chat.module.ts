import { Module } from '@nestjs/common';
import { ChatController } from './chat.controller.js';
import { ChatService } from './chat.service.js';
import { ChatSessionsSqlRepository } from './chat-sessions-sql.repository.js';
import { ChatMessagesSqlRepository } from './chat-messages-sql.repository.js';
import { MockLLMProvider } from './llm/mock-llm.provider.js';
import { ILLMProvider, LLM_PROVIDER } from './llm/llm-provider.interface.js';
import {
  CHAT_SESSIONS_REPOSITORY,
  CHAT_MESSAGES_REPOSITORY,
  USERS_REPOSITORY,
} from '../common/repositories/index.js';
import { UsersSqlRepository } from '../users/users-sql.repository.js';
import { WorkoutDialogModule } from '../workout-dialog/workout-dialog.module.js';

@Module({
  imports: [WorkoutDialogModule],
  controllers: [ChatController],
  providers: [
    ChatService,
    {
      provide: CHAT_SESSIONS_REPOSITORY,
      useClass: ChatSessionsSqlRepository,
    },
    {
      provide: CHAT_MESSAGES_REPOSITORY,
      useClass: ChatMessagesSqlRepository,
    },
    {
      provide: USERS_REPOSITORY,
      useClass: UsersSqlRepository,
    },
    {
      provide: LLM_PROVIDER,
      useClass: MockLLMProvider,
    },
  ],
})
export class ChatModule {}
