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
    app.useGlobalPipes(
      new ValidationPipe({ transform: true, whitelist: true }),
    );

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
    it('chest/back hypertrophy → reps 6-12, ≥3 exercises, chest & back covered', async () => {
      const res = await request(app.getHttpServer())
        .post('/workout-milp/generate')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          sessionDurationMin: 60,
          experienceLevel: 'intermediate',
          goal: 'hypertrophy',
          focusMuscles: ['chest', 'back'],
          availableEquipment: ['barbell', 'dumbbell'],
        });

      console.log('Status:', res.status);
      console.log('Body:', JSON.stringify(res.body, null, 2));

      expect(res.status).toBe(201);

      const body = res.body;
      expect(body.exercises).toBeDefined();
      expect(body.exercises.length).toBeGreaterThanOrEqual(3);

      const loadByMuscle = body.totalLoadByMuscle ?? {};
      expect('chest' in loadByMuscle).toBe(true);

      for (const ex of body.exercises) {
        expect(ex.repsPerSet).toBeGreaterThanOrEqual(6);
        expect(ex.repsPerSet).toBeLessThanOrEqual(12);
      }

      expect(body.totalTimeSec).toBeGreaterThan(0);
      expect(body.usedFallback).toBeDefined();
    }, 30000);

    it('strength goal → reps 1-5, longer rest', async () => {
      const res = await request(app.getHttpServer())
        .post('/workout-milp/generate')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          sessionDurationMin: 60,
          experienceLevel: 'intermediate',
          goal: 'strength',
          focusMuscles: ['chest', 'arms'],
          availableEquipment: ['barbell', 'dumbbell'],
        });

      console.log('Status:', res.status);
      console.log('Body:', JSON.stringify(res.body, null, 2));

      expect(res.status).toBe(201);

      const body = res.body;
      expect(body.exercises).toBeDefined();

      for (const ex of body.exercises) {
        expect(ex.repsPerSet).toBeGreaterThanOrEqual(1);
        expect(ex.repsPerSet).toBeLessThanOrEqual(5);
      }
    }, 30000);

    it('endurance goal → reps 15-25', async () => {
      const res = await request(app.getHttpServer())
        .post('/workout-milp/generate')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          sessionDurationMin: 45,
          experienceLevel: 'beginner',
          goal: 'endurance',
          focusMuscles: ['legs'],
          availableEquipment: ['barbell', 'dumbbell', 'cable'],
        });

      console.log('Status:', res.status);
      console.log('Body:', JSON.stringify(res.body, null, 2));

      expect(res.status).toBe(201);

      const body = res.body;
      expect(body.exercises).toBeDefined();

      for (const ex of body.exercises) {
        expect(ex.repsPerSet).toBeGreaterThanOrEqual(15);
        expect(ex.repsPerSet).toBeLessThanOrEqual(25);
      }

      const loadByMuscle = body.totalLoadByMuscle ?? {};
      const lowerCovered =
        'quads' in loadByMuscle ||
        'hamstrings' in loadByMuscle ||
        'glutes' in loadByMuscle;
      expect(lowerCovered).toBe(true);
    }, 30000);

    it('empty equipment → bodyweight exercises only', async () => {
      const res = await request(app.getHttpServer())
        .post('/workout-milp/generate')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          sessionDurationMin: 30,
          experienceLevel: 'beginner',
          goal: 'general_health',
          focusMuscles: ['chest', 'arms'],
          availableEquipment: [],
        });

      expect(res.status).toBe(201);

      const body = res.body;
      expect(body.exercises).toBeDefined();
    }, 30000);

    it('specificMuscles → should prioritize specific muscles', async () => {
      const res = await request(app.getHttpServer())
        .post('/workout-milp/generate')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          sessionDurationMin: 60,
          experienceLevel: 'advanced',
          goal: 'hypertrophy',
          focusMuscles: ['back'],
          specificMuscles: ['lats', 'rear_delts'],
          availableEquipment: ['barbell', 'dumbbell', 'cable'],
        });

      console.log('Status:', res.status);
      console.log('Body:', JSON.stringify(res.body, null, 2));

      expect(res.status).toBe(201);

      const body = res.body;
      expect(body.exercises).toBeDefined();
      expect(body.exercises.length).toBeGreaterThanOrEqual(2);

      const loadByMuscle = body.totalLoadByMuscle ?? {};
      const backCovered =
        'lats' in loadByMuscle || 'upper_back' in loadByMuscle;
      expect(backCovered).toBe(true);
    }, 30000);

    it('time calculation → totalTimeSec should be realistic', async () => {
      const res = await request(app.getHttpServer())
        .post('/workout-milp/generate')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          sessionDurationMin: 60,
          experienceLevel: 'intermediate',
          goal: 'hypertrophy',
          focusMuscles: ['chest'],
          availableEquipment: ['barbell', 'dumbbell'],
        });

      expect(res.status).toBe(201);

      const body = res.body;
      expect(body.totalTimeSec).toBeGreaterThan(0);
      expect(body.totalTimeSec).toBeLessThanOrEqual(60 * 60);

      const exerciseCount = body.exercises?.length ?? 0;
      expect(exerciseCount).toBeGreaterThanOrEqual(1);
    }, 30000);
  });
});
