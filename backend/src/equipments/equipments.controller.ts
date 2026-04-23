import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { EquipmentsService } from './equipments.service.js';
import { EquipmentResponseDto } from './dto/equipment-response.dto.js';

@ApiTags('Equipments')
@Controller('equipments')
export class EquipmentsController {
  constructor(private readonly equipmentsService: EquipmentsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all equipments' })
  @ApiOkResponse({ type: [EquipmentResponseDto], description: 'List of all equipments' })
  findAll(): EquipmentResponseDto[] {
    return this.equipmentsService.findAll();
  }
}
