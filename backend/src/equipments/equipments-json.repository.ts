import { Injectable } from '@nestjs/common';
import * as path from 'path';
import * as fs from 'fs';
import type { Equipment } from '../entities/index.js';
import type { IEquipmentsRepository } from '../common/repositories/index.js';

@Injectable()
export class EquipmentsJsonRepository implements IEquipmentsRepository {
  private readonly equipments: Equipment[];

  constructor() {
    const filePath = path.join(__dirname, '..', '..', 'data', 'equipments.json');
    const raw = fs.readFileSync(filePath, 'utf-8');
    this.equipments = JSON.parse(raw) as Equipment[];
  }

  findAll(): Equipment[] {
    return this.equipments;
  }
}
