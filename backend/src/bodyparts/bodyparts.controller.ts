import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { BodypartsService } from './bodyparts.service.js';
import { BodypartResponseDto } from './dto/bodypart-response.dto.js';

@ApiTags('Body Parts')
@Controller('bodyparts')
export class BodypartsController {
  constructor(private readonly bodypartsService: BodypartsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all body parts' })
  @ApiOkResponse({ type: [BodypartResponseDto], description: 'List of all body parts' })
  findAll(): BodypartResponseDto[] {
    return this.bodypartsService.findAll();
  }
}
