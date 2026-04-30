import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class UserProfileResponseDto {
  @ApiProperty({ example: 'l1a2b3c', description: 'User ID' })
  id: string;

  @ApiProperty({ example: 'device-abc123', description: 'Device identifier' })
  deviceId: string;

  @ApiPropertyOptional({ example: 'Иван', description: 'User name' })
  name?: string;

  @ApiPropertyOptional({ example: 75, description: 'Weight in kg' })
  weight?: number;

  @ApiPropertyOptional({ example: 180, description: 'Height in cm' })
  height?: number;

  @ApiPropertyOptional({ example: 30, description: 'Age in years' })
  age?: number;

  @ApiProperty({
    type: [String],
    example: ['herniated_disc'],
    description: 'Contraindication slugs',
  })
  contraindications: string[];

  @ApiProperty({
    example: '2026-01-01T00:00:00.000Z',
    description: 'Account creation date',
  })
  createdAt: string;
}
