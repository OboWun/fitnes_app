import type { EquipmentPreset } from '../../entities/index.js';

export const EQUIPMENT_PRESETS_REPOSITORY = Symbol(
  'EQUIPMENT_PRESETS_REPOSITORY',
);

export interface IEquipmentPresetsRepository {
  findById(id: string): Promise<EquipmentPreset | undefined>;
  findSystemPresets(): Promise<EquipmentPreset[]>;
  findByUserId(userId: string): Promise<EquipmentPreset[]>;
  findByIdAndUserId(
    id: string,
    userId: string,
  ): Promise<EquipmentPreset | undefined>;
  create(
    data: Omit<EquipmentPreset, 'id' | 'createdAt' | 'updatedAt'>,
  ): Promise<EquipmentPreset>;
  update(
    id: string,
    data: Partial<Pick<EquipmentPreset, 'name' | 'slug' | 'equipmentSlugs'>>,
  ): Promise<EquipmentPreset | undefined>;
  delete(id: string): Promise<boolean>;
}
