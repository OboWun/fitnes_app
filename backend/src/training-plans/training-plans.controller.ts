import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  Query,
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
import { TrainingPlansService } from './training-plans.service.js';
import { CreateTrainingPlanDto } from './dto/create-plan.dto.js';
import { UpdateTrainingPlanDto } from './dto/update-plan.dto.js';
import { TrainingPlanResponseDto } from './dto/plan-response.dto.js';
import { AssignTemplateDto, UnassignTemplateDto } from './dto/assign-template.dto.js';
import { ReplaceSessionDto } from './dto/replace-session.dto.js';

@ApiTags('Training Plans')
@ApiBearerAuth()
@Controller('training-plans')
@UseGuards(JwtAuthGuard)
export class TrainingPlansController {
  constructor(private readonly service: TrainingPlansService) {}

  @Get()
  @ApiOperation({ summary: 'Get all training plans for current user' })
  @ApiOkResponse({ type: [TrainingPlanResponseDto] })
  async findAll(@CurrentUser() user: User): Promise<TrainingPlanResponseDto[]> {
    return this.service.findAll(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a training plan by ID' })
  @ApiParam({ name: 'id' })
  @ApiOkResponse({ type: TrainingPlanResponseDto })
  async findOne(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ): Promise<TrainingPlanResponseDto> {
    return this.service.findOne(user.id, id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new training plan' })
  @ApiCreatedResponse({ type: TrainingPlanResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async create(
    @CurrentUser() user: User,
    @Body() dto: CreateTrainingPlanDto,
  ): Promise<TrainingPlanResponseDto> {
    return this.service.create(user.id, dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a training plan (inactive only)' })
  @ApiParam({ name: 'id' })
  @ApiOkResponse({ type: TrainingPlanResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async update(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: UpdateTrainingPlanDto,
  ): Promise<TrainingPlanResponseDto> {
    return this.service.update(user.id, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a training plan (inactive only)' })
  @ApiParam({ name: 'id' })
  @ApiNoContentResponse()
  async delete(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ): Promise<void> {
    await this.service.delete(user.id, id);
  }

  @Post(':id/activate')
  @ApiOperation({ summary: 'Activate a training plan — creates TrainingPlanSession + first WorkoutSession' })
  @ApiParam({ name: 'id' })
  @ApiOkResponse({ type: TrainingPlanResponseDto })
  async activate(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ): Promise<TrainingPlanResponseDto> {
    return this.service.activate(user.id, id);
  }

  @Post(':id/archive')
  @ApiOperation({ summary: 'Archive an active training plan — removes planned sessions, keeps completed' })
  @ApiParam({ name: 'id' })
  @ApiOkResponse({ type: TrainingPlanResponseDto })
  async archive(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ): Promise<TrainingPlanResponseDto> {
    return this.service.archive(user.id, id);
  }

  @Post(':id/assign')
  @ApiOperation({ summary: 'Assign a workout template to a day in the plan' })
  @ApiParam({ name: 'id' })
  @ApiOkResponse({ type: TrainingPlanResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async assignTemplate(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: AssignTemplateDto,
  ): Promise<TrainingPlanResponseDto> {
    return this.service.assignTemplate(user.id, id, dto);
  }

  @Delete(':id/assign/:dayOfWeek')
  @ApiOperation({ summary: 'Unassign a workout template from a day in the plan' })
  @ApiParam({ name: 'id' })
  @ApiParam({ name: 'dayOfWeek' })
  @ApiOkResponse({ type: TrainingPlanResponseDto })
  async unassignTemplate(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Param('dayOfWeek') dayOfWeek: string,
  ): Promise<TrainingPlanResponseDto> {
    return this.service.unassignTemplate(user.id, id, dayOfWeek);
  }

  @Post('sessions/:sessionId/replace')
  @ApiOperation({ summary: 'Replace the workout template for a planned session' })
  @ApiParam({ name: 'sessionId' })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async replaceWorkout(
    @CurrentUser() user: User,
    @Param('sessionId') sessionId: string,
    @Body() dto: ReplaceSessionDto,
  ): Promise<void> {
    await this.service.replaceWorkout(user.id, sessionId, dto);
  }
}
