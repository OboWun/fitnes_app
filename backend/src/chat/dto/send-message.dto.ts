import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class SendMessageDto {
  @ApiProperty({ example: 'Как набрать мышечную массу?' })
  @IsNotEmpty()
  @IsString()
  content!: string;
}
