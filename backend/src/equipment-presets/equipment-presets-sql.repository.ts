import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type { EquipmentPreset } from '../entities/index.js';
import type { IEquipmentPresetsRepository } from '../common/repositories/index.js';

interface PresetRow {
  id: string;
  user_id: string | null;
  name: string;
  slug: string;
  is_system: boolean;
  equipment_slugs: string[];
  created_at: string;
  updated_at: string;
}

function toPreset(row: PresetRow): EquipmentPreset {
  return {
    id: row.id,
    userId: row.user_id ?? undefined,
    name: row.name,
    slug: row.slug,
    isSystem: row.is_system,
    equipmentSlugs: row.equipment_slugs ?? [],
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

@Injectable()
export class EquipmentPresetsSqlRepository implements IEquipmentPresetsRepository {
  constructor(private readonly db: DatabaseService) {}

  async findById(id: string): Promise<EquipmentPreset | undefined> {
    const row = await this.db.queryOne<PresetRow>(
      'SELECT id, user_id, name, slug, is_system, equipment_slugs, created_at, updated_at FROM equipment_presets WHERE id = $1',
      [id],
    );
    if (!row) return undefined;
    return toPreset(row);
  }

  async findSystemPresets(): Promise<EquipmentPreset[]> {
    const rows = await this.db.query<PresetRow>(
      'SELECT id, user_id, name, slug, is_system, equipment_slugs, created_at, updated_at FROM equipment_presets WHERE is_system = true ORDER BY name',
    );
    return rows.map(toPreset);
  }

  async findByUserId(userId: string): Promise<EquipmentPreset[]> {
    const rows = await this.db.query<PresetRow>(
      'SELECT id, user_id, name, slug, is_system, equipment_slugs, created_at, updated_at FROM equipment_presets WHERE user_id = $1 ORDER BY name',
      [userId],
    );
    return rows.map(toPreset);
  }

  async findByIdAndUserId(
    id: string,
    userId: string,
  ): Promise<EquipmentPreset | undefined> {
    const row = await this.db.queryOne<PresetRow>(
      'SELECT id, user_id, name, slug, is_system, equipment_slugs, created_at, updated_at FROM equipment_presets WHERE id = $1 AND user_id = $2',
      [id, userId],
    );
    if (!row) return undefined;
    return toPreset(row);
  }

  async create(
    data: Omit<EquipmentPreset, 'id' | 'createdAt' | 'updatedAt'>,
  ): Promise<EquipmentPreset> {
    const id =
      Date.now().toString(36) + Math.random().toString(36).substring(2, 8);
    const row = await this.db.queryOne<PresetRow>(
      `INSERT INTO equipment_presets (id, user_id, name, slug, is_system, equipment_slugs)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, user_id, name, slug, is_system, equipment_slugs, created_at, updated_at`,
      [
        id,
        data.userId ?? null,
        data.name,
        data.slug,
        data.isSystem ?? false,
        data.equipmentSlugs ?? [],
      ],
    );
    return toPreset(row!);
  }

  async update(
    id: string,
    data: Partial<Pick<EquipmentPreset, 'name' | 'slug' | 'equipmentSlugs'>>,
  ): Promise<EquipmentPreset | undefined> {
    const sets: string[] = [];
    const params: unknown[] = [id];
    let idx = 2;

    if (data.name !== undefined) {
      sets.push(`name = $${idx++}`);
      params.push(data.name);
    }
    if (data.slug !== undefined) {
      sets.push(`slug = $${idx++}`);
      params.push(data.slug);
    }
    if (data.equipmentSlugs !== undefined) {
      sets.push(`equipment_slugs = $${idx++}`);
      params.push(data.equipmentSlugs);
    }

    sets.push(`updated_at = NOW()`);

    if (sets.length === 1) return this.findById(id);

    const row = await this.db.queryOne<PresetRow>(
      `UPDATE equipment_presets SET ${sets.join(', ')} WHERE id = $1
       RETURNING id, user_id, name, slug, is_system, equipment_slugs, created_at, updated_at`,
      params,
    );
    if (!row) return undefined;
    return toPreset(row);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.db.query(
      'DELETE FROM equipment_presets WHERE id = $1',
      [id],
    );
    return (result as unknown as { rowCount: number }).rowCount > 0;
  }
}
