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

  findAll(userId: string): WorkoutTemplateResponseDto[] {
    return this.templatesRepository
      .findByUserId(userId)
      .map((t) => this.toTemplateResponseDto(t));
  }

  findOne(userId: string, id: string): WorkoutTemplateResponseDto {
    const template = this.templatesRepository.findById(id);
    if (!template || template.userId !== userId) {
      throw new NotFoundException(`Workout template with id "${id}" not found`);
    }
    return this.toTemplateResponseDto(template);
  }

  create(
    userId: string,
    dto: CreateWorkoutTemplateDto,
  ): WorkoutTemplateResponseDto {
    const exercises: WorkoutExercise[] = dto.exercises.map((e) => ({
      exerciseSlug: e.exerciseSlug,
      sets: e.sets,
      reps: e.reps,
      restBetweenSets: e.restBetweenSets,
      restAfterExercise: e.restAfterExercise,
      order: e.order,
    }));

    const template = this.templatesRepository.create({
      userId,
      name: dto.name,
      description: dto.description,
      exercises,
    });
    return this.toTemplateResponseDto(template);
  }

  update(
    userId: string,
    id: string,
    dto: UpdateWorkoutTemplateDto,
  ): WorkoutTemplateResponseDto {
    const existing = this.templatesRepository.findById(id);
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

    const updated = this.templatesRepository.update(id, updateData);
    return this.toTemplateResponseDto(updated!);
  }

  delete(userId: string, id: string): void {
    const existing = this.templatesRepository.findById(id);
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException(`Workout template with id "${id}" not found`);
    }
    this.templatesRepository.delete(id);
  }

  getSchedule(userId: string): ScheduledWorkoutResponseDto[] {
    return this.scheduledRepository
      .findByUserId(userId)
      .map((s) => this.toScheduledResponseDto(s));
  }

  scheduleWorkout(
    userId: string,
    dto: ScheduleWorkoutDto,
  ): ScheduledWorkoutResponseDto {
    const template = this.templatesRepository.findById(dto.templateId);
    if (!template || template.userId !== userId) {
      throw new NotFoundException(
        `Workout template with id "${dto.templateId}" not found`,
      );
    }

    const scheduled = this.scheduledRepository.create({
      templateId: dto.templateId,
      userId,
      dayOfWeek: dto.dayOfWeek,
      time: dto.time,
    });
    return this.toScheduledResponseDto(scheduled);
  }

  updateScheduledWorkout(
    userId: string,
    scheduleId: string,
    dto: UpdateScheduledWorkoutDto,
  ): ScheduledWorkoutResponseDto {
    const existing = this.scheduledRepository.findById(scheduleId);
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException(
        `Scheduled workout with id "${scheduleId}" not found`,
      );
    }

    if (dto.templateId !== undefined) {
      const template = this.templatesRepository.findById(dto.templateId);
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

    const updated = this.scheduledRepository.update(scheduleId, updateData);
    return this.toScheduledResponseDto(updated!);
  }

  deleteScheduledWorkout(userId: string, scheduleId: string): void {
    const existing = this.scheduledRepository.findById(scheduleId);
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException(
        `Scheduled workout with id "${scheduleId}" not found`,
      );
    }
    this.scheduledRepository.delete(scheduleId);
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
