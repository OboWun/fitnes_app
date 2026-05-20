import { Inject, Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { WORKOUT_SESSIONS_REPOSITORY, type WorkoutSessionsFilter } from '../common/repositories/index.js';
import type { IWorkoutSessionsRepository } from '../common/repositories/index.js';
import type {
  WorkoutSession,
  WorkoutSessionExercise,
  WorkoutSessionSet,
} from '../entities/index.js';
import type { CreateWorkoutSessionDto } from './dto/create-workout-session.dto.js';
import type { UpdateWorkoutSessionDto } from './dto/update-workout-session.dto.js';
import type {
  WorkoutSessionResponseDto,
  SessionExerciseResponseDto,
} from './dto/workout-session-response.dto.js';
import type { CompleteSessionDto } from './dto/complete-session.dto.js';
import { SetPlannerService } from './set-planner.service.js';
import { TrainingPlansService } from '../training-plans/training-plans.service.js';

@Injectable()
export class WorkoutSessionsService {
  private readonly logger = new Logger(WorkoutSessionsService.name);

  constructor(
    @Inject(WORKOUT_SESSIONS_REPOSITORY)
    private readonly repository: IWorkoutSessionsRepository,
    private readonly plansService: TrainingPlansService,
    private readonly setPlanner: SetPlannerService,
  ) {}

  async findByPlanSessionId(planSessionId: string): Promise<WorkoutSessionResponseDto[]> {
    const sessions = await this.repository.findByPlanSessionId(planSessionId);
    return this.toResponseDtos(sessions);
  }

  async findByUserId(
    userId: string,
    filter?: WorkoutSessionsFilter,
  ): Promise<WorkoutSessionResponseDto[]> {
    const sessions = await this.repository.findByUserId(userId, filter);
    return this.toResponseDtos(sessions);
  }

  async findOne(
    userId: string,
    id: string,
  ): Promise<WorkoutSessionResponseDto> {
    const session = await this.repository.findById(id);
    if (!session || session.userId !== userId) {
      throw new NotFoundException(`Workout session with id "${id}" not found`);
    }
    return this.toResponseDto(session, await this.repository.getSetsBySession(id));
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
      planSessionId: dto.planSessionId,
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
      Omit<WorkoutSession, 'id' | 'userId' | 'planSessionId'>
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

  async complete(
    userId: string,
    sessionId: string,
    dto: CompleteSessionDto,
  ): Promise<WorkoutSessionResponseDto> {
    const session = await this.repository.findById(sessionId);
    if (!session || session.userId !== userId) {
      throw new NotFoundException(`Workout session with id "${sessionId}" not found`);
    }
    if (session.status !== 'planned') {
      throw new BadRequestException(`Session "${sessionId}" is not in planned status`);
    }
    if (!dto.sets?.length) {
      throw new BadRequestException('At least one actual set is required to complete a session');
    }

    await this.repository.completeSession(sessionId, dto.sets);

    try {
      await this.plansService.advanceAfterComplete(userId, sessionId);
    } catch (e) {
      this.logger.warn(`advanceAfterComplete failed for session ${sessionId}: ${(e as Error).message}`);
    }

    const completed = await this.repository.findById(sessionId);
    return this.toResponseDto(completed!, await this.repository.getSetsBySession(sessionId));
  }

  async skip(
    userId: string,
    sessionId: string,
    reschedule = false,
  ): Promise<WorkoutSessionResponseDto> {
    const session = await this.repository.findById(sessionId);
    if (!session || session.userId !== userId) {
      throw new NotFoundException(`Workout session with id "${sessionId}" not found`);
    }
    if (session.status !== 'planned') {
      throw new BadRequestException(`Session "${sessionId}" is not in planned status`);
    }

    await this.repository.skipSession(sessionId);

    if (reschedule) {
      await this.rescheduleSession(session);
    }

    const skipped = await this.repository.findById(sessionId);
    return this.toResponseDto(skipped!);
  }

  private async rescheduleSession(original: WorkoutSession): Promise<void> {
    const dayOrder = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    const currentIdx = dayOrder.indexOf(original.dayOfWeek as string);

    const existingSessions = await this.repository.findByPlanSessionId(original.planSessionId);
    const usedDays = new Set(existingSessions.map((s) => s.dayOfWeek as string));

    let nextDay: string | undefined;
    for (let offset = 1; offset <= 7; offset++) {
      const candidate = dayOrder[(currentIdx + offset) % 7];
      if (!usedDays.has(candidate)) {
        nextDay = candidate;
        break;
      }
    }

    if (!nextDay) return;

    const exercises = original.exercises?.map((e) => ({
      exerciseSlug: e.exerciseSlug,
      sets: e.sets,
      order: e.order,
      metadata: e.metadata,
    }));

    const rescheduled = await this.repository.create({
      planSessionId: original.planSessionId,
      userId: original.userId,
      dayOfWeek: nextDay as WorkoutSession['dayOfWeek'],
      time: original.time,
      status: 'planned',
      weekNumber: original.weekNumber,
      metadata: {
        ...original.metadata,
        rescheduledFrom: original.id,
      },
      exercises,
    });

    await this.setPlanner.planSetsForSession(rescheduled);
  }

  private async toResponseDtos(sessions: WorkoutSession[]): Promise<WorkoutSessionResponseDto[]> {
    const ids = sessions.map((s) => s.id);
    const setsMap = ids.length > 0
      ? await this.repository.getSetsBySessions(ids)
      : new Map<string, WorkoutSessionSet[]>();
    return sessions.map((s) => this.toResponseDto(s, setsMap.get(s.id)));
  }

  private toResponseDto(
    session: WorkoutSession,
    setDetails?: WorkoutSessionSet[],
  ): WorkoutSessionResponseDto {
    return {
      id: session.id,
      planSessionId: session.planSessionId,
      userId: session.userId,
      dayOfWeek: session.dayOfWeek,
      time: session.time,
      status: session.status,
      exercises: session.exercises?.map(
        (e): SessionExerciseResponseDto => {
          const exerciseSets = setDetails?.filter(
            (s) => s.exerciseSlug === e.exerciseSlug,
          );
          return {
            exerciseSlug: e.exerciseSlug,
            sets: e.sets,
            order: e.order,
            metadata: e.metadata,
            setDetails: exerciseSets?.map((s) => ({
              setNumber: s.setNumber,
              setType: s.setType,
              plannedWeightKg: s.plannedWeightKg,
              plannedReps: s.plannedReps,
              plannedDurationSec: s.plannedDurationSec,
              plannedDistanceM: s.plannedDistanceM,
              actualWeightKg: s.actualWeightKg,
              actualReps: s.actualReps,
              actualDurationSec: s.actualDurationSec,
              actualDistanceM: s.actualDistanceM,
              actualRpe: s.actualRpe,
              completedAt: s.completedAt,
            })),
          };
        },
      ),
      metadata: session.metadata,
    };
  }
}
