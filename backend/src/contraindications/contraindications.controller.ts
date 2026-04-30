import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ContraindicationsService } from './contraindications.service.js';
import { ContraindicationResponseDto } from './dto/contraindication-response.dto.js';

@ApiTags('Contraindications')
@Controller('contraindications')
export class ContraindicationsController {
  constructor(
    private readonly contraindicationsService: ContraindicationsService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'Get all contraindications' })
  @ApiOkResponse({
    type: [ContraindicationResponseDto],
    description: 'List of all contraindications',
  })
  findAll(): ContraindicationResponseDto[] {
    return this.contraindicationsService.findAll();
  }
}
