import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class DialogAnswerDto {
  @ApiProperty({
    example: 'weekly',
    description: 'Answer value for current step',
  })
  @IsNotEmpty()
  @IsString()
  answer!: string;
}
