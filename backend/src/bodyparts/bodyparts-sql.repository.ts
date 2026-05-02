import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type { Bodypart } from '../entities/index.js';
import type { IBodypartsRepository } from '../common/repositories/index.js';

@Injectable()
export class BodypartsSqlRepository implements IBodypartsRepository {
  constructor(private readonly db: DatabaseService) {}

  async findAll(): Promise<Bodypart[]> {
    const rows = await this.db.query<{ name: string; slug: string }>(
      'SELECT name, slug FROM bodyparts ORDER BY name',
    );
    return rows.map((r) => ({ name: r.name, slug: r.slug }));
  }
}
