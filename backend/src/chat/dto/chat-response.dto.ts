import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

class ChatMessageDto {
  @ApiProperty() id!: string;
  @ApiProperty() role!: string;
  @ApiProperty() content!: string;
  @ApiPropertyOptional() metadata?: Record<string, unknown>;
  @ApiProperty() createdAt!: string;
}

export class ChatSessionResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() mode!: string;
  @ApiPropertyOptional() dialogId?: string;
  @ApiPropertyOptional() title?: string;
  @ApiProperty() createdAt!: string;
  @ApiPropertyOptional() messages?: ChatMessageDto[];
}

export class SendMessageResponseDto {
  @ApiProperty() userMessageId!: string;
  @ApiProperty() assistantMessageId!: string;
  @ApiProperty() content!: string;
  @ApiProperty() mode!: string;
  @ApiPropertyOptional() dialogStep?: string;
  @ApiPropertyOptional() dialogCompleted?: boolean;
  @ApiPropertyOptional() workoutResult?: Record<string, unknown>;
}

export { ChatMessageDto };
