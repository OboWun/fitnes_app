import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type { Equipment } from '../entities/index.js';
import type { IEquipmentsRepository } from '../common/repositories/index.js';

@Injectable()
export class EquipmentsSqlRepository implements IEquipmentsRepository {
  constructor(private readonly db: DatabaseService) {}

  async findAll(): Promise<Equipment[]> {
    const rows = await this.db.query<{ name: string; slug: string }>(
      'SELECT name, slug FROM equipments ORDER BY name',
    );
    return rows.map((r) => ({ name: r.name, slug: r.slug }));
  }
}
