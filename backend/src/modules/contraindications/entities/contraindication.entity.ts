import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type ContraindicationDocument = Contraindication & Document;

@Schema({ 
  timestamps: true,
  collection: 'contraindications'
})
export class Contraindication {
  @Prop({ required: true })
  name: string;

  @Prop({ required: true, unique: true })
  slug: string;
}

export const ContraindicationSchema = SchemaFactory.createForClass(Contraindication);

// Indexes for better query performance
ContraindicationSchema.index({ slug: 1 });
ContraindicationSchema.index({ name: 1 });
