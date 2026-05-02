import { Injectable } from '@nestjs/common';
import * as path from 'path';
import * as fs from 'fs';
import type { WorkoutTemplate, ScheduledWorkout } from '../entities/index.js';
import type {
  IWorkoutTemplatesRepository,
  IScheduledWorkoutsRepository,
} from '../common/repositories/index.js';

@Injectable()
export class WorkoutTemplatesJsonRepository implements IWorkoutTemplatesRepository {
  private readonly filePath: string;
  private templates: WorkoutTemplate[];

  constructor() {
    this.filePath = path.join(
      __dirname,
      '..',
      '..',
      'data',
      'workout-templates.json',
    );
    if (fs.existsSync(this.filePath)) {
      const raw = fs.readFileSync(this.filePath, 'utf-8');
      this.templates = JSON.parse(raw) as WorkoutTemplate[];
    } else {
      this.templates = [];
    }
  }

  private save(): void {
    fs.writeFileSync(
      this.filePath,
      JSON.stringify(this.templates, null, 2) + '\n',
      'utf-8',
    );
  }

  findByUserId(userId: string): WorkoutTemplate[] {
    return this.templates.filter((t) => t.userId === userId);
  }

  findById(id: string): WorkoutTemplate | undefined {
    return this.templates.find((t) => t.id === id);
  }

  create(
    data: Omit<WorkoutTemplate, 'id' | 'createdAt' | 'updatedAt'>,
  ): WorkoutTemplate {
    const now = new Date().toISOString();
    const template: WorkoutTemplate = {
      id: this.generateId(),
      ...data,
      createdAt: now,
      updatedAt: now,
    };
    this.templates.push(template);
    this.save();
    return template;
  }

  update(
    id: string,
    data: Partial<
      Omit<WorkoutTemplate, 'id' | 'userId' | 'createdAt' | 'updatedAt'>
    >,
  ): WorkoutTemplate | undefined {
    const index = this.templates.findIndex((t) => t.id === id);
    if (index === -1) return undefined;
    this.templates[index] = {
      ...this.templates[index],
      ...data,
      updatedAt: new Date().toISOString(),
    };
    this.save();
    return this.templates[index];
  }

  delete(id: string): boolean {
    const index = this.templates.findIndex((t) => t.id === id);
    if (index === -1) return false;
    this.templates.splice(index, 1);
    this.save();
    return true;
  }

  private generateId(): string {
    return Date.now().toString(36) + Math.random().toString(36).substring(2, 8);
  }
}

@Injectable()
export class ScheduledWorkoutsJsonRepository implements IScheduledWorkoutsRepository {
  private readonly filePath: string;
  private scheduled: ScheduledWorkout[];

  constructor() {
    this.filePath = path.join(
      __dirname,
      '..',
      '..',
      'data',
      'scheduled-workouts.json',
    );
    if (fs.existsSync(this.filePath)) {
      const raw = fs.readFileSync(this.filePath, 'utf-8');
      this.scheduled = JSON.parse(raw) as ScheduledWorkout[];
    } else {
      this.scheduled = [];
    }
  }

  private save(): void {
    fs.writeFileSync(
      this.filePath,
      JSON.stringify(this.scheduled, null, 2) + '\n',
      'utf-8',
    );
  }

  findByUserId(userId: string): ScheduledWorkout[] {
    return this.scheduled.filter((s) => s.userId === userId);
  }

  findById(id: string): ScheduledWorkout | undefined {
    return this.scheduled.find((s) => s.id === id);
  }

  findByUserIdAndDay(userId: string, dayOfWeek: string): ScheduledWorkout[] {
    return this.scheduled.filter(
      (s) => s.userId === userId && s.dayOfWeek === dayOfWeek,
    );
  }

  create(data: Omit<ScheduledWorkout, 'id' | 'createdAt'>): ScheduledWorkout {
    const item: ScheduledWorkout = {
      id: this.generateId(),
      ...data,
      createdAt: new Date().toISOString(),
    };
    this.scheduled.push(item);
    this.save();
    return item;
  }

  update(
    id: string,
    data: Partial<Omit<ScheduledWorkout, 'id' | 'userId' | 'createdAt'>>,
  ): ScheduledWorkout | undefined {
    const index = this.scheduled.findIndex((s) => s.id === id);
    if (index === -1) return undefined;
    this.scheduled[index] = { ...this.scheduled[index], ...data };
    this.save();
    return this.scheduled[index];
  }

  delete(id: string): boolean {
    const index = this.scheduled.findIndex((s) => s.id === id);
    if (index === -1) return false;
    this.scheduled.splice(index, 1);
    this.save();
    return true;
  }

  private generateId(): string {
    return Date.now().toString(36) + Math.random().toString(36).substring(2, 8);
  }
}
