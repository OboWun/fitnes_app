import { ApiProperty } from '@nestjs/swagger';

export class ContraindicationResponseDto {
  @ApiProperty({
    example: 'Грыжа межпозвоночного диска',
    description: 'Contraindication name',
  })
  name: string;

  @ApiProperty({
    example: 'herniated_disc',
    description: 'Contraindication slug',
  })
  slug: string;
}
