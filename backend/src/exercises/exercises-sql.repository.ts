import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type { Exercise, ExerciseMetadata } from '../entities/index.js';
import type {
  IExercisesRepository,
  ExerciseFilterParams,
  PaginatedResult,
  ExerciseMILPData,
} from '../common/repositories/index.js';

interface ExerciseRow {
  exercise_id: string;
  name: string;
  slug: string;
  gif_url: string;
  instructions: string[];
  alias: string[] | null;
  exercise_type: string | null;
  description: string | null;
  confidence: number | null;
  difficulty: string | null;
  movement_pattern: string | null;
  variations: string[] | null;
  metadata: ExerciseMetadata | null;
}

@Injectable()
export class ExercisesSqlRepository implements IExercisesRepository {
  constructor(private readonly db: DatabaseService) {}

  async findPaginated(
    page: number,
    limit: number,
    filters?: ExerciseFilterParams,
  ): Promise<PaginatedResult<Exercise>> {
    const { where, params } = this.buildWhere(filters);
    const offset = (page - 1) * limit;

    const countRow = await this.db.queryOne<{ total: string }>(
      `SELECT COUNT(DISTINCT e.id)::text AS total FROM exercises e ${where}`,
      params,
    );
    const total = parseInt(countRow?.total ?? '0', 10);

    const rows = await this.db.query<ExerciseRow>(
      `SELECT e.exercise_id, e.name, e.slug, e.gif_url, e.instructions, e.alias,
              e.exercise_type, e.description, e.confidence, e.difficulty,
              e.movement_pattern, e.variations, e.metadata
       FROM exercises e ${where}
       ORDER BY e.name
       LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
      [...params, limit, offset],
    );

    const exercises = await Promise.all(rows.map((r) => this.toExercise(r)));
    return { data: exercises, total };
  }

  async findBySlug(slug: string): Promise<Exercise | undefined> {
    const row = await this.db.queryOne<ExerciseRow>(
      `SELECT exercise_id, name, slug, gif_url, instructions, alias,
              exercise_type, description, confidence, difficulty,
              movement_pattern, variations, metadata
       FROM exercises WHERE slug = $1`,
      [slug],
    );
    if (!row) return undefined;
    return this.toExercise(row);
  }

  async findSimilar(
    slug: string,
    page: number,
    limit: number,
  ): Promise<PaginatedResult<Exercise>> {
    const offset = (page - 1) * limit;

    const countRow = await this.db.queryOne<{ total: string }>(
      `SELECT COUNT(DISTINCT e.id)::text AS total
       FROM exercises e
       WHERE e.slug != $1
         AND EXISTS (
           SELECT 1 FROM exercise_target_muscles etm
           WHERE etm.exercise_id = e.id
             AND etm.muscle_id IN (
               SELECT etm2.muscle_id FROM exercise_target_muscles etm2
               JOIN exercises e2 ON e2.id = etm2.exercise_id
               WHERE e2.slug = $1
             )
         )`,
      [slug],
    );
    const total = parseInt(countRow?.total ?? '0', 10);

    const rows = await this.db.query<ExerciseRow>(
      `SELECT e.exercise_id, e.name, e.slug, e.gif_url, e.instructions, e.alias,
              e.exercise_type, e.description, e.confidence, e.difficulty,
              e.movement_pattern, e.variations, e.metadata
       FROM exercises e
       WHERE e.slug != $1
         AND EXISTS (
           SELECT 1 FROM exercise_target_muscles etm
           WHERE etm.exercise_id = e.id
             AND etm.muscle_id IN (
               SELECT etm2.muscle_id FROM exercise_target_muscles etm2
               JOIN exercises e2 ON e2.id = etm2.exercise_id
               WHERE e2.slug = $1
             )
         )
       ORDER BY e.name
       LIMIT $2 OFFSET $3`,
      [slug, limit, offset],
    );

    const exercises = await Promise.all(rows.map((r) => this.toExercise(r)));
    return { data: exercises, total };
  }

  async findAntagonist(
    slug: string,
    antagonistMuscles: string[],
    page: number,
    limit: number,
  ): Promise<PaginatedResult<Exercise>> {
    if (!antagonistMuscles.length) {
      return { data: [], total: 0 };
    }

    const offset = (page - 1) * limit;
    const muscleSlugs = antagonistMuscles.map((m) => m.toLowerCase());

    const countRow = await this.db.queryOne<{ total: string }>(
      `SELECT COUNT(DISTINCT e.id)::text AS total
       FROM exercises e
       WHERE e.slug != $1
         AND EXISTS (
           SELECT 1 FROM exercise_target_muscles etm
           JOIN muscles m ON m.id = etm.muscle_id
           WHERE etm.exercise_id = e.id
             AND LOWER(m.slug) = ANY($2::text[])
         )`,
      [slug, muscleSlugs],
    );
    const total = parseInt(countRow?.total ?? '0', 10);

    const rows = await this.db.query<ExerciseRow>(
      `SELECT e.exercise_id, e.name, e.slug, e.gif_url, e.instructions, e.alias,
              e.exercise_type, e.description, e.confidence, e.difficulty,
              e.movement_pattern, e.variations, e.metadata
       FROM exercises e
       WHERE e.slug != $1
         AND EXISTS (
           SELECT 1 FROM exercise_target_muscles etm
           JOIN muscles m ON m.id = etm.muscle_id
           WHERE etm.exercise_id = e.id
             AND LOWER(m.slug) = ANY($2::text[])
         )
       ORDER BY e.name
       LIMIT $3 OFFSET $4`,
      [slug, muscleSlugs, limit, offset],
    );

    const exercises = await Promise.all(rows.map((r) => this.toExercise(r)));
    return { data: exercises, total };
  }

  private buildWhere(
    filters?: ExerciseFilterParams,
  ): { where: string; params: unknown[] } {
    const conditions: string[] = [];
    const params: unknown[] = [];
    let idx = 1;

    if (filters?.contraindications?.length) {
      conditions.push(
        `NOT EXISTS (
          SELECT 1 FROM exercise_contraindications ec
          JOIN contraindications c ON c.id = ec.contraindication_id
          WHERE ec.exercise_id = e.id AND c.slug = ANY($${idx}::text[])
        )`,
      );
      params.push(filters.contraindications);
      idx++;
    }

    if (filters?.equipments?.length) {
      conditions.push(
        `EXISTS (
          SELECT 1 FROM exercise_equipments ee
          JOIN equipments eq ON eq.id = ee.equipment_id
          WHERE ee.exercise_id = e.id AND eq.slug = ANY($${idx}::text[])
        )`,
      );
      params.push(filters.equipments);
      idx++;
    }

    if (filters?.targetMuscles?.length) {
      conditions.push(
        `EXISTS (
          SELECT 1 FROM exercise_target_muscles etm
          JOIN muscles m ON m.id = etm.muscle_id
          WHERE etm.exercise_id = e.id AND m.slug = ANY($${idx}::text[])
        )`,
      );
      params.push(filters.targetMuscles);
      idx++;
    }

    if (filters?.search) {
      conditions.push(`e.name ILIKE '%' || $${idx} || '%'`);
      params.push(filters.search);
      idx++;
    }

    const where =
      conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
    return { where, params };
  }

  private async toExercise(row: ExerciseRow): Promise<Exercise> {
    const [targetMuscles, secondaryMuscles, bodyParts, equipments, contraindications] =
      await Promise.all([
        this.getRelations(
          'exercise_target_muscles etm JOIN muscles m ON m.id = etm.muscle_id',
          'm.name, m.slug',
          'etm.exercise_id',
          row.slug,
        ),
        this.getRelations(
          'exercise_secondary_muscles esm JOIN muscles m ON m.id = esm.muscle_id',
          'm.name, m.slug',
          'esm.exercise_id',
          row.slug,
        ),
        this.getRelations(
          'exercise_body_parts ebp JOIN bodyparts bp ON bp.id = ebp.bodypart_id',
          'bp.name, bp.slug',
          'ebp.exercise_id',
          row.slug,
        ),
        this.getRelations(
          'exercise_equipments ee JOIN equipments eq ON eq.id = ee.equipment_id',
          'eq.name, eq.slug',
          'ee.exercise_id',
          row.slug,
        ),
        this.getContraindications(row.slug),
      ]);

    return {
      exerciseId: row.exercise_id,
      name: row.name,
      slug: row.slug,
      gifUrl: row.gif_url,
      targetMuscles: targetMuscles.map((r: { name: string; slug: string }) => r.slug),
      bodyParts: bodyParts.map((r: { name: string; slug: string }) => r.slug),
      equipments: equipments.map((r: { name: string; slug: string }) => r.slug),
      secondaryMuscles: secondaryMuscles.map((r: { name: string; slug: string }) => r.slug) || undefined,
      instructions: row.instructions || [],
      contraindications: contraindications || undefined,
      alias: row.alias || undefined,
      exerciseType: (row.exercise_type as Exercise['exerciseType']) || undefined,
      description: row.description || undefined,
      confidence: row.confidence !== null ? Number(row.confidence) : undefined,
      difficulty: (row.difficulty as Exercise['difficulty']) || undefined,
      movementPattern: (row.movement_pattern as Exercise['movementPattern']) || undefined,
      variations: row.variations || undefined,
      metadata: row.metadata || undefined,
    };
  }

  private async getRelations(
    join: string,
    select: string,
    exerciseIdCol: string,
    slug: string,
  ): Promise<{ name: string; slug: string }[]> {
    return this.db.query<{ name: string; slug: string }>(
      `SELECT ${select}
       FROM ${join}
       WHERE ${exerciseIdCol} = (SELECT id FROM exercises WHERE slug = $1)`,
      [slug],
    );
  }

  private async getContraindications(
    slug: string,
  ): Promise<{ slug: string; severity: 'forbidden' | 'not_recommended' | 'low_weight' }[]> {
    return this.db.query<{
      slug: string;
      severity: 'forbidden' | 'not_recommended' | 'low_weight';
    }>(
      `SELECT c.slug, ec.severity
       FROM exercise_contraindications ec
       JOIN contraindications c ON c.id = ec.contraindication_id
       WHERE ec.exercise_id = (SELECT id FROM exercises WHERE slug = $1)`,
      [slug],
    );
  }

  async findForMILP(page: number, limit: number): Promise<PaginatedResult<ExerciseMILPData>> {
    const offset = (page - 1) * limit;

    const countRow = await this.db.queryOne<{ total: string }>(
      `SELECT COUNT(*)::text AS total FROM exercises`,
      [],
    );
    const total = parseInt(countRow?.total ?? '0', 10);

    interface MILPRow {
      slug: string;
      exercise_type: string | null;
      movement_pattern: string | null;
      metadata: ExerciseMetadata | null;
      equipments: { slug: string }[];
      contraindications: { slug: string; severity: string }[];
    }

    const rows = await this.db.query<MILPRow>(
      `SELECT 
         e.slug,
         e.exercise_type,
         e.movement_pattern,
         e.metadata,
         COALESCE(
           (SELECT json_agg(json_build_object('slug', eq.slug))
            FROM exercise_equipments ee
            JOIN equipments eq ON eq.id = ee.equipment_id
            WHERE ee.exercise_id = e.id),
           '[]'::json
         ) as equipments,
         COALESCE(
           (SELECT json_agg(json_build_object('slug', c.slug, 'severity', ec.severity))
            FROM exercise_contraindications ec
            JOIN contraindications c ON c.id = ec.contraindication_id
            WHERE ec.exercise_id = e.id),
           '[]'::json
         ) as contraindications
       FROM exercises e
       ORDER BY e.slug
       LIMIT $1 OFFSET $2`,
      [limit, offset],
    );

    const data: ExerciseMILPData[] = rows.map((r) => ({
      slug: r.slug,
      exerciseType: r.exercise_type,
      movementPattern: r.movement_pattern,
      metadata: r.metadata,
      equipments: r.equipments.map((e) => e.slug),
      contraindications: r.contraindications.map((c) => ({
        slug: c.slug,
        severity: c.severity,
      })),
    }));

    return { data, total };
  }
}
