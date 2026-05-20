import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsIn } from 'class-validator';

export class CreateChatSessionDto {
  @ApiPropertyOptional({ example: 'chat', enum: ['chat', 'workout'] })
  @IsOptional()
  @IsIn(['chat', 'workout'])
  mode?: 'chat' | 'workout';

  @ApiPropertyOptional({ example: 'Вопросы о тренировках' })
  @IsOptional()
  @IsString()
  title?: string;
}
