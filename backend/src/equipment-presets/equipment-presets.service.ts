import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import {
  EQUIPMENT_PRESETS_REPOSITORY,
  EQUIPMENTS_REPOSITORY,
} from '../common/repositories/index.js';
import type {
  IEquipmentPresetsRepository,
  IEquipmentsRepository,
} from '../common/repositories/index.js';
import type { EquipmentPreset } from '../entities/index.js';
import type { Equipment } from '../entities/equipment.entity.js';
import type { CreateEquipmentPresetDto } from './dto/create-equipment-preset.dto.js';
import type { UpdateEquipmentPresetDto } from './dto/update-equipment-preset.dto.js';

@Injectable()
export class EquipmentPresetsService {
  constructor(
    @Inject(EQUIPMENT_PRESETS_REPOSITORY)
    private readonly presetsRepository: IEquipmentPresetsRepository,
    @Inject(EQUIPMENTS_REPOSITORY)
    private readonly equipmentsRepository: IEquipmentsRepository,
  ) {}

  async getSystemPresets(includeDetails?: boolean): Promise<
    (EquipmentPreset & {
      equipmentDetails?: { slug: string; name: string }[];
    })[]
  > {
    const presets = await this.presetsRepository.findSystemPresets();
    if (!includeDetails) return presets;
    return this.enrichWithDetails(presets);
  }

  async getUserPresets(
    userId: string,
    includeDetails?: boolean,
  ): Promise<
    (EquipmentPreset & {
      equipmentDetails?: { slug: string; name: string }[];
    })[]
  > {
    const presets = await this.presetsRepository.findByUserId(userId);
    if (!includeDetails) return presets;
    return this.enrichWithDetails(presets);
  }

  async createPreset(
    userId: string,
    dto: CreateEquipmentPresetDto,
  ): Promise<EquipmentPreset> {
    return this.presetsRepository.create({
      userId,
      name: dto.name,
      slug: dto.slug,
      isSystem: false,
      equipmentSlugs: dto.equipmentSlugs,
    });
  }

  async updatePreset(
    userId: string,
    id: string,
    dto: UpdateEquipmentPresetDto,
  ): Promise<EquipmentPreset> {
    const preset = await this.presetsRepository.findByIdAndUserId(id, userId);
    if (!preset) {
      throw new NotFoundException('Preset not found');
    }
    if (preset.isSystem) {
      throw new NotFoundException('Cannot modify system preset');
    }
    const updated = await this.presetsRepository.update(id, dto);
    if (!updated) {
      throw new NotFoundException('Preset not found');
    }
    return updated;
  }

  async deletePreset(userId: string, id: string): Promise<void> {
    const preset = await this.presetsRepository.findByIdAndUserId(id, userId);
    if (!preset) {
      throw new NotFoundException('Preset not found');
    }
    if (preset.isSystem) {
      throw new NotFoundException('Cannot delete system preset');
    }
    const deleted = await this.presetsRepository.delete(id);
    if (!deleted) {
      throw new NotFoundException('Preset not found');
    }
  }

  async clonePreset(
    userId: string,
    sourceId: string,
    data: { name: string; slug?: string },
  ): Promise<EquipmentPreset> {
    const source = await this.presetsRepository.findById(sourceId);
    if (!source) {
      throw new NotFoundException('Source preset not found');
    }
    if (!source.isSystem && source.userId !== userId) {
      throw new NotFoundException('Source preset not found');
    }
    return this.presetsRepository.create({
      userId,
      name: data.name,
      slug: data.slug ?? source.slug + '-copy',
      isSystem: false,
      equipmentSlugs: [...source.equipmentSlugs],
    });
  }

  async resolvePreset(
    presetId: string,
    userId: string,
  ): Promise<string[] | undefined> {
    const preset = await this.presetsRepository.findById(presetId);
    if (!preset) return undefined;
    if (preset.isSystem) return preset.equipmentSlugs;
    if (preset.userId === userId) return preset.equipmentSlugs;
    return undefined;
  }

  private async enrichWithDetails(
    presets: EquipmentPreset[],
  ): Promise<
    (EquipmentPreset & { equipmentDetails: { slug: string; name: string }[] })[]
  > {
    const allEquipment = await this.equipmentsRepository.findAll();
    const slugToName = new Map<string, string>(
      allEquipment.map((e: Equipment) => [e.slug, e.name]),
    );
    return presets.map((p) => ({
      ...p,
      equipmentDetails: p.equipmentSlugs.map((slug) => ({
        slug,
        name: slugToName.get(slug) ?? slug,
      })),
    }));
  }
}
