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
import { WorkoutTemplatesService } from './workout-templates.service.js';
import { CreateWorkoutTemplateDto } from './dto/create-workout-template.dto.js';
import { UpdateWorkoutTemplateDto } from './dto/update-workout-template.dto.js';
import { WorkoutTemplateResponseDto } from './dto/workout-template-response.dto.js';
import {
  ScheduleWorkoutDto,
  UpdateScheduledWorkoutDto,
} from './dto/scheduled-workout.dto.js';
import { ScheduledWorkoutResponseDto } from './dto/scheduled-workout-response.dto.js';

@ApiTags('Workout Templates')
@ApiBearerAuth()
@Controller('workout-templates')
@UseGuards(JwtAuthGuard)
export class WorkoutTemplatesController {
  constructor(
    private readonly workoutTemplatesService: WorkoutTemplatesService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'Get all workout templates for current user' })
  @ApiOkResponse({
    type: [WorkoutTemplateResponseDto],
    description: 'List of workout templates',
  })
  findAll(@CurrentUser() user: User): WorkoutTemplateResponseDto[] {
    return this.workoutTemplatesService.findAll(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a workout template by ID' })
  @ApiParam({ name: 'id', description: 'Template ID' })
  @ApiOkResponse({
    type: WorkoutTemplateResponseDto,
    description: 'Workout template',
  })
  findOne(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ): WorkoutTemplateResponseDto {
    return this.workoutTemplatesService.findOne(user.id, id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new workout template' })
  @ApiCreatedResponse({
    type: WorkoutTemplateResponseDto,
    description: 'Created workout template',
  })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  create(
    @CurrentUser() user: User,
    @Body() dto: CreateWorkoutTemplateDto,
  ): WorkoutTemplateResponseDto {
    return this.workoutTemplatesService.create(user.id, dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a workout template' })
  @ApiParam({ name: 'id', description: 'Template ID' })
  @ApiOkResponse({
    type: WorkoutTemplateResponseDto,
    description: 'Updated workout template',
  })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  update(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: UpdateWorkoutTemplateDto,
  ): WorkoutTemplateResponseDto {
    return this.workoutTemplatesService.update(user.id, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a workout template' })
  @ApiParam({ name: 'id', description: 'Template ID' })
  @ApiNoContentResponse({ description: 'Template deleted' })
  delete(@CurrentUser() user: User, @Param('id') id: string): void {
    this.workoutTemplatesService.delete(user.id, id);
  }

  @Get('schedule/all')
  @ApiOperation({
    summary: 'Get scheduled workouts for current user',
  })
  @ApiOkResponse({
    type: [ScheduledWorkoutResponseDto],
    description: 'List of scheduled workouts',
  })
  getSchedule(@CurrentUser() user: User): ScheduledWorkoutResponseDto[] {
    return this.workoutTemplatesService.getSchedule(user.id);
  }

  @Post('schedule')
  @ApiOperation({ summary: 'Schedule a workout template to a day and time' })
  @ApiCreatedResponse({
    type: ScheduledWorkoutResponseDto,
    description: 'Created schedule entry',
  })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  scheduleWorkout(
    @CurrentUser() user: User,
    @Body() dto: ScheduleWorkoutDto,
  ): ScheduledWorkoutResponseDto {
    return this.workoutTemplatesService.scheduleWorkout(user.id, dto);
  }

  @Patch('schedule/:scheduleId')
  @ApiOperation({
    summary: 'Update a scheduled workout (change day/time/template)',
  })
  @ApiParam({ name: 'scheduleId', description: 'Schedule entry ID' })
  @ApiOkResponse({
    type: ScheduledWorkoutResponseDto,
    description: 'Updated schedule entry',
  })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  updateScheduledWorkout(
    @CurrentUser() user: User,
    @Param('scheduleId') scheduleId: string,
    @Body() dto: UpdateScheduledWorkoutDto,
  ): ScheduledWorkoutResponseDto {
    return this.workoutTemplatesService.updateScheduledWorkout(
      user.id,
      scheduleId,
      dto,
    );
  }

  @Delete('schedule/:scheduleId')
  @ApiOperation({ summary: 'Remove a scheduled workout' })
  @ApiParam({ name: 'scheduleId', description: 'Schedule entry ID' })
  @ApiNoContentResponse({ description: 'Schedule entry deleted' })
  deleteScheduledWorkout(
    @CurrentUser() user: User,
    @Param('scheduleId') scheduleId: string,
  ): void {
    this.workoutTemplatesService.deleteScheduledWorkout(user.id, scheduleId);
  }
}
