import { Injectable } from '@nestjs/common';
import * as path from 'path';
import * as fs from 'fs';
import type { Contraindication } from '../entities/index.js';
import type { IContraindicationsRepository } from '../common/repositories/index.js';

@Injectable()
export class ContraindicationsJsonRepository implements IContraindicationsRepository {
  private readonly items: Contraindication[];

  constructor() {
    const filePath = path.join(
      __dirname,
      '..',
      '..',
      'data',
      'contraindications.json',
    );
    const raw = fs.readFileSync(filePath, 'utf-8');
    this.items = JSON.parse(raw) as Contraindication[];
  }

  findAll(): Contraindication[] {
    return this.items;
  }

  findBySlug(slug: string): Contraindication | undefined {
    return this.items.find((item) => item.slug === slug);
  }
}
