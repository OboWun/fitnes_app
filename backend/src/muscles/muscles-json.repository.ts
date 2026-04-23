import { Injectable } from '@nestjs/common';
import * as path from 'path';
import * as fs from 'fs';
import type { Muscle } from '../entities/index.js';
import type { IMusclesRepository } from '../common/repositories/index.js';

@Injectable()
export class MusclesJsonRepository implements IMusclesRepository {
  private readonly muscles: Muscle[];

  constructor() {
    const filePath = path.join(__dirname, '..', '..', 'data', 'muscles.json');
    const raw = fs.readFileSync(filePath, 'utf-8');
    this.muscles = JSON.parse(raw) as Muscle[];
  }

  findAll(): Muscle[] {
    return this.muscles;
  }

  findBySlug(slug: string): Muscle | undefined {
    return this.muscles.find((m) => m.slug === slug);
  }

  findAntagonists(slug: string): Muscle[] {
    const muscle = this.findBySlug(slug);
    if (!muscle?.antagonists?.length) {
      return [];
    }
    return this.muscles.filter((m) => muscle.antagonists!.includes(m.slug));
  }
}
