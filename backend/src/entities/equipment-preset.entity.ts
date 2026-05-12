export interface EquipmentPreset {
  id: string;
  userId?: string;
  name: string;
  slug: string;
  isSystem: boolean;
  equipmentSlugs: string[];
  createdAt: string;
  updatedAt: string;
}
