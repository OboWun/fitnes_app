import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type ExerciseDocument = Exercise & Document;

@Schema({ 
  timestamps: true,
  collection: 'exercises'
})
export class Exercise {
  @Prop({ required: true, unique: true })
  exerciseId: string;

  @Prop({ required: true })
  name: string;

  @Prop({ required: true, unique: true })
  slug: string;

  @Prop({ required: true })
  gifUrl: string;

  @Prop({ type: [String], default: [] })
  targetMuscles: string[];

  @Prop({ type: [String], default: [] })
  bodyParts: string[];

  @Prop({ type: [String], default: [] })
  equipments: string[];

  @Prop({ type: [String], default: [] })
  secondaryMuscles: string[];

  @Prop({ type: [String], default: [] })
  instructions: string[];

  @Prop({
    type: [{
      slug: String,
      severity: {
        type: String,
        enum: ['not_recommended', 'low_weight', 'forbidden'],
      },
    }],
    default: [],
  })
  contraindications?: Array<{
    slug: string;
    severity: 'not_recommended' | 'low_weight' | 'forbidden';
  }>;
}

export const ExerciseSchema = SchemaFactory.createForClass(Exercise);

// Indexes for better query performance
ExerciseSchema.index({ slug: 1 });
ExerciseSchema.index({ name: 1 });
ExerciseSchema.index({ targetMuscles: 1 });
ExerciseSchema.index({ bodyParts: 1 });
ExerciseSchema.index({ equipments: 1 });
ExerciseSchema.index({ exerciseId: 1 });
