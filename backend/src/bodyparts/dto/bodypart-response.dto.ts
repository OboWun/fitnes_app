import { ApiProperty } from '@nestjs/swagger';

export class BodypartResponseDto {
  @ApiProperty({ example: 'грудь', description: 'Body part name' })
  name: string;

  @ApiProperty({ example: 'chest', description: 'Body part slug identifier' })
  slug: string;
}
