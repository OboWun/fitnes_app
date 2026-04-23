import { Injectable } from '@nestjs/common';
import * as path from 'path';
import * as fs from 'fs';
import type { Exercise } from '../entities/index.js';
import type { IExercisesRepository, ExerciseFilterParams, PaginatedResult } from '../common/repositories/index.js';

@Injectable()
export class ExercisesJsonRepository implements IExercisesRepository {
  private readonly exercises: Exercise[];

  constructor() {
    const filePath = path.join(__dirname, '..', '..', 'data', 'exercises.json');
    const raw = fs.readFileSync(filePath, 'utf-8');
    this.exercises = JSON.parse(raw) as Exercise[];
  }

  findPaginated(page: number, limit: number, filters?: ExerciseFilterParams): PaginatedResult<Exercise> {
    const filtered = this.applyFilters(filters);
    const total = filtered.length;
    const offset = (page - 1) * limit;
    return { data: filtered.slice(offset, offset + limit), total };
  }

  findBySlug(slug: string): Exercise | undefined {
    return this.exercises.find((e) => e.slug === slug);
  }

  findSimilar(slug: string, page: number, limit: number): PaginatedResult<Exercise> {
    const exercise = this.findBySlug(slug);
    if (!exercise) {
      return { data: [], total: 0 };
    }

    const targetMuscles = exercise.targetMuscles;
    const similar = this.exercises.filter(
      (e) =>
        e.slug !== slug &&
        e.targetMuscles.some((m) => targetMuscles.includes(m)),
    );

    const total = similar.length;
    const offset = (page - 1) * limit;
    return { data: similar.slice(offset, offset + limit), total };
  }

  findAntagonist(
    slug: string,
    antagonistMuscles: string[],
    page: number,
    limit: number,
  ): PaginatedResult<Exercise> {
    if (!antagonistMuscles.length) {
      return { data: [], total: 0 };
    }

    const antagonistSlugs = antagonistMuscles.map((m) => m.toLowerCase());
    const result = this.exercises.filter(
      (e) =>
        e.slug !== slug &&
        e.targetMuscles.some((m) => antagonistSlugs.includes(m.toLowerCase())),
    );

    const total = result.length;
    const offset = (page - 1) * limit;
    return { data: result.slice(offset, offset + limit), total };
  }

  private applyFilters(filters?: ExerciseFilterParams): Exercise[] {
    if (!filters) {
      return this.exercises;
    }

    let result = this.exercises;

    if (filters.contraindications?.length) {
      const slugs = filters.contraindications.map((s) => s.toLowerCase());
      result = result.filter(
        (e) =>
          !e.contraindications?.some((c) =>
            slugs.includes(c.slug.toLowerCase()),
          ),
      );
    }

    if (filters.equipments?.length) {
      const eqSlugs = filters.equipments.map((s) => s.toLowerCase());
      result = result.filter((e) =>
        e.equipments.some((eq) => eqSlugs.includes(eq.toLowerCase())),
      );

      // Sort by equipment preference order (first in array = most preferred)
      result = result.sort((a, b) => {
        const aIdx = this.bestEquipmentIndex(a.equipments, eqSlugs);
        const bIdx = this.bestEquipmentIndex(b.equipments, eqSlugs);
        return aIdx - bIdx;
      });
    }

    if (filters.targetMuscles?.length) {
      const muscleSlugs = filters.targetMuscles.map((s) => s.toLowerCase());
      result = result.filter((e) =>
        e.targetMuscles.some((m) => muscleSlugs.includes(m.toLowerCase())),
      );
    }

    if (filters.search) {
      const search = filters.search.toLowerCase();
      result = result.filter(
        (e) =>
          e.name.toLowerCase().includes(search) ||
          e.slug.toLowerCase().includes(search),
      );
    }

    return result;
  }

  private bestEquipmentIndex(exerciseEquipments: string[], preferredOrder: string[]): number {
    let best = preferredOrder.length;
    for (const eq of exerciseEquipments) {
      const idx = preferredOrder.indexOf(eq.toLowerCase());
      if (idx !== -1 && idx < best) {
        best = idx;
      }
    }
    return best;
  }
}
