import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type EquipmentDocument = Equipment & Document;

@Schema({ 
  timestamps: true,
  collection: 'equipments'
})
export class Equipment {
  @Prop({ required: true })
  name: string;

  @Prop({ required: true, unique: true })
  slug: string;
}

export const EquipmentSchema = SchemaFactory.createForClass(Equipment);

// Indexes for better query performance
EquipmentSchema.index({ slug: 1 });
EquipmentSchema.index({ name: 1 });
