import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { WORKOUT_SESSIONS_REPOSITORY } from '../common/repositories/index.js';
import type { IWorkoutSessionsRepository } from '../common/repositories/index.js';
import type {
  WorkoutSession,
  WorkoutSessionExercise,
} from '../entities/index.js';
import type { CreateWorkoutSessionDto } from './dto/create-workout-session.dto.js';
import type { UpdateWorkoutSessionDto } from './dto/update-workout-session.dto.js';
import type {
  WorkoutSessionResponseDto,
  SessionExerciseResponseDto,
} from './dto/workout-session-response.dto.js';

@Injectable()
export class WorkoutSessionsService {
  constructor(
    @Inject(WORKOUT_SESSIONS_REPOSITORY)
    private readonly repository: IWorkoutSessionsRepository,
  ) {}

  async findByBlockId(blockId: string): Promise<WorkoutSessionResponseDto[]> {
    const sessions = await this.repository.findByBlockId(blockId);
    return sessions.map((s) => this.toResponseDto(s));
  }

  async findByUserId(userId: string): Promise<WorkoutSessionResponseDto[]> {
    const sessions = await this.repository.findByUserId(userId);
    return sessions.map((s) => this.toResponseDto(s));
  }

  async findOne(
    userId: string,
    id: string,
  ): Promise<WorkoutSessionResponseDto> {
    const session = await this.repository.findById(id);
    if (!session || session.userId !== userId) {
      throw new NotFoundException(`Workout session with id "${id}" not found`);
    }
    return this.toResponseDto(session);
  }

  async create(
    userId: string,
    dto: CreateWorkoutSessionDto,
  ): Promise<WorkoutSessionResponseDto> {
    const exercises: WorkoutSessionExercise[] | undefined = dto.exercises?.map(
      (e) => ({
        exerciseSlug: e.exerciseSlug,
        sets: e.sets,
        order: e.order,
        metadata: e.metadata,
      }),
    );

    const session = await this.repository.create({
      blockId: dto.blockId,
      userId,
      dayOfWeek: dto.dayOfWeek as WorkoutSession['dayOfWeek'],
      time: dto.time,
      status: dto.status as WorkoutSession['status'],
      metadata: dto.metadata,
      exercises,
    });
    return this.toResponseDto(session);
  }

  async update(
    userId: string,
    id: string,
    dto: UpdateWorkoutSessionDto,
  ): Promise<WorkoutSessionResponseDto> {
    const existing = await this.repository.findById(id);
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException(`Workout session with id "${id}" not found`);
    }

    const updateData: Partial<
      Omit<WorkoutSession, 'id' | 'userId' | 'blockId'>
    > & {
      exercises?: WorkoutSessionExercise[];
    } = {};
    if (dto.dayOfWeek !== undefined)
      updateData.dayOfWeek = dto.dayOfWeek as WorkoutSession['dayOfWeek'];
    if (dto.time !== undefined) updateData.time = dto.time;
    if (dto.status !== undefined)
      updateData.status = dto.status as WorkoutSession['status'];
    if (dto.metadata !== undefined) updateData.metadata = dto.metadata;
    if (dto.exercises !== undefined) {
      updateData.exercises = dto.exercises.map((e) => ({
        exerciseSlug: e.exerciseSlug,
        sets: e.sets,
        order: e.order,
        metadata: e.metadata,
      }));
    }

    const updated = await this.repository.update(id, updateData);
    return this.toResponseDto(updated!);
  }

  async delete(userId: string, id: string): Promise<void> {
    const existing = await this.repository.findById(id);
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException(`Workout session with id "${id}" not found`);
    }
    await this.repository.delete(id);
  }

  private toResponseDto(session: WorkoutSession): WorkoutSessionResponseDto {
    return {
      id: session.id,
      blockId: session.blockId,
      userId: session.userId,
      dayOfWeek: session.dayOfWeek,
      time: session.time,
      status: session.status,
      exercises: session.exercises?.map(
        (e): SessionExerciseResponseDto => ({
          exerciseSlug: e.exerciseSlug,
          sets: e.sets,
          order: e.order,
          metadata: e.metadata,
        }),
      ),
      metadata: session.metadata,
    };
  }
}
