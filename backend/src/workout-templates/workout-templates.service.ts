import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import {
  WORKOUT_TEMPLATES_REPOSITORY,
  SCHEDULED_WORKOUTS_REPOSITORY,
} from '../common/repositories/index.js';
import type {
  IWorkoutTemplatesRepository,
  IScheduledWorkoutsRepository,
} from '../common/repositories/index.js';
import type {
  WorkoutTemplate,
  WorkoutExercise,
  ScheduledWorkout,
} from '../entities/index.js';
import type { CreateWorkoutTemplateDto } from './dto/create-workout-template.dto.js';
import type { UpdateWorkoutTemplateDto } from './dto/update-workout-template.dto.js';
import type { WorkoutTemplateResponseDto } from './dto/workout-template-response.dto.js';
import type {
  ScheduleWorkoutDto,
  UpdateScheduledWorkoutDto,
} from './dto/scheduled-workout.dto.js';
import type { ScheduledWorkoutResponseDto } from './dto/scheduled-workout-response.dto.js';

@Injectable()
export class WorkoutTemplatesService {
  constructor(
    @Inject(WORKOUT_TEMPLATES_REPOSITORY)
    private readonly templatesRepository: IWorkoutTemplatesRepository,
    @Inject(SCHEDULED_WORKOUTS_REPOSITORY)
    private readonly scheduledRepository: IScheduledWorkoutsRepository,
  ) {}

  async findAll(userId: string): Promise<WorkoutTemplateResponseDto[]> {
    const templates = await this.templatesRepository.findByUserId(userId);
    return templates.map((t) => this.toTemplateResponseDto(t));
  }

  async findOne(
    userId: string,
    id: string,
  ): Promise<WorkoutTemplateResponseDto> {
    const template = await this.templatesRepository.findById(id);
    if (!template || template.userId !== userId) {
      throw new NotFoundException(`Workout template with id "${id}" not found`);
    }
    return this.toTemplateResponseDto(template);
  }

  async create(
    userId: string,
    dto: CreateWorkoutTemplateDto,
  ): Promise<WorkoutTemplateResponseDto> {
    const exercises: WorkoutExercise[] = dto.exercises.map((e) => ({
      exerciseSlug: e.exerciseSlug,
      sets: e.sets,
      reps: e.reps,
      restBetweenSets: e.restBetweenSets,
      restAfterExercise: e.restAfterExercise,
      order: e.order,
    }));

    const template = await this.templatesRepository.create({
      userId,
      name: dto.name,
      description: dto.description,
      exercises,
    });
    return this.toTemplateResponseDto(template);
  }

  async update(
    userId: string,
    id: string,
    dto: UpdateWorkoutTemplateDto,
  ): Promise<WorkoutTemplateResponseDto> {
    const existing = await this.templatesRepository.findById(id);
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException(`Workout template with id "${id}" not found`);
    }

    const updateData: Partial<
      Omit<WorkoutTemplate, 'id' | 'userId' | 'createdAt' | 'updatedAt'>
    > = {};
    if (dto.name !== undefined) updateData.name = dto.name;
    if (dto.description !== undefined) updateData.description = dto.description;
    if (dto.exercises !== undefined) {
      updateData.exercises = dto.exercises.map((e) => ({
        exerciseSlug: e.exerciseSlug,
        sets: e.sets,
        reps: e.reps,
        restBetweenSets: e.restBetweenSets,
        restAfterExercise: e.restAfterExercise,
        order: e.order,
      }));
    }

    const updated = await this.templatesRepository.update(id, updateData);
    return this.toTemplateResponseDto(updated!);
  }

  async delete(userId: string, id: string): Promise<void> {
    const existing = await this.templatesRepository.findById(id);
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException(`Workout template with id "${id}" not found`);
    }
    await this.templatesRepository.delete(id);
  }

  async getSchedule(userId: string): Promise<ScheduledWorkoutResponseDto[]> {
    const scheduled = await this.scheduledRepository.findByUserId(userId);
    return scheduled.map((s) => this.toScheduledResponseDto(s));
  }

  async scheduleWorkout(
    userId: string,
    dto: ScheduleWorkoutDto,
  ): Promise<ScheduledWorkoutResponseDto> {
    const template = await this.templatesRepository.findById(dto.templateId);
    if (!template || template.userId !== userId) {
      throw new NotFoundException(
        `Workout template with id "${dto.templateId}" not found`,
      );
    }

    const scheduled = await this.scheduledRepository.create({
      templateId: dto.templateId,
      userId,
      dayOfWeek: dto.dayOfWeek,
      time: dto.time,
    });
    return this.toScheduledResponseDto(scheduled);
  }

  async updateScheduledWorkout(
    userId: string,
    scheduleId: string,
    dto: UpdateScheduledWorkoutDto,
  ): Promise<ScheduledWorkoutResponseDto> {
    const existing = await this.scheduledRepository.findById(scheduleId);
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException(
        `Scheduled workout with id "${scheduleId}" not found`,
      );
    }

    if (dto.templateId !== undefined) {
      const template = await this.templatesRepository.findById(dto.templateId);
      if (!template || template.userId !== userId) {
        throw new NotFoundException(
          `Workout template with id "${dto.templateId}" not found`,
        );
      }
    }

    const updateData: Partial<
      Omit<ScheduledWorkout, 'id' | 'userId' | 'createdAt'>
    > = {};
    if (dto.templateId !== undefined) updateData.templateId = dto.templateId;
    if (dto.dayOfWeek !== undefined) updateData.dayOfWeek = dto.dayOfWeek;
    if (dto.time !== undefined) updateData.time = dto.time;

    const updated = await this.scheduledRepository.update(
      scheduleId,
      updateData,
    );
    return this.toScheduledResponseDto(updated!);
  }

  async deleteScheduledWorkout(
    userId: string,
    scheduleId: string,
  ): Promise<void> {
    const existing = await this.scheduledRepository.findById(scheduleId);
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException(
        `Scheduled workout with id "${scheduleId}" not found`,
      );
    }
    await this.scheduledRepository.delete(scheduleId);
  }

  private toTemplateResponseDto(
    template: WorkoutTemplate,
  ): WorkoutTemplateResponseDto {
    return {
      id: template.id,
      userId: template.userId,
      name: template.name,
      description: template.description,
      exercises: template.exercises.map((e) => ({
        exerciseSlug: e.exerciseSlug,
        sets: e.sets,
        reps: e.reps,
        restBetweenSets: e.restBetweenSets,
        restAfterExercise: e.restAfterExercise,
        order: e.order,
      })),
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
    };
  }

  private toScheduledResponseDto(
    scheduled: ScheduledWorkout,
  ): ScheduledWorkoutResponseDto {
    return {
      id: scheduled.id,
      templateId: scheduled.templateId,
      userId: scheduled.userId,
      dayOfWeek: scheduled.dayOfWeek,
      time: scheduled.time,
      createdAt: scheduled.createdAt,
    };
  }
}
