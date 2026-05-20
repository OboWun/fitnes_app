import {
  Controller,
  Get,
  Post,
  Delete,
  Patch,
  Param,
  Body,
  UseGuards,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiCreatedResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
  ApiNoContentResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import type { User } from '../entities/index.js';
import { ChatService } from './chat.service.js';
import { CreateChatSessionDto } from './dto/create-session.dto.js';
import { SendMessageDto } from './dto/send-message.dto.js';
import { SwitchModeDto } from './dto/switch-mode.dto.js';
import {
  ChatSessionResponseDto,
  SendMessageResponseDto,
} from './dto/chat-response.dto.js';

@ApiTags('Chat')
@ApiBearerAuth()
@Controller('chat')
@UseGuards(JwtAuthGuard)
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post('sessions')
  @ApiOperation({ summary: 'Create a new chat session' })
  @ApiCreatedResponse({ type: ChatSessionResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async createSession(
    @CurrentUser() user: User,
    @Body() dto: CreateChatSessionDto,
  ): Promise<ChatSessionResponseDto> {
    const session = await this.chatService.createSession(user.id, {
      mode: dto.mode,
      title: dto.title,
    });
    return this.toSessionResponse(session);
  }

  @Get('sessions')
  @ApiOperation({ summary: 'Get all chat sessions for current user' })
  @ApiOkResponse({ type: [ChatSessionResponseDto] })
  async getSessions(
    @CurrentUser() user: User,
  ): Promise<ChatSessionResponseDto[]> {
    const sessions = await this.chatService.getSessions(user.id);
    return sessions.map((s) => this.toSessionResponse(s));
  }

  @Get('sessions/:id')
  @ApiOperation({ summary: 'Get a chat session with messages' })
  @ApiParam({ name: 'id' })
  @ApiOkResponse({ type: ChatSessionResponseDto })
  async getSession(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ): Promise<ChatSessionResponseDto> {
    const result = await this.chatService.getSession(user.id, id);
    return {
      id: result.id,
      mode: result.mode,
      dialogId: result.dialogId,
      title: result.title,
      createdAt: result.createdAt,
      messages: result.messages.map((m) => ({
        id: m.id,
        sessionId: m.sessionId,
        role: m.role,
        content: m.content,
        metadata: m.metadata,
        createdAt: m.createdAt,
      })),
    };
  }

  @Delete('sessions/:id')
  @ApiOperation({ summary: 'Delete a chat session' })
  @ApiParam({ name: 'id' })
  @ApiNoContentResponse()
  async deleteSession(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ): Promise<void> {
    await this.chatService.deleteSession(user.id, id);
  }

  @Post('sessions/:id/messages')
  @ApiOperation({ summary: 'Send a message in a chat session' })
  @ApiParam({ name: 'id' })
  @ApiOkResponse({ type: SendMessageResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async sendMessage(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: SendMessageDto,
  ): Promise<SendMessageResponseDto> {
    const result = await this.chatService.sendMessage(
      user.id,
      id,
      dto.content,
    );
    return {
      userMessageId: result.userMessage.id,
      assistantMessageId: result.assistantMessage.id,
      content: result.assistantMessage.content,
      mode: result.mode,
      dialogCompleted: result.dialogCompleted,
      workoutResult: result.workoutResult,
    };
  }

  @Patch('sessions/:id/mode')
  @ApiOperation({ summary: 'Switch chat mode (chat ↔ workout)' })
  @ApiParam({ name: 'id' })
  @ApiOkResponse({ type: ChatSessionResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async switchMode(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: SwitchModeDto,
  ): Promise<ChatSessionResponseDto> {
    const session = await this.chatService.switchMode(
      user.id,
      id,
      dto.mode,
    );
    return this.toSessionResponse(session);
  }

  private toSessionResponse(session: {
    id: string;
    mode: string;
    dialogId?: string;
    title?: string;
    createdAt: string;
  }): ChatSessionResponseDto {
    return {
      id: session.id,
      mode: session.mode,
      dialogId: session.dialogId,
      title: session.title,
      createdAt: session.createdAt,
    };
  }
}
