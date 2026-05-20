import { ApiProperty } from '@nestjs/swagger';
import { IsIn } from 'class-validator';

export class SwitchModeDto {
  @ApiProperty({ enum: ['chat', 'workout'] })
  @IsIn(['chat', 'workout'])
  mode!: 'chat' | 'workout';
}
