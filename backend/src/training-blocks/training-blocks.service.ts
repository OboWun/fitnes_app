import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { TRAINING_BLOCKS_REPOSITORY } from '../common/repositories/index.js';
import type { ITrainingBlocksRepository } from '../common/repositories/index.js';
import type { TrainingBlock } from '../entities/index.js';
import type { CreateTrainingBlockDto } from './dto/create-training-block.dto.js';
import type { UpdateTrainingBlockDto } from './dto/update-training-block.dto.js';
import type { TrainingBlockResponseDto } from './dto/training-block-response.dto.js';

@Injectable()
export class TrainingBlocksService {
  constructor(
    @Inject(TRAINING_BLOCKS_REPOSITORY)
    private readonly repository: ITrainingBlocksRepository,
  ) {}

  async findAll(userId: string): Promise<TrainingBlockResponseDto[]> {
    const blocks = await this.repository.findByUserId(userId);
    return blocks.map((b) => this.toResponseDto(b));
  }

  async findOne(userId: string, id: string): Promise<TrainingBlockResponseDto> {
    const block = await this.repository.findById(id);
    if (!block || block.userId !== userId) {
      throw new NotFoundException(`Training block with id "${id}" not found`);
    }
    return this.toResponseDto(block);
  }

  async create(
    userId: string,
    dto: CreateTrainingBlockDto,
  ): Promise<TrainingBlockResponseDto> {
    const block = await this.repository.create({
      userId,
      name: dto.name,
      type: dto.type,
      index: dto.index,
      durationWeeks: dto.durationWeeks,
      goal: dto.goal,
      targetMuscles: dto.targetMuscles,
      metadata: dto.metadata as TrainingBlock['metadata'],
    });
    return this.toResponseDto(block);
  }

  async update(
    userId: string,
    id: string,
    dto: UpdateTrainingBlockDto,
  ): Promise<TrainingBlockResponseDto> {
    const existing = await this.repository.findById(id);
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException(`Training block with id "${id}" not found`);
    }

    const updateData: Partial<Omit<TrainingBlock, 'id' | 'userId'>> = {};
    if (dto.name !== undefined) updateData.name = dto.name;
    if (dto.type !== undefined) updateData.type = dto.type;
    if (dto.index !== undefined) updateData.index = dto.index;
    if (dto.durationWeeks !== undefined) updateData.durationWeeks = dto.durationWeeks;
    if (dto.goal !== undefined) updateData.goal = dto.goal;
    if (dto.targetMuscles !== undefined) updateData.targetMuscles = dto.targetMuscles;
    if (dto.metadata !== undefined) updateData.metadata = dto.metadata as TrainingBlock['metadata'];

    const updated = await this.repository.update(id, updateData);
    return this.toResponseDto(updated!);
  }

  async delete(userId: string, id: string): Promise<void> {
    const existing = await this.repository.findById(id);
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException(`Training block with id "${id}" not found`);
    }
    await this.repository.delete(id);
  }

  private toResponseDto(block: TrainingBlock): TrainingBlockResponseDto {
    return {
      id: block.id,
      userId: block.userId,
      name: block.name,
      type: block.type,
      index: block.index,
      durationWeeks: block.durationWeeks,
      goal: block.goal,
      targetMuscles: block.targetMuscles,
      metadata: block.metadata,
    };
  }
}
