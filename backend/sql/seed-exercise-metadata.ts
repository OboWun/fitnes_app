import { Pool } from 'pg';

const DIFFICULTY_MAP: Record<string, number> = {
  beginner: 0.2,
  intermediate: 0.5,
  advanced: 0.8,
};

const EXERCISE_TYPE_FATIGUE: Record<string, number> = {
  strength: 7,
  hypertrophy: 5,
  endurance: 3,
  mobility: 1,
  stability: 2,
  cardio: 4,
  plyometric: 8,
  rehab: 1,
  stretching: 1,
};

const MOVEMENT_RISK: Record<string, number> = {
  hinge: 0.7,
  squat: 0.5,
  lunge: 0.6,
  jump: 0.8,
  push: 0.3,
  pull: 0.2,
  press: 0.3,
  row: 0.2,
  carry: 0.2,
  rotate: 0.4,
  anti_rotate: 0.3,
  crawl: 0.4,
  curl: 0.2,
  extension: 0.2,
  flexion: 0.3,
  abduction: 0.3,
  adduction: 0.3,
  rotation: 0.4,
  stabilization: 0.2,
  locomotion: 0.4,
  stretch: 0.1,
};

const MOVEMENT_JOINT_STRESS: Record<string, number> = {
  hinge: 7,
  squat: 5,
  lunge: 4,
  jump: 8,
  push: 3,
  pull: 2,
  press: 3,
  row: 2,
  carry: 2,
  rotate: 4,
  anti_rotate: 2,
  crawl: 3,
  curl: 2,
  extension: 2,
  flexion: 3,
  abduction: 3,
  adduction: 3,
  rotation: 4,
  stabilization: 2,
  locomotion: 3,
  stretch: 1,
};

const PHASE_AFFINITY: Record<string, string[]> = {
  strength: ['accumulation', 'intensification', 'realization'],
  hypertrophy: ['accumulation', 'intensification'],
  endurance: ['accumulation'],
  mobility: ['deload', 'transition'],
  stability: ['accumulation', 'deload'],
  cardio: ['accumulation'],
  plyometric: ['intensification', 'realization'],
  rehab: ['deload', 'transition'],
  stretching: ['deload', 'transition'],
};

const STRETCHING_EXERCISE_TYPES = new Set(['stretching', 'mobility']);

interface ExerciseRow {
  id: number;
  slug: string;
  exercise_type: string | null;
  difficulty: string | null;
  movement_pattern: string | null;
}

interface MuscleRelation {
  exercise_id: number;
  muscle_slug: string;
}

interface BodyPartRelation {
  exercise_id: number;
  bodypart_slug: string;
}

async function seedMetadata() {
  const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
  });

  try {
    const exercises = await pool.query<ExerciseRow>(
      `SELECT e.id, e.slug, e.exercise_type, e.difficulty, e.movement_pattern
       FROM exercises e`,
    );

    console.log(`Found ${exercises.rows.length} exercises to enrich.`);

    const targetMuscles = await pool.query<MuscleRelation>(
      `SELECT etm.exercise_id, m.slug AS muscle_slug
       FROM exercise_target_muscles etm
       JOIN muscles m ON m.id = etm.muscle_id`,
    );

    const secondaryMuscles = await pool.query<MuscleRelation>(
      `SELECT esm.exercise_id, m.slug AS muscle_slug
       FROM exercise_secondary_muscles esm
       JOIN muscles m ON m.id = esm.muscle_id`,
    );

    const bodyParts = await pool.query<BodyPartRelation>(
      `SELECT ebp.exercise_id, bp.slug AS bodypart_slug
       FROM exercise_body_parts ebp
       JOIN bodyparts bp ON bp.id = ebp.bodypart_id`,
    );

    const targetMap = new Map<number, string[]>();
    for (const r of targetMuscles.rows) {
      const arr = targetMap.get(r.exercise_id) ?? [];
      arr.push(r.muscle_slug);
      targetMap.set(r.exercise_id, arr);
    }

    const secondaryMap = new Map<number, string[]>();
    for (const r of secondaryMuscles.rows) {
      const arr = secondaryMap.get(r.exercise_id) ?? [];
      arr.push(r.muscle_slug);
      secondaryMap.set(r.exercise_id, arr);
    }

    const bodyPartMap = new Map<number, string[]>();
    for (const r of bodyParts.rows) {
      const arr = bodyPartMap.get(r.exercise_id) ?? [];
      arr.push(r.bodypart_slug);
      bodyPartMap.set(r.exercise_id, arr);
    }

    const batchSize = 50;
    for (let i = 0; i < exercises.rows.length; i += batchSize) {
      const batch = exercises.rows.slice(i, i + batchSize);
      const client = await pool.connect();

      try {
        await client.query('BEGIN');

        for (const ex of batch) {
          const difficulty = ex.difficulty ?? 'intermediate';
          const exerciseType = ex.exercise_type ?? 'strength';
          const movement = ex.movement_pattern ?? 'push';

          const complexityScore = DIFFICULTY_MAP[difficulty] ?? 0.5;
          const fatigueCost = EXERCISE_TYPE_FATIGUE[exerciseType] ?? 5;
          const riskLevel = MOVEMENT_RISK[movement] ?? 0.3;
          const jointStress = MOVEMENT_JOINT_STRESS[movement] ?? 3;

          const targetCount = targetMap.get(ex.id)?.length ?? 1;
          const timeCostSec = targetCount > 2 ? 300 : 120;

          const primaryMuscles = targetMap.get(ex.id) ?? [];
          const primaryMuscleWeights = primaryMuscles.map((slug, index) => ({
            slug,
            weight: index === 0 ? 1.0 : 0.85,
          }));

          const secMuscles = secondaryMap.get(ex.id) ?? [];
          const secondaryMuscleWeights = secMuscles.map((slug) => ({
            slug,
            weight: 0.2,
          }));

          const bpSlugs = bodyPartMap.get(ex.id) ?? [];
          const variationGroup = [movement, exerciseType, ...bpSlugs.slice(0, 1)]
            .filter(Boolean)
            .join('-');

          const phaseAffinity = PHASE_AFFINITY[exerciseType] ?? ['accumulation'];

          const isStretching = STRETCHING_EXERCISE_TYPES.has(exerciseType) || movement === 'stretch';

          const metadata = {
            complexityScore,
            fatigueCost: isStretching ? 1 : fatigueCost,
            timeCostSec,
            riskLevel: isStretching ? 0.05 : riskLevel,
            jointStress: isStretching ? 1 : jointStress,
            ...(primaryMuscleWeights.length > 0 ? { primaryMuscleWeights } : {}),
            ...(secondaryMuscleWeights.length > 0 ? { secondaryMuscleWeights } : {}),
            phaseAffinity,
            variationGroup,
          };

          await client.query(
            `UPDATE exercises SET metadata = $2 WHERE id = $1`,
            [ex.id, JSON.stringify(metadata)],
          );
        }

        await client.query('COMMIT');
        console.log(
          `  Batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(exercises.rows.length / batchSize)} done.`,
        );
      } catch (err) {
        await client.query('ROLLBACK');
        throw err;
      } finally {
        client.release();
      }
    }

    console.log(`Metadata seeded for ${exercises.rows.length} exercises.`);
    console.log('Seed-metadata completed successfully.');
  } catch (err) {
    console.error('Seed-metadata failed:', err);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

seedMetadata();
