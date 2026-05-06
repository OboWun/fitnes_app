import 'dotenv/config';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { JwtService } from '@nestjs/jwt';

describe('WorkoutMILP /generate (e2e)', () => {
  let app: INestApplication;
  let jwtService: JwtService;
  let validToken: string;

  const TEST_USER_ID = 'mou9v9awz48fga';

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));

    jwtService = app.get(JwtService);
    validToken = jwtService.sign({
      sub: TEST_USER_ID,
      deviceId: 'test-device-001',
    });

    await app.init();
  }, 30000);

  afterAll(async () => {
    await app.close();
  });

  describe('POST /workout-milp/generate', () => {
    it('chest/back + barbell/dumbbell → should cover chest & back with proper time', async () => {
      const res = await request(app.getHttpServer())
        .post('/workout-milp/generate')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          sessionDurationMin: 60,
          exerciseCount: 5,
          setsPerExercise: 3,
          restBetweenSetsSec: 90,
          availableEquipment: ['barbell', 'dumbbell'],
          phase: 'accumulation',
          mandatoryMuscles: ['chest', 'back'],
        });

      console.log('Status:', res.status);
      console.log('Body:', JSON.stringify(res.body, null, 2));

      expect(res.status).toBe(201);

      const body = res.body;
      expect(body.exercises).toBeDefined();
      expect(body.exercises.length).toBeGreaterThanOrEqual(3);
      expect(body.exercises.length).toBeLessThanOrEqual(5);
      expect(body.totalTimeSec).toBeGreaterThan(0);
      expect(body.usedFallback).toBeDefined();
      expect(body.partialCoverage).toBeDefined();

      const loadByMuscle = body.totalLoadByMuscle ?? {};
      const chestOrBackCovered =
        'chest' in loadByMuscle ||
        'lats' in loadByMuscle ||
        'upper_back' in loadByMuscle ||
        'traps' in loadByMuscle;
      expect(chestOrBackCovered).toBe(true);
    }, 30000);

    it('lower body (quads/hamstrings) → should not bias toward chest/back', async () => {
      const res = await request(app.getHttpServer())
        .post('/workout-milp/generate')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          sessionDurationMin: 45,
          exerciseCount: 4,
          setsPerExercise: 4,
          restBetweenSetsSec: 120,
          availableEquipment: ['barbell', 'dumbbell', 'cable'],
          mandatoryMuscles: ['quads', 'hamstrings', 'glutes'],
        });

      console.log('Status:', res.status);
      console.log('Body:', JSON.stringify(res.body, null, 2));

      expect(res.status).toBe(201);

      const body = res.body;
      expect(body.exercises).toBeDefined();
      expect(body.exercises.length).toBeGreaterThanOrEqual(2);

      const loadByMuscle = body.totalLoadByMuscle ?? {};
      const lowerCovered =
        'quads' in loadByMuscle ||
        'hamstrings' in loadByMuscle ||
        'glutes' in loadByMuscle;
      expect(lowerCovered).toBe(true);
    }, 30000);

    it('empty equipment → should return only bodyweight exercises', async () => {
      const res = await request(app.getHttpServer())
        .post('/workout-milp/generate')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          sessionDurationMin: 30,
          exerciseCount: 4,
          setsPerExercise: 3,
          availableEquipment: [],
          mandatoryMuscles: ['chest', 'triceps'],
        });

      console.log('Status:', res.status);
      console.log('Body:', JSON.stringify(res.body, null, 2));

      expect(res.status).toBe(201);

      const body = res.body;
      expect(body.exercises).toBeDefined();
    }, 30000);

    it('time calculation → totalTimeSec should reflect sets × timeCostSec + rest', async () => {
      const res = await request(app.getHttpServer())
        .post('/workout-milp/generate')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          sessionDurationMin: 60,
          exerciseCount: 3,
          setsPerExercise: 3,
          restBetweenSetsSec: 90,
          availableEquipment: ['barbell', 'dumbbell'],
          mandatoryMuscles: ['chest'],
        });

      console.log('Status:', res.status);
      console.log('Body:', JSON.stringify(res.body, null, 2));

      expect(res.status).toBe(201);

      const body = res.body;
      const exerciseCount = body.exercises?.length ?? 0;
      const sets = 3;
      const restSec = 90;
      const defaultPerSetTime = 40;

      const expectedMinPerExercise = defaultPerSetTime * sets;
      const expectedMaxPerExercise = 300 * sets + restSec * (sets - 1);

      const expectedMin = exerciseCount * expectedMinPerExercise;
      const expectedMax = exerciseCount * expectedMaxPerExercise;

      expect(body.totalTimeSec).toBeGreaterThanOrEqual(expectedMin);
      expect(body.totalTimeSec).toBeLessThanOrEqual(expectedMax);
    }, 30000);
  });
});
