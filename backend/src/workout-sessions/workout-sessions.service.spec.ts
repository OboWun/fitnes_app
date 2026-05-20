import { Test, TestingModule } from '@nestjs/testing';
import { WorkoutSessionsService } from './workout-sessions.service.js';
import { WORKOUT_SESSIONS_REPOSITORY } from '../common/repositories/index.js';
import { SetPlannerService } from './set-planner.service.js';
import { TrainingPlansService } from '../training-plans/training-plans.service.js';
import { NotFoundException, BadRequestException } from '@nestjs/common';
import type { WorkoutSession, WorkoutSessionSet } from '../entities/index.js';

const mockSession: WorkoutSession = {
  id: 'ws-1',
  planSessionId: 'ps-1',
  userId: 'user-1',
  dayOfWeek: 'monday' as any,
  time: '18:00',
  weekNumber: 1,
  status: 'planned',
  exercises: [
    { exerciseSlug: 'bench-press', sets: 4, order: 1 },
    { exerciseSlug: 'overhead-press', sets: 3, order: 2 },
  ],
  metadata: { sessionType: 'push' },
};

const mockSets: WorkoutSessionSet[] = [
  {
    sessionId: 'ws-1',
    exerciseSlug: 'bench-press',
    setNumber: 1,
    setType: 'warmup',
    plannedWeightKg: 20,
    plannedReps: 15,
  },
  {
    sessionId: 'ws-1',
    exerciseSlug: 'bench-press',
    setNumber: 2,
    setType: 'working',
    plannedWeightKg: 60,
    plannedReps: 10,
  },
];

describe('WorkoutSessionsService', () => {
  let service: WorkoutSessionsService;
  let repo: any;
  let setPlanner: any;

  beforeEach(async () => {
    repo = {
      findByPlanSessionId: jest.fn().mockResolvedValue([mockSession]),
      findByUserId: jest.fn().mockResolvedValue([mockSession]),
      findById: jest.fn().mockResolvedValue(mockSession),
      create: jest.fn().mockResolvedValue(mockSession),
      update: jest.fn().mockResolvedValue(mockSession),
      delete: jest.fn().mockResolvedValue(true),
      planSets: jest.fn(),
      getSetsBySession: jest.fn().mockResolvedValue(mockSets),
      getSetsBySessions: jest.fn().mockResolvedValue(new Map([['ws-1', mockSets]])),
      completeSession: jest.fn(),
      findNextPlannedByUserId: jest.fn().mockResolvedValue(null),
      findStalePlanned: jest.fn().mockResolvedValue([]),
      skipSession: jest.fn(),
      findExerciseHistory: jest.fn().mockResolvedValue([]),
    };

    setPlanner = {
      planSetsForSession: jest.fn().mockResolvedValue(undefined),
    };

    const plansService = {
      advanceAfterComplete: jest.fn().mockResolvedValue(undefined),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WorkoutSessionsService,
        { provide: WORKOUT_SESSIONS_REPOSITORY, useValue: repo },
        { provide: TrainingPlansService, useValue: plansService },
        SetPlannerService,
      ],
    })
      .overrideProvider(SetPlannerService)
      .useValue(setPlanner)
      .compile();

    service = module.get<WorkoutSessionsService>(WorkoutSessionsService);
  });

  describe('findByPlanSessionId', () => {
    it('returns sessions for a plan session', async () => {
      const result = await service.findByPlanSessionId('ps-1');
      expect(result).toHaveLength(1);
      expect(result[0].id).toBe('ws-1');
      expect(result[0].exercises?.[0]?.setDetails).toBeDefined();
      expect(repo.findByPlanSessionId).toHaveBeenCalledWith('ps-1');
    });
  });

  describe('findByUserId', () => {
    it('returns sessions with filter', async () => {
      const result = await service.findByUserId('user-1', { limit: 10, status: ['completed'], sort: 'id_desc' });
      expect(result).toHaveLength(1);
      expect(repo.findByUserId).toHaveBeenCalledWith('user-1', { limit: 10, status: ['completed'], sort: 'id_desc' });
    });
  });

  describe('findOne', () => {
    it('returns session with setDetails', async () => {
      const result = await service.findOne('user-1', 'ws-1');
      expect(result.id).toBe('ws-1');
      expect(result.exercises?.[0]?.setDetails).toBeDefined();
    });

    it('throws if not found', async () => {
      repo.findById.mockResolvedValue(null);
      await expect(service.findOne('user-1', 'nonexistent')).rejects.toThrow(NotFoundException);
    });

    it('throws if belongs to different user', async () => {
      await expect(service.findOne('user-2', 'ws-1')).rejects.toThrow(NotFoundException);
    });
  });

  describe('create', () => {
    it('creates session with exercises', async () => {
      const dto = {
        planSessionId: 'ps-1',
        dayOfWeek: 'monday',
        time: '18:00',
        exercises: [{ exerciseSlug: 'squat', sets: 3, order: 1 }],
      };
      const result = await service.create('user-1', dto as any);
      expect(result).toBeDefined();
      expect(repo.create).toHaveBeenCalledWith(
        expect.objectContaining({
          planSessionId: 'ps-1',
          userId: 'user-1',
          dayOfWeek: 'monday',
        }),
      );
    });
  });

  describe('update', () => {
    it('updates session fields', async () => {
      const result = await service.update('user-1', 'ws-1', { time: '19:00' });
      expect(result).toBeDefined();
      expect(repo.update).toHaveBeenCalledWith('ws-1', expect.objectContaining({ time: '19:00' }));
    });

    it('throws if not found', async () => {
      repo.findById.mockResolvedValue(null);
      await expect(service.update('user-1', 'nonexistent', { time: '10:00' })).rejects.toThrow(NotFoundException);
    });
  });

  describe('delete', () => {
    it('deletes session', async () => {
      await service.delete('user-1', 'ws-1');
      expect(repo.delete).toHaveBeenCalledWith('ws-1');
    });

    it('throws if not found', async () => {
      repo.findById.mockResolvedValue(null);
      await expect(service.delete('user-1', 'nonexistent')).rejects.toThrow(NotFoundException);
    });
  });

  describe('complete', () => {
    it('completes session with actual data', async () => {
      repo.findNextPlannedByUserId.mockResolvedValue(undefined);

      const dto = {
        sets: [
          { exerciseSlug: 'bench-press', setNumber: 1, actualWeightKg: 20, actualReps: 15, actualRpe: 4 },
          { exerciseSlug: 'bench-press', setNumber: 2, actualWeightKg: 60, actualReps: 10, actualRpe: 7 },
        ],
      };

      const result = await service.complete('user-1', 'ws-1', dto as any);
      expect(result).toBeDefined();
      expect(repo.completeSession).toHaveBeenCalledWith(
        'ws-1',
        expect.arrayContaining([
          expect.objectContaining({ exerciseSlug: 'bench-press', setNumber: 1, actualWeightKg: 20, actualReps: 15 }),
        ]),
      );
    });

    it('throws if session not planned', async () => {
      repo.findById.mockResolvedValue({ ...mockSession, status: 'completed' });
      await expect(service.complete('user-1', 'ws-1', { sets: [{ exerciseSlug: 'x', setNumber: 1 }] } as any))
        .rejects.toThrow(BadRequestException);
    });

    it('throws if no actual sets provided', async () => {
      await expect(service.complete('user-1', 'ws-1', { sets: [] } as any))
        .rejects.toThrow(BadRequestException);
    });

    it('calls advanceAfterComplete after completing session', async () => {
      const dto = {
        sets: [{ exerciseSlug: 'bench-press', setNumber: 1, actualWeightKg: 60, actualReps: 10 }],
      };

      const module2 = await Test.createTestingModule({
        providers: [
          WorkoutSessionsService,
          { provide: WORKOUT_SESSIONS_REPOSITORY, useValue: repo },
          { provide: TrainingPlansService, useValue: { advanceAfterComplete: jest.fn().mockResolvedValue(undefined) } },
          SetPlannerService,
        ],
      })
        .overrideProvider(SetPlannerService)
        .useValue(setPlanner)
        .compile();

      const svc = module2.get<WorkoutSessionsService>(WorkoutSessionsService);
      const svcPlans = module2.get<TrainingPlansService>(TrainingPlansService);

      await svc.complete('user-1', 'ws-1', dto as any);
      expect(svcPlans.advanceAfterComplete).toHaveBeenCalledWith('user-1', 'ws-1');
    });
  });

  describe('skip', () => {
    it('skips session without reschedule', async () => {
      const result = await service.skip('user-1', 'ws-1', false);
      expect(result).toBeDefined();
      expect(repo.skipSession).toHaveBeenCalledWith('ws-1');
    });

    it('skips session with reschedule', async () => {
      repo.findByPlanSessionId.mockResolvedValue([mockSession]);

      const result = await service.skip('user-1', 'ws-1', true);
      expect(result).toBeDefined();
      expect(repo.skipSession).toHaveBeenCalledWith('ws-1');
      expect(repo.create).toHaveBeenCalled();
      expect(setPlanner.planSetsForSession).toHaveBeenCalled();
    });

    it('throws if session not planned', async () => {
      repo.findById.mockResolvedValue({ ...mockSession, status: 'completed' });
      await expect(service.skip('user-1', 'ws-1')).rejects.toThrow(BadRequestException);
    });
  });
});
