import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { MusclesService } from './muscles.service.js';
import { MuscleResponseDto } from './dto/muscle-response.dto.js';

@ApiTags('Muscles')
@Controller('muscles')
export class MusclesController {
  constructor(private readonly musclesService: MusclesService) {}

  @Get()
  @ApiOperation({ summary: 'Get all muscles' })
  @ApiOkResponse({ type: [MuscleResponseDto], description: 'List of all muscles' })
  findAll(): MuscleResponseDto[] {
    return this.musclesService.findAll();
  }
}
