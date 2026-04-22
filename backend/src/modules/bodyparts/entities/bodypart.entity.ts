import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type BodyPartDocument = BodyPart & Document;

@Schema({ 
  timestamps: true,
  collection: 'bodyparts'
})
export class BodyPart {
  @Prop({ required: true })
  name: string;

  @Prop({ required: true, unique: true })
  slug: string;
}

export const BodyPartSchema = SchemaFactory.createForClass(BodyPart);

// Indexes for better query performance
BodyPartSchema.index({ slug: 1 });
BodyPartSchema.index({ name: 1 });
