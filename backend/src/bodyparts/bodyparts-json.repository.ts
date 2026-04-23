import { Injectable } from '@nestjs/common';
import * as path from 'path';
import * as fs from 'fs';
import type { Bodypart } from '../entities/index.js';
import type { IBodypartsRepository } from '../common/repositories/index.js';

@Injectable()
export class BodypartsJsonRepository implements IBodypartsRepository {
  private readonly bodyparts: Bodypart[];

  constructor() {
    const filePath = path.join(__dirname, '..', '..', 'data', 'bodyparts.json');
    const raw = fs.readFileSync(filePath, 'utf-8');
    this.bodyparts = JSON.parse(raw) as Bodypart[];
  }

  findAll(): Bodypart[] {
    return this.bodyparts;
  }
}
