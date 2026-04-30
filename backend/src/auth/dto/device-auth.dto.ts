import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty } from 'class-validator';

export class DeviceAuthDto {
  @ApiProperty({
    example: 'device-abc123',
    description: 'Unique device identifier',
  })
  @IsString()
  @IsNotEmpty()
  deviceId: string;
}
