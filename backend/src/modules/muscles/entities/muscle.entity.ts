import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type MuscleDocument = Muscle & Document;

@Schema({ 
  timestamps: true,
  collection: 'muscles'
})
export class Muscle {
  @Prop({ required: true })
  name: string;

  @Prop({ required: true, unique: true })
  slug: string;

  @Prop({ type: [String], default: [] })
  antagonists?: string[];
}

export const MuscleSchema = SchemaFactory.createForClass(Muscle);

// Indexes for better query performance
MuscleSchema.index({ slug: 1 });
MuscleSchema.index({ name: 1 });
