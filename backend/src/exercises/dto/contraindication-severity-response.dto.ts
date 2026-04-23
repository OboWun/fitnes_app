import { ApiProperty } from '@nestjs/swagger';

export class ContraindicationSeverityResponseDto {
  @ApiProperty({ example: 'herniated_disc', description: 'Contraindication slug' })
  slug: string;

  @ApiProperty({
    example: 'forbidden',
    enum: ['forbidden', 'not_recommended', 'low_weight'],
    description: 'Severity level',
  })
  severity: 'forbidden' | 'not_recommended' | 'low_weight';
}
