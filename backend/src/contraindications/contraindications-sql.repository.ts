import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type { Contraindication } from '../entities/index.js';
import type { IContraindicationsRepository } from '../common/repositories/index.js';

@Injectable()
export class ContraindicationsSqlRepository
  implements IContraindicationsRepository
{
  constructor(private readonly db: DatabaseService) {}

  async findAll(): Promise<Contraindication[]> {
    const rows = await this.db.query<{ name: string; slug: string }>(
      'SELECT name, slug FROM contraindications ORDER BY name',
    );
    return rows.map((r) => ({ name: r.name, slug: r.slug }));
  }

  async findBySlug(slug: string): Promise<Contraindication | undefined> {
    const row = await this.db.queryOne<{ name: string; slug: string }>(
      'SELECT name, slug FROM contraindications WHERE slug = $1',
      [slug],
    );
    if (!row) return undefined;
    return { name: row.name, slug: row.slug };
  }
}
