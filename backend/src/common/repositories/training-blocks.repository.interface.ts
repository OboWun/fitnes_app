import type { TrainingBlock } from '../../entities/index.js';

export const TRAINING_BLOCKS_REPOSITORY = Symbol('TRAINING_BLOCKS_REPOSITORY');

export interface ITrainingBlocksRepository {
  findByUserId(userId: string): Promise<TrainingBlock[]>;
  findById(id: string): Promise<TrainingBlock | undefined>;
  create(data: Omit<TrainingBlock, 'id'>): Promise<TrainingBlock>;
  update(
    id: string,
    data: Partial<Omit<TrainingBlock, 'id' | 'userId'>>,
  ): Promise<TrainingBlock | undefined>;
  delete(id: string): Promise<boolean>;
}
