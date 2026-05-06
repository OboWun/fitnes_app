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
import { WorkoutSessionsService } from './workout-sessions.service.js';
import { CreateWorkoutSessionDto } from './dto/create-workout-session.dto.js';
import { UpdateWorkoutSessionDto } from './dto/update-workout-session.dto.js';
import { WorkoutSessionResponseDto } from './dto/workout-session-response.dto.js';

@ApiTags('Workout Sessions')
@ApiBearerAuth()
@Controller('workout-sessions')
@UseGuards(JwtAuthGuard)
export class WorkoutSessionsController {
  constructor(private readonly service: WorkoutSessionsService) {}

  @Get('block/:blockId')
  @ApiOperation({ summary: 'Get all sessions for a training block' })
  @ApiParam({ name: 'blockId' })
  @ApiOkResponse({ type: [WorkoutSessionResponseDto] })
  async findByBlockId(@Param('blockId') blockId: string): Promise<WorkoutSessionResponseDto[]> {
    return this.service.findByBlockId(blockId);
  }

  @Get()
  @ApiOperation({ summary: 'Get all workout sessions for current user' })
  @ApiOkResponse({ type: [WorkoutSessionResponseDto] })
  async findAll(@CurrentUser() user: User): Promise<WorkoutSessionResponseDto[]> {
    return this.service.findByUserId(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a workout session by ID' })
  @ApiParam({ name: 'id' })
  @ApiOkResponse({ type: WorkoutSessionResponseDto })
  async findOne(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ): Promise<WorkoutSessionResponseDto> {
    return this.service.findOne(user.id, id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new workout session' })
  @ApiCreatedResponse({ type: WorkoutSessionResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async create(
    @CurrentUser() user: User,
    @Body() dto: CreateWorkoutSessionDto,
  ): Promise<WorkoutSessionResponseDto> {
    return this.service.create(user.id, dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a workout session' })
  @ApiParam({ name: 'id' })
  @ApiOkResponse({ type: WorkoutSessionResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async update(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: UpdateWorkoutSessionDto,
  ): Promise<WorkoutSessionResponseDto> {
    return this.service.update(user.id, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a workout session' })
  @ApiParam({ name: 'id' })
  @ApiNoContentResponse()
  async delete(@CurrentUser() user: User, @Param('id') id: string): Promise<void> {
    await this.service.delete(user.id, id);
  }
}
