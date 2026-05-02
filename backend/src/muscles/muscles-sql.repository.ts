import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type { Muscle } from '../entities/index.js';
import type { IMusclesRepository } from '../common/repositories/index.js';

@Injectable()
export class MusclesSqlRepository implements IMusclesRepository {
  constructor(private readonly db: DatabaseService) {}

  async findAll(): Promise<Muscle[]> {
    const rows = await this.db.query<{ name: string; slug: string }>(
      'SELECT name, slug FROM muscles ORDER BY name',
    );
    return rows.map((r) => ({
      name: r.name,
      slug: r.slug,
    }));
  }

  async findBySlug(slug: string): Promise<Muscle | undefined> {
    const row = await this.db.queryOne<{ name: string; slug: string }>(
      'SELECT name, slug FROM muscles WHERE slug = $1',
      [slug],
    );
    if (!row) return undefined;
    return { name: row.name, slug: row.slug };
  }

  async findAntagonists(slug: string): Promise<Muscle[]> {
    const rows = await this.db.query<{ name: string; slug: string }>(
      `SELECT m.name, m.slug
       FROM muscles m
       JOIN muscle_antagonists ma ON m.id = ma.antagonist_id
       JOIN muscles base ON base.id = ma.muscle_id
       WHERE base.slug = $1`,
      [slug],
    );
    return rows.map((r) => ({ name: r.name, slug: r.slug }));
  }
}
