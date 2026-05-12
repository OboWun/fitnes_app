import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../common/database/database.service.js';
import type { User, UserMetadata } from '../entities/index.js';
import type { IUsersRepository } from '../common/repositories/index.js';

interface UserRow {
  id: string;
  device_id: string;
  name: string | null;
  gender: string | null;
  weight: number | null;
  height: number | null;
  age: number | null;
  created_at: Date;
  metadata: UserMetadata | null;
}

function toUser(row: UserRow): User {
  return {
    id: row.id,
    deviceId: row.device_id,
    name: row.name ?? undefined,
    gender: (row.gender as 'male' | 'female') ?? undefined,
    weight: row.weight != null ? Number(row.weight) : undefined,
    height: row.height != null ? Number(row.height) : undefined,
    age: row.age ?? undefined,
    createdAt: new Date(row.created_at).toISOString(),
    metadata: row.metadata || undefined,
  };
}

@Injectable()
export class UsersSqlRepository implements IUsersRepository {
  constructor(private readonly db: DatabaseService) {}

  async findByDeviceId(deviceId: string): Promise<User | undefined> {
    const row = await this.db.queryOne<UserRow>(
      'SELECT id, device_id, name, gender, weight, height, age, created_at, metadata FROM users WHERE device_id = $1',
      [deviceId],
    );
    if (!row) return undefined;
    const user = toUser(row);
    user.contraindications = await this.getUserContraindications(row.id);
    return user;
  }

  async findById(id: string): Promise<User | undefined> {
    const row = await this.db.queryOne<UserRow>(
      'SELECT id, device_id, name, gender, weight, height, age, created_at, metadata FROM users WHERE id = $1',
      [id],
    );
    if (!row) return undefined;
    const user = toUser(row);
    user.contraindications = await this.getUserContraindications(row.id);
    return user;
  }

  async create(deviceId: string): Promise<User> {
    const id =
      Date.now().toString(36) + Math.random().toString(36).substring(2, 8);
    const row = await this.db.queryOne<UserRow>(
      `INSERT INTO users (id, device_id, created_at)
       VALUES ($1, $2, NOW())
       RETURNING id, device_id, name, gender, weight, height, age, created_at, metadata`,
      [id, deviceId],
    );
    return toUser(row!);
  }

  async update(
    id: string,
    data: Partial<Omit<User, 'id' | 'deviceId' | 'createdAt'>>,
  ): Promise<User | undefined> {
    const existing = await this.db.queryOne<UserRow>(
      'SELECT id, device_id, name, gender, weight, height, age, created_at, metadata FROM users WHERE id = $1',
      [id],
    );
    if (!existing) return undefined;

    await this.db.transaction(async (client) => {
      await client.query(
        `UPDATE users SET name = $2, gender = $3, weight = $4, height = $5, age = $6, metadata = COALESCE($7, metadata) WHERE id = $1`,
        [
          id,
          data.name ?? null,
          (data as Record<string, unknown>).gender ?? null,
          data.weight ?? null,
          data.height ?? null,
          data.age ?? null,
          data.metadata ?? null,
        ],
      );

      if (data.contraindications !== undefined) {
        await client.query(
          'DELETE FROM user_contraindications WHERE user_id = $1',
          [id],
        );
        if (data.contraindications.length > 0) {
          for (const slug of data.contraindications) {
            await client.query(
              `INSERT INTO user_contraindications (user_id, contraindication_id)
               SELECT $1, id FROM contraindications WHERE slug = $2
               ON CONFLICT DO NOTHING`,
              [id, slug],
            );
          }
        }
      }
    });

    const row = await this.db.queryOne<UserRow>(
      'SELECT id, device_id, name, gender, weight, height, age, created_at, metadata FROM users WHERE id = $1',
      [id],
    );
    if (!row) return undefined;
    const user = toUser(row);
    user.contraindications = await this.getUserContraindications(id);
    return user;
  }

  private async getUserContraindications(userId: string): Promise<string[]> {
    const rows = await this.db.query<{ slug: string }>(
      `SELECT c.slug
       FROM user_contraindications uc
       JOIN contraindications c ON c.id = uc.contraindication_id
       WHERE uc.user_id = $1`,
      [userId],
    );
    return rows.map((r) => r.slug);
  }
}
