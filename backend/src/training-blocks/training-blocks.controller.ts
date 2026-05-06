import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  UseGuards,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiCreatedResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
  ApiNoContentResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import type { User } from '../entities/index.js';
import { TrainingBlocksService } from './training-blocks.service.js';
import { CreateTrainingBlockDto } from './dto/create-training-block.dto.js';
import { UpdateTrainingBlockDto } from './dto/update-training-block.dto.js';
import { TrainingBlockResponseDto } from './dto/training-block-response.dto.js';

@ApiTags('Training Blocks')
@ApiBearerAuth()
@Controller('training-blocks')
@UseGuards(JwtAuthGuard)
export class TrainingBlocksController {
  constructor(private readonly service: TrainingBlocksService) {}

  @Get()
  @ApiOperation({ summary: 'Get all training blocks for current user' })
  @ApiOkResponse({ type: [TrainingBlockResponseDto] })
  async findAll(@CurrentUser() user: User): Promise<TrainingBlockResponseDto[]> {
    return this.service.findAll(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a training block by ID' })
  @ApiParam({ name: 'id' })
  @ApiOkResponse({ type: TrainingBlockResponseDto })
  async findOne(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ): Promise<TrainingBlockResponseDto> {
    return this.service.findOne(user.id, id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new training block' })
  @ApiCreatedResponse({ type: TrainingBlockResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async create(
    @CurrentUser() user: User,
    @Body() dto: CreateTrainingBlockDto,
  ): Promise<TrainingBlockResponseDto> {
    return this.service.create(user.id, dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a training block' })
  @ApiParam({ name: 'id' })
  @ApiOkResponse({ type: TrainingBlockResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async update(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: UpdateTrainingBlockDto,
  ): Promise<TrainingBlockResponseDto> {
    return this.service.update(user.id, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a training block' })
  @ApiParam({ name: 'id' })
  @ApiNoContentResponse()
  async delete(@CurrentUser() user: User, @Param('id') id: string): Promise<void> {
    await this.service.delete(user.id, id);
  }
}
