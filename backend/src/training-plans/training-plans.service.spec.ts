import { Test, TestingModule } from '@nestjs/testing';
import { TrainingPlansService } from './training-plans.service.js';
import { TRAINING_PLANS_REPOSITORY, WORKOUT_SESSIONS_REPOSITORY, WORKOUT_TEMPLATES_REPOSITORY, USERS_REPOSITORY } from '../common/repositories/index.js';
import { SetPlannerService } from '../workout-sessions/set-planner.service.js';
import { BadRequestException, NotFoundException } from '@nestjs/common';
import type { TrainingPlan, TrainingPlanSession, WorkoutSession } from '../entities/index.js';

const mockPlan: TrainingPlan = {
  id: 'plan-1',
  userId: 'user-1',
  name: 'Test Plan',
  isActive: false,
  source: 'manual',
  schedule: [
    { dayOfWeek: 'monday' as any, workoutTemplateId: 'tpl-push', time: '18:00', name: 'Push Day', sortOrder: 0 },
    { dayOfWeek: 'wednesday' as any, workoutTemplateId: 'tpl-pull', time: '18:00', name: 'Pull Day', sortOrder: 1 },
    { dayOfWeek: 'friday' as any, workoutTemplateId: 'tpl-legs', time: '10:00', name: 'Leg Day', sortOrder: 2 },
  ],
  createdAt: new Date().toISOString(),
};

const mockPlanNoSchedule: TrainingPlan = {
  id: 'plan-2',
  userId: 'user-1',
  name: 'Empty Plan',
  isActive: false,
  source: 'manual',
  schedule: [],
  createdAt: new Date().toISOString(),
};

const mockPlanSession: TrainingPlanSession = {
  id: 'ps-1',
  planId: 'plan-1',
  userId: 'user-1',
  startedAt: '2026-05-18',
  currentWeek: 1,
  status: 'active',
  createdAt: new Date().toISOString(),
};

describe('TrainingPlansService', () => {
  let service: TrainingPlansService;
  let plansRepo: any;
  let sessionsRepo: any;
  let setPlanner: any;

  beforeEach(async () => {
    plansRepo = {
      findByUserId: jest.fn().mockResolvedValue([mockPlan]),
      findById: jest.fn().mockResolvedValue(mockPlan),
      findActiveByUserId: jest.fn().mockResolvedValue(null),
      create: jest.fn().mockResolvedValue(mockPlan),
      update: jest.fn().mockResolvedValue(mockPlan),
      delete: jest.fn().mockResolvedValue(true),
      activate: jest.fn(),
      deactivateByUserId: jest.fn(),
      assignTemplate: jest.fn(),
      unassignTemplate: jest.fn(),
      createPlanSession: jest.fn().mockResolvedValue(mockPlanSession),
      findActivePlanSession: jest.fn().mockResolvedValue(null),
      updatePlanSessionWeek: jest.fn(),
      archivePlanSession: jest.fn(),
    };

    sessionsRepo = {
      findById: jest.fn().mockResolvedValue(null),
      create: jest.fn().mockResolvedValue({ id: 'ws-1', userId: 'user-1', planSessionId: 'ps-1', dayOfWeek: 'monday', status: 'planned', exercises: [] }),
      delete: jest.fn().mockResolvedValue(true),
      findByPlanSessionId: jest.fn().mockResolvedValue([]),
    };

    const templatesRepo = {
      findById: jest.fn().mockImplementation((id: string) => ({
        id,
        userId: 'user-1',
        name: `Template ${id}`,
        exercises: [
          { exerciseSlug: 'bench-press', sets: 3, reps: 10, order: 0 },
          { exerciseSlug: 'squat', sets: 4, reps: 8, order: 1 },
        ],
      })),
    };

    setPlanner = {
      planSetsForSession: jest.fn().mockResolvedValue(undefined),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TrainingPlansService,
        { provide: TRAINING_PLANS_REPOSITORY, useValue: plansRepo },
        { provide: WORKOUT_SESSIONS_REPOSITORY, useValue: sessionsRepo },
        { provide: WORKOUT_TEMPLATES_REPOSITORY, useValue: templatesRepo },
        { provide: USERS_REPOSITORY, useValue: { findById: jest.fn().mockResolvedValue({ id: 'user-1', weight: 70 }) } },
        SetPlannerService,
      ],
    })
      .overrideProvider(SetPlannerService)
      .useValue(setPlanner)
      .compile();

    service = module.get<TrainingPlansService>(TrainingPlansService);
  });

  describe('findAll', () => {
    it('returns all plans for user', async () => {
      const result = await service.findAll('user-1');
      expect(result).toHaveLength(1);
      expect(result[0].id).toBe('plan-1');
      expect(result[0].schedule).toHaveLength(3);
      expect(plansRepo.findByUserId).toHaveBeenCalledWith('user-1');
    });
  });

  describe('findOne', () => {
    it('returns plan by id', async () => {
      const result = await service.findOne('user-1', 'plan-1');
      expect(result.id).toBe('plan-1');
    });

    it('throws if plan not found', async () => {
      plansRepo.findById.mockResolvedValue(null);
      await expect(service.findOne('user-1', 'nonexistent')).rejects.toThrow(NotFoundException);
    });

    it('throws if plan belongs to different user', async () => {
      await expect(service.findOne('user-2', 'plan-1')).rejects.toThrow(NotFoundException);
    });
  });

  describe('create', () => {
    it('creates a plan with schedule', async () => {
      const dto = {
        name: 'My Plan',
        schedule: [
          { dayOfWeek: 'monday', workoutTemplateId: 'tpl-1', name: 'Push' },
          { dayOfWeek: 'friday', workoutTemplateId: 'tpl-2', name: 'Legs' },
        ],
      };
      const result = await service.create('user-1', dto as any);
      expect(result).toBeDefined();
      expect(plansRepo.create).toHaveBeenCalledWith(
        expect.objectContaining({
          userId: 'user-1',
          name: 'My Plan',
          isActive: false,
          source: 'manual',
          schedule: expect.arrayContaining([
            expect.objectContaining({ dayOfWeek: 'monday', workoutTemplateId: 'tpl-1', name: 'Push', sortOrder: 0 }),
            expect.objectContaining({ dayOfWeek: 'friday', workoutTemplateId: 'tpl-2', name: 'Legs', sortOrder: 1 }),
          ]),
        }),
      );
    });

    it('creates plan without schedule', async () => {
      const dto = { name: 'Empty' };
      const result = await service.create('user-1', dto as any);
      expect(result).toBeDefined();
      expect(plansRepo.create).toHaveBeenCalledWith(
        expect.objectContaining({ name: 'Empty', isActive: false }),
      );
    });
  });

  describe('update', () => {
    it('updates name', async () => {
      const result = await service.update('user-1', 'plan-1', { name: 'Updated' });
      expect(result).toBeDefined();
      expect(plansRepo.update).toHaveBeenCalledWith('plan-1', expect.objectContaining({ name: 'Updated' }));
    });

    it('updates name for active plan (no schedule change)', async () => {
      plansRepo.findById.mockResolvedValue({ ...mockPlan, isActive: true });
      plansRepo.update.mockResolvedValue({ ...mockPlan, isActive: true, name: 'X' });
      const result = await service.update('user-1', 'plan-1', { name: 'X' });
      expect(result).toBeDefined();
      expect(plansRepo.update).toHaveBeenCalledWith('plan-1', expect.objectContaining({ name: 'X' }));
      expect(sessionsRepo.delete).not.toHaveBeenCalled();
    });

    it('updates schedule for active plan and recreates planned sessions', async () => {
      const activePlan = { ...mockPlan, isActive: true };
      const updatedPlan = {
        ...activePlan,
        schedule: [
          { dayOfWeek: 'tuesday', workoutTemplateId: 'tpl-new', time: '09:00', name: 'New Day', sortOrder: 0 },
        ],
      };
      plansRepo.findById.mockResolvedValue(activePlan);
      plansRepo.update.mockResolvedValue(updatedPlan);
      plansRepo.findActivePlanSession.mockResolvedValue(mockPlanSession);
      sessionsRepo.findByPlanSessionId.mockResolvedValue([
        { id: 'ws-old-1', status: 'planned' },
        { id: 'ws-old-2', status: 'completed' },
      ]);

      const result = await service.update('user-1', 'plan-1', {
        schedule: [{ dayOfWeek: 'tuesday', workoutTemplateId: 'tpl-new', name: 'New Day' }],
      } as any);

      expect(result).toBeDefined();
      expect(sessionsRepo.delete).toHaveBeenCalledWith('ws-old-1');
      expect(sessionsRepo.delete).not.toHaveBeenCalledWith('ws-old-2');
      expect(sessionsRepo.create).toHaveBeenCalled();
      expect(setPlanner.planSetsForSession).toHaveBeenCalled();
    });

    it('throws if plan not found', async () => {
      plansRepo.findById.mockResolvedValue(null);
      await expect(service.update('user-1', 'nonexistent', { name: 'X' })).rejects.toThrow(NotFoundException);
    });
  });

  describe('delete', () => {
    it('deletes inactive plan', async () => {
      await service.delete('user-1', 'plan-1');
      expect(plansRepo.delete).toHaveBeenCalledWith('plan-1');
    });

    it('throws if plan is active', async () => {
      plansRepo.findById.mockResolvedValue({ ...mockPlan, isActive: true });
      await expect(service.delete('user-1', 'plan-1')).rejects.toThrow(BadRequestException);
    });
  });

  describe('activate', () => {
    it('activates plan and creates plan session + all week workout sessions', async () => {
      const result = await service.activate('user-1', 'plan-1');
      expect(result).toBeDefined();
      expect(plansRepo.deactivateByUserId).toHaveBeenCalledWith('user-1');
      expect(plansRepo.activate).toHaveBeenCalledWith('plan-1');
      expect(plansRepo.createPlanSession).toHaveBeenCalledWith(
        expect.objectContaining({
          planId: 'plan-1',
          userId: 'user-1',
          currentWeek: 1,
          status: 'active',
        }),
      );
      expect(sessionsRepo.create).toHaveBeenCalledTimes(3);
      expect(setPlanner.planSetsForSession).toHaveBeenCalledTimes(1);
    });

    it('throws if plan already active', async () => {
      plansRepo.findById.mockResolvedValue({ ...mockPlan, isActive: true });
      await expect(service.activate('user-1', 'plan-1')).rejects.toThrow(BadRequestException);
    });

    it('throws if plan has no schedule', async () => {
      plansRepo.findById.mockResolvedValue(mockPlanNoSchedule);
      await expect(service.activate('user-1', 'plan-2')).rejects.toThrow(BadRequestException);
    });

    it('deactivates previous active plan before activating new one', async () => {
      await service.activate('user-1', 'plan-1');
      expect(plansRepo.deactivateByUserId).toHaveBeenCalledWith('user-1');
      expect(plansRepo.activate).toHaveBeenCalledWith('plan-1');
    });
  });

  describe('archive', () => {
    it('archives active plan', async () => {
      plansRepo.findActivePlanSession.mockResolvedValue(mockPlanSession);
      const result = await service.archive('user-1', 'plan-1');
      expect(result).toBeDefined();
      expect(plansRepo.deactivateByUserId).toHaveBeenCalledWith('user-1');
      expect(plansRepo.archivePlanSession).toHaveBeenCalledWith('ps-1');
    });

    it('works even without active plan session', async () => {
      plansRepo.findActivePlanSession.mockResolvedValue(undefined);
      const result = await service.archive('user-1', 'plan-1');
      expect(result).toBeDefined();
      expect(plansRepo.archivePlanSession).not.toHaveBeenCalled();
    });
  });

  describe('assignTemplate', () => {
    it('assigns template to day', async () => {
      const dto = { dayOfWeek: 'tuesday', workoutTemplateId: 'tpl-new', name: 'Arms Day' };
      const result = await service.assignTemplate('user-1', 'plan-1', dto as any);
      expect(result).toBeDefined();
      expect(plansRepo.assignTemplate).toHaveBeenCalledWith(
        'plan-1', 'tuesday', 'tpl-new', undefined, 'Arms Day',
      );
    });
  });

  describe('unassignTemplate', () => {
    it('removes template from day', async () => {
      const result = await service.unassignTemplate('user-1', 'plan-1', 'monday');
      expect(result).toBeDefined();
      expect(plansRepo.unassignTemplate).toHaveBeenCalledWith('plan-1', 'monday');
    });
  });

  describe('replaceWorkout', () => {
    it('replaces planned session', async () => {
      const mockSession: Partial<WorkoutSession> = {
        id: 'ws-1',
        userId: 'user-1',
        planSessionId: 'ps-1',
        dayOfWeek: 'monday' as any,
        status: 'planned',
      };
      sessionsRepo.findById.mockResolvedValue(mockSession);
      plansRepo.findActivePlanSession.mockResolvedValue(mockPlanSession);
      plansRepo.findById.mockResolvedValueOnce(mockPlan).mockResolvedValueOnce({ ...mockPlan, isActive: true });

      await service.replaceWorkout('user-1', 'ws-1', { workoutTemplateId: 'tpl-replacement', name: 'Replacement' });
      expect(sessionsRepo.delete).toHaveBeenCalledWith('ws-1');
    });

    it('throws if session not planned', async () => {
      sessionsRepo.findById.mockResolvedValue({ id: 'ws-1', userId: 'user-1', status: 'completed' });
      await expect(service.replaceWorkout('user-1', 'ws-1', { workoutTemplateId: 'tpl-x' })).rejects.toThrow(BadRequestException);
    });

    it('throws if session not found', async () => {
      sessionsRepo.findById.mockResolvedValue(null);
      await expect(service.replaceWorkout('user-1', 'ws-1', { workoutTemplateId: 'tpl-x' })).rejects.toThrow(NotFoundException);
    });
  });

  describe('advanceAfterComplete', () => {
    it('runs SetPlanner on existing next planned session (same week)', async () => {
      const completed: Partial<WorkoutSession> = {
        id: 'ws-1', userId: 'user-1', dayOfWeek: 'monday' as any, status: 'completed',
      };
      const nextPlanned: Partial<WorkoutSession> = {
        id: 'ws-next', userId: 'user-1', dayOfWeek: 'wednesday' as any, status: 'planned',
      };
      sessionsRepo.findById.mockResolvedValue(completed);
      sessionsRepo.findByPlanSessionId.mockResolvedValue([completed as any, nextPlanned as any]);
      plansRepo.findActivePlanSession.mockResolvedValue({ ...mockPlanSession, currentWeek: 1 });
      plansRepo.findById.mockResolvedValue(mockPlan);

      await service.advanceAfterComplete('user-1', 'ws-1');
      expect(setPlanner.planSetsForSession).toHaveBeenCalledWith(expect.objectContaining({ id: 'ws-next' }));
      expect(sessionsRepo.create).not.toHaveBeenCalled();
    });

    it('increments week and creates all sessions for new week', async () => {
      const completed: Partial<WorkoutSession> = {
        id: 'ws-1', userId: 'user-1', dayOfWeek: 'friday' as any, status: 'completed',
      };
      sessionsRepo.findById.mockResolvedValue(completed);
      plansRepo.findActivePlanSession.mockResolvedValue({ ...mockPlanSession, currentWeek: 1 });
      plansRepo.findById.mockResolvedValue(mockPlan);

      await service.advanceAfterComplete('user-1', 'ws-1');
      expect(plansRepo.updatePlanSessionWeek).toHaveBeenCalledWith('ps-1', 2);
      expect(sessionsRepo.create).toHaveBeenCalledTimes(3);
      expect(setPlanner.planSetsForSession).toHaveBeenCalledTimes(1);
    });

    it('archives plan session after 4 weeks', async () => {
      const completed: Partial<WorkoutSession> = {
        id: 'ws-1', userId: 'user-1', dayOfWeek: 'friday' as any, status: 'completed',
      };
      sessionsRepo.findById.mockResolvedValue(completed);
      plansRepo.findActivePlanSession.mockResolvedValue({ ...mockPlanSession, currentWeek: 4 });
      plansRepo.findById.mockResolvedValue(mockPlan);

      await service.advanceAfterComplete('user-1', 'ws-1');
      expect(plansRepo.archivePlanSession).toHaveBeenCalledWith('ps-1');
    });

    it('does nothing if no active plan session', async () => {
      sessionsRepo.findById.mockResolvedValue({ id: 'ws-1', userId: 'user-1' });
      plansRepo.findActivePlanSession.mockResolvedValue(undefined);
      await service.advanceAfterComplete('user-1', 'ws-1');
      expect(sessionsRepo.create).not.toHaveBeenCalled();
    });
  });
});
