import { Inject, Injectable, Logger } from '@nestjs/common';
import {
  EXERCISES_REPOSITORY,
  WORKOUT_SESSIONS_REPOSITORY,
} from '../common/repositories/index.js';
import type {
  IExercisesRepository,
  IWorkoutSessionsRepository,
  ExerciseMILPData,
} from '../common/repositories/index.js';
import type { ExerciseMetadata } from '../entities/index.js';
// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore - javascript-lp-solver has no types
import solver from 'javascript-lp-solver';

// Priors from MILP-COMMON.md section 6
const ALPHA_1 = 1.5;
const ALPHA_2 = 0.5;
const ALPHA_3 = 2.0;
const DELTA = 0.2;
const EPSILON = 0.2;
const THETA = 1.5;
const FATIGUE_LIMIT = 3.0;
const DEFAULT_PHASE = 'accumulation';
const DIVERSITY_WINDOW = 4;

const DEFAULT_SESSION_DURATION: Record<string, Record<string, number>> = {
  beginner: { default: 45 },
  intermediate: { strength: 60, hypertrophy: 60, glute_growth: 60, recomposition: 60, default: 45 },
  advanced: { strength: 75, hypertrophy: 75, glute_growth: 75, recomposition: 75, default: 60 },
};

const ACTIVITY_VOLUME_SCALE: Record<string, number> = {
  sedentary: 0.7,
  light: 0.85,
  moderate: 1.0,
  active: 1.1,
};

const AGE_VOLUME_SCALE: Record<string, number> = {
  under_25: 1.1,
  '25_40': 1.0,
  '40_55': 0.85,
  over_55: 0.7,
};

const AGE_REST_MODIFIER: Record<string, number> = {
  under_40: 1.0,
  '40_55': 1.1,
  over_55: 1.2,
};

function getAgeBucket(age: number | undefined): string {
  if (!age) return '25_40';
  if (age < 25) return 'under_25';
  if (age <= 40) return '25_40';
  if (age <= 55) return '40_55';
  return 'over_55';
}

function getAgeRestBucket(age: number | undefined): string {
  if (!age) return 'under_40';
  if (age <= 40) return 'under_40';
  if (age <= 55) return '40_55';
  return 'over_55';
}

function computeBMI(weightKg: number | undefined | null, heightCm: number | undefined | null): number | null {
  if (!weightKg || !heightCm || heightCm <= 0) return null;
  const heightM = heightCm / 100;
  return weightKg / (heightM * heightM);
}

const GLUTE_MUSCLES = new Set(['glutes', 'hamstrings', 'adductors', 'abductors']);

type SessionType =
  | 'upper'
  | 'lower'
  | 'full_body'
  | 'push'
  | 'pull'
  | 'cardio'
  | 'mobility'
  | 'general';

const SESSION_TARGETS: Record<SessionType, string[]> = {
  upper: ['chest', 'back', 'shoulders', 'lats', 'upper_back', 'traps'],
  push: ['chest', 'shoulders', 'triceps'],
  pull: ['back', 'lats', 'upper_back', 'traps', 'biceps'],
  lower: ['quads', 'hamstrings', 'glutes', 'calves'],
  full_body: [
    'chest',
    'back',
    'shoulders',
    'quads',
    'hamstrings',
    'glutes',
    'lats',
    'upper_back',
  ],
  cardio: [],
  mobility: [],
  general: [],
};

const SESSION_DEPRIORITIZE: Record<SessionType, string[]> = {
  upper: ['stretch', 'mobility'],
  push: ['stretch', 'mobility'],
  pull: ['stretch', 'mobility'],
  lower: ['stretch', 'mobility'],
  full_body: ['stretch', 'mobility'],
  cardio: [],
  mobility: [],
  general: [],
};

const MUSCLE_HIERARCHY: Record<string, { slug: string; priority: number }[]> = {
  arms: [
    { slug: 'biceps', priority: 0.9 },
    { slug: 'triceps', priority: 0.9 },
    { slug: 'shoulders', priority: 0.6 },
    { slug: 'side_delts', priority: 0.5 },
    { slug: 'forearms', priority: 0.3 },
  ],
  legs: [
    { slug: 'quads', priority: 0.9 },
    { slug: 'hamstrings', priority: 0.8 },
    { slug: 'glutes', priority: 0.7 },
    { slug: 'calves', priority: 0.4 },
    { slug: 'adductors', priority: 0.3 },
    { slug: 'abductors', priority: 0.3 },
  ],
  back: [
    { slug: 'lats', priority: 0.9 },
    { slug: 'upper_back', priority: 0.8 },
    { slug: 'traps', priority: 0.5 },
    { slug: 'rhomboids', priority: 0.4 },
    { slug: 'rear_delts', priority: 0.3 },
    { slug: 'lower_back', priority: 0.3 },
  ],
  chest: [{ slug: 'chest', priority: 1.0 }],
  shoulders: [
    { slug: 'side_delts', priority: 0.8 },
    { slug: 'shoulders', priority: 0.7 },
    { slug: 'front_delts', priority: 0.6 },
    { slug: 'rear_delts', priority: 0.5 },
  ],
  core: [
    { slug: 'abs', priority: 0.8 },
    { slug: 'obliques', priority: 0.4 },
    { slug: 'lower_back', priority: 0.3 },
  ],
};

const EXPERIENCE_PRESETS: Record<
  string,
  {
    exerciseCount: number;
    setsPerExercise: number;
    restBetweenSetsSec: number;
    weeklyVolumeScale: number;
  }
> = {
  beginner: {
    exerciseCount: 4,
    setsPerExercise: 3,
    restBetweenSetsSec: 120,
    weeklyVolumeScale: 0.6,
  },
  intermediate: {
    exerciseCount: 5,
    setsPerExercise: 3,
    restBetweenSetsSec: 90,
    weeklyVolumeScale: 1.0,
  },
  advanced: {
    exerciseCount: 6,
    setsPerExercise: 4,
    restBetweenSetsSec: 60,
    weeklyVolumeScale: 1.4,
  },
};

const SETS_BY_ROLE: Record<string, { compound: number; isolation: number }> = {
  beginner: { compound: 3, isolation: 2 },
  intermediate: { compound: 4, isolation: 3 },
  advanced: { compound: 4, isolation: 3 },
};

const SETS_GOAL_MODIFIER: Record<
  string,
  { compound: number; isolation: number }
> = {
  strength: { compound: 1, isolation: 0 },
  hypertrophy: { compound: 0, isolation: 1 },
  endurance: { compound: 0, isolation: 1 },
  weight_loss: { compound: 0, isolation: 0 },
  general_health: { compound: 0, isolation: 0 },
  rehab: { compound: -1, isolation: 0 },
  mobility: { compound: -1, isolation: 0 },
  glute_growth: { compound: 1, isolation: 1 },
  recomposition: { compound: 0, isolation: 1 },
};

const GOAL_REP_RANGES: Record<
  string,
  { min: number; max: number; default: number }
> = {
  strength: { min: 1, max: 5, default: 5 },
  hypertrophy: { min: 6, max: 12, default: 10 },
  endurance: { min: 15, max: 25, default: 15 },
  weight_loss: { min: 10, max: 15, default: 12 },
  general_health: { min: 8, max: 15, default: 10 },
  rehab: { min: 12, max: 20, default: 15 },
  mobility: { min: 10, max: 20, default: 15 },
  glute_growth: { min: 6, max: 20, default: 12 },
  recomposition: { min: 8, max: 15, default: 12 },
};

const GOAL_CONFIG: Record<
  string,
  {
    setsMultiplier: number;
    restSec: number;
    preferCompound: boolean;
    exerciseTypeBonus: string[];
    exerciseTypePenalty: string[];
  }
> = {
  strength: {
    setsMultiplier: 1.0,
    restSec: 180,
    preferCompound: true,
    exerciseTypeBonus: ['strength', 'plyometric'],
    exerciseTypePenalty: ['stretching', 'mobility', 'cardio'],
  },
  hypertrophy: {
    setsMultiplier: 1.25,
    restSec: 90,
    preferCompound: true,
    exerciseTypeBonus: ['hypertrophy', 'strength'],
    exerciseTypePenalty: ['stretching', 'mobility', 'cardio'],
  },
  endurance: {
    setsMultiplier: 1.5,
    restSec: 45,
    preferCompound: false,
    exerciseTypeBonus: ['endurance', 'cardio'],
    exerciseTypePenalty: ['plyometric'],
  },
  weight_loss: {
    setsMultiplier: 1.25,
    restSec: 45,
    preferCompound: true,
    exerciseTypeBonus: ['cardio', 'endurance'],
    exerciseTypePenalty: [],
  },
  general_health: {
    setsMultiplier: 1.0,
    restSec: 90,
    preferCompound: false,
    exerciseTypeBonus: ['hypertrophy', 'endurance'],
    exerciseTypePenalty: [],
  },
  rehab: {
    setsMultiplier: 0.75,
    restSec: 120,
    preferCompound: false,
    exerciseTypeBonus: ['rehab', 'mobility', 'stability'],
    exerciseTypePenalty: ['plyometric', 'strength'],
  },
  mobility: {
    setsMultiplier: 0.75,
    restSec: 45,
    preferCompound: false,
    exerciseTypeBonus: ['mobility', 'stretching', 'stability'],
    exerciseTypePenalty: ['plyometric', 'strength'],
  },
  glute_growth: {
    setsMultiplier: 1.3,
    restSec: 90,
    preferCompound: true,
    exerciseTypeBonus: ['hypertrophy', 'strength'],
    exerciseTypePenalty: ['stretching', 'cardio'],
  },
  recomposition: {
    setsMultiplier: 1.25,
    restSec: 60,
    preferCompound: true,
    exerciseTypeBonus: ['hypertrophy', 'strength', 'endurance'],
    exerciseTypePenalty: ['stretching', 'mobility'],
  },
};

const MUSCLE_WEEKLY_VOLUME_TARGETS: Record<
  string,
  { min: number; max: number }
> = {
  quads: { min: 12, max: 18 },
  glutes: { min: 14, max: 20 },
  hamstrings: { min: 10, max: 14 },
  lats: { min: 12, max: 16 },
  upper_back: { min: 8, max: 12 },
  traps: { min: 6, max: 10 },
  chest: { min: 12, max: 16 },
  shoulders: { min: 8, max: 12 },
  side_delts: { min: 6, max: 10 },
  front_delts: { min: 4, max: 8 },
  rear_delts: { min: 6, max: 10 },
  biceps: { min: 8, max: 12 },
  triceps: { min: 10, max: 14 },
  forearms: { min: 4, max: 8 },
  calves: { min: 8, max: 12 },
  abs: { min: 6, max: 10 },
  obliques: { min: 4, max: 6 },
  lower_back: { min: 4, max: 8 },
  adductors: { min: 4, max: 8 },
};

const MUSCLE_NORMALIZATION: Record<string, string> = {
  chest: 'chest',
  pec: 'chest',
  pectoral: 'chest',
  pectorals: 'chest',
  pecs: 'chest',
  'upper chest': 'chest',
  back: 'back',
  lats: 'lats',
  lat: 'lats',
  latissimus: 'lats',
  'latissimus dorsi': 'lats',
  latissimus_dorsi: 'lats',
  upper_back: 'upper_back',
  'upper back': 'upper_back',
  traps: 'traps',
  trap: 'traps',
  trapezius: 'traps',
  rhomboids: 'rhomboids',
  rhomboid: 'rhomboids',
  'rear deltoids': 'rear_delts',
  rear_delts: 'rear_delts',
  rear_delt: 'rear_delts',
  posterior_delt: 'rear_delts',
  front_delts: 'front_delts',
  front_delt: 'front_delts',
  anterior_delt: 'front_delts',
  side_delts: 'side_delts',
  side_delt: 'side_delts',
  lateral_delt: 'side_delts',
  shoulders: 'shoulders',
  deltoids: 'shoulders',
  delts: 'shoulders',
  delt: 'shoulders',
  quadriceps: 'quads',
  quads: 'quads',
  quad: 'quads',
  hamstrings: 'hamstrings',
  hamstring: 'hamstrings',
  glute: 'glutes',
  glutes: 'glutes',
  gluteus: 'glutes',
  calf: 'calves',
  calves: 'calves',
  calf_muscle: 'calves',
  gastrocnemius: 'calves',
  soleus: 'calves',
  biceps: 'biceps',
  bicep: 'biceps',
  biceps_brachii: 'biceps',
  triceps: 'triceps',
  tricep: 'triceps',
  triceps_brachii: 'triceps',
  forearms: 'forearms',
  forearm: 'forearms',
  'grip muscles': 'forearms',
  abs: 'abs',
  abdominals: 'abs',
  abdominal: 'abs',
  'lower abs': 'abs',
  core: 'abs',
  obliques: 'obliques',
  oblique: 'obliques',
  lower_back: 'lower_back',
  'lower back': 'lower_back',
  erector_spinae: 'lower_back',
  erectors: 'lower_back',
  spine: 'lower_back',
  adductors: 'adductors',
  adductor: 'adductors',
  'inner thighs': 'adductors',
  abductors: 'abductors',
  abductor: 'abductors',
  'hip flexors': 'hip_flexors',
  'rotator cuff': 'rotator_cuff',
  'serratus anterior': 'serratus_anterior',
  'levator scapulae': 'levator_scapulae',
  'ankle stabilizers': 'calves',
  ankles: 'calves',
  'cardiovascular system': 'cardio',
};

const MUSCLE_GROUPS: Record<string, string[]> = {
  back: [
    'lats',
    'upper_back',
    'traps',
    'rhomboids',
    'rear_delts',
    'lower_back',
  ],
  chest: ['chest', 'pecs', 'pectorals'],
  shoulders: ['front_delts', 'side_delts', 'rear_delts', 'shoulders'],
  legs: ['quads', 'hamstrings', 'glutes', 'calves', 'adductors', 'abductors'],
  arms: ['biceps', 'triceps', 'forearms'],
  core: ['abs', 'obliques', 'lower_back'],
};

const PHASE_LEVEL: Record<string, number> = {
  accumulation: 1,
  intensification: 2,
  realization: 3,
  deload: 1,
  transition: 1,
  general_preparation: 1,
};

const CONTRA_TIER_MULTIPLIER: Record<string, number> = {
  forbidden: 0.0,
  not_recommended: 0.1,
  low_weight: 0.25,
};

const CONTRA_TIER_ORDER: Record<string, number> = {
  low_weight: 1,
  not_recommended: 2,
  forbidden: 3,
};

const DEFAULT_PER_SET_TIME_SEC = 40;

const FOCUS_GROUP_MIN_EXERCISES: Record<string, number> = {
  chest: 2,
  back: 2,
  legs: 2,
  shoulders: 1,
  arms: 1,
  core: 1,
};

export interface WorkoutMILPInput {
  userId: string;
  sessionDurationMin: number | null;
  experienceLevel?: string;
  goal?: string;
  focusMuscles?: string[];
  specificMuscles?: string[];
  exerciseCount?: number;
  setsPerExercise?: number;
  restBetweenSetsSec?: number;
  compoundSets?: number;
  isolationSets?: number;
  availableEquipment: string[];
  phase?: string;
  fatigueByMuscle: Record<string, number>;
  usedExercises: string[];
  mandatoryMuscles?: string[];
  userContraindications?: string[];
  gender?: string;
  weeklyVolumeByMuscle?: Record<string, number>;
  activityLevel?: string;
  cardioPreference?: string;
  primaryLifts?: string[];
  enduranceType?: string;
  age?: number;
  heightCm?: number;
  weightKg?: number;
}

interface NormalizedWorkoutMILPInput {
  userId: string;
  sessionDurationMin: number;
  exerciseCount: number;
  setsPerExercise: number;
  compoundSets: number;
  isolationSets: number;
  restBetweenSetsSec: number;
  repsPerSet: number;
  experienceLevel: string;
  goal: string;
  gender: string;
  focusMuscles: string[];
  specificMuscles: string[];
  focusGroupMinimums: Record<string, number>;
  availableEquipment: string[];
  phase: string;
  fatigueByMuscle: Record<string, number>;
  usedExercises: string[];
  mandatoryMuscles: string[];
  userContraindications: string[];
  weeklyVolumeByMuscle: Record<string, number>;
  weeklyVolumeScale: number;
  cardioPreference?: string;
  primaryLifts?: string[];
  enduranceType?: string;
  age?: number;
  bmi?: number;
}

export interface WorkoutMILPOutput {
  exercises: {
    exerciseSlug: string;
    sets: number;
    repsPerSet: number;
    order: number;
    restBetweenSetsSec?: number;
    restAfterExerciseSec?: number;
  }[];
  totalLoadByMuscle: Record<string, number>;
  totalTimeSec: number;
  usedFallback?: boolean;
  partialCoverage?: boolean;
  unmetMandatory?: string[];
}

@Injectable()
export class WorkoutMilpService {
  private readonly logger = new Logger(WorkoutMilpService.name);

  constructor(
    @Inject(EXERCISES_REPOSITORY)
    private readonly exercisesRepository: IExercisesRepository,
    @Inject(WORKOUT_SESSIONS_REPOSITORY)
    private readonly sessionsRepository: IWorkoutSessionsRepository,
  ) {}

  async generateWorkout(input: WorkoutMILPInput): Promise<WorkoutMILPOutput> {
    const normalizedInput = this.normalizeInput(input);

    const allExercises = await this.loadAllExercises();

    const candidates = this.filterCandidates(allExercises, normalizedInput);

    this.logger.log(`MILP: ${candidates.length} candidates for ${normalizedInput.exerciseCount} exercises, goal=${normalizedInput.goal}`);

    const coverageCheck = this.checkCoverageFeasibility(
      candidates,
      normalizedInput,
    );

    if (candidates.length < normalizedInput.exerciseCount) {
      return this.fallbackSelection(candidates, normalizedInput, coverageCheck);
    }

    const weights = this.calculateWeights(candidates, normalizedInput);

    const { selected, usedFallback: lpUsedFallback } = this.solveLP(
      candidates,
      weights,
      normalizedInput,
      coverageCheck,
    );

    return this.buildOutput(
      selected,
      normalizedInput,
      coverageCheck,
      lpUsedFallback,
    );
  }

  private async loadAllExercises(): Promise<ExerciseMILPData[]> {
    const result = await this.exercisesRepository.findForMILP(1, 2000);
    return result.data;
  }

  private filterCandidates(
    exercises: ExerciseMILPData[],
    input: NormalizedWorkoutMILPInput,
  ): ExerciseMILPData[] {
    const normalizeEquipment = (slug: string): string =>
      slug.toLowerCase().replace(/[-_\s]/g, '');

    const isBodyweightEquipment = (slug: string): boolean => {
      const normalized = normalizeEquipment(slug);
      return [
        'bodyweight',
        'bodyweight',
        'bodyweight',
        'none',
        'body',
      ].includes(normalized);
    };

    return exercises.filter((ex) => {
      // Exclude forbidden contraindications
      if (input.userContraindications?.length && ex.contraindications?.length) {
        for (const c of ex.contraindications) {
          if (
            input.userContraindications.includes(c.slug) &&
            c.severity === 'forbidden'
          ) {
            return false;
          }
        }
      }

      // Equipment filtering
      const equipments = ex.equipments ?? [];
      const availableEquipment = input.availableEquipment ?? [];

      // If no available equipment specified → only bodyweight allowed
      if (availableEquipment.length === 0) {
        const hasOnlyBodyweight =
          equipments.length === 0 || equipments.every(isBodyweightEquipment);
        const exType = (ex.exerciseType ?? '').toLowerCase();
        const isLikelyBodyweight =
          ex.movementPattern === 'stretch' ||
          exType === 'mobility' ||
          exType === 'stretching' ||
          hasOnlyBodyweight;
        if (!isLikelyBodyweight) return false;
      } else {
        // Equipment specified → must have at least one matching
        const hasEquipment = equipments.some((eq) =>
          availableEquipment.some(
            (avail) => normalizeEquipment(eq) === normalizeEquipment(avail),
          ),
        );
        const needsEquipment =
          equipments.length > 0 && !equipments.some(isBodyweightEquipment);
        const hasNoData = equipments.length === 0;

        // If equipment is specified and none match -> drop
        if (needsEquipment && !hasEquipment) return false;

        // If no data about equipment: be conservative — drop unless tagged as bodyweight/stretch
        const exType = (ex.exerciseType ?? '').toLowerCase();
        const isLikelyBodyweight =
          ex.movementPattern === 'stretch' ||
          exType === 'mobility' ||
          exType === 'stretching';
        if (hasNoData && !isLikelyBodyweight) return false;
      }

      return true;
    });
  }

  private getWorstContraTier(
    ex: ExerciseMILPData,
    userContraindications: string[],
  ): string | null {
    if (!userContraindications.length || !ex.contraindications?.length) return null;
    let worstTier = 0;
    let worstSeverity: string | null = null;
    for (const c of ex.contraindications) {
      if (userContraindications.includes(c.slug)) {
        const tier = CONTRA_TIER_ORDER[c.severity] ?? 0;
        if (tier > worstTier) {
          worstTier = tier;
          worstSeverity = c.severity;
        }
      }
    }
    return worstSeverity;
  }

  private calculateWeights(
    candidates: ExerciseMILPData[],
    input: NormalizedWorkoutMILPInput,
  ): Map<string, number> {
    const weights = new Map<string, number>();
    const phase = input.phase;
    const phaseLevel = PHASE_LEVEL[phase] ?? 1;
    const sessionType = this.detectSessionType(input.mandatoryMuscles);
    const sessionTargets = SESSION_TARGETS[sessionType] ?? [];
    const sessionAvoid = SESSION_DEPRIORITIZE[sessionType] ?? [];
    const goalCfg = GOAL_CONFIG[input.goal] ?? GOAL_CONFIG.general_health;

    const specificSet = new Set(input.specificMuscles);
    const allFocusMuscles = new Set([
      ...input.focusMuscles,
      ...input.specificMuscles,
    ]);
    for (const focus of input.focusMuscles) {
      const hierarchy = MUSCLE_HIERARCHY[focus];
      if (hierarchy) {
        for (const child of hierarchy) {
          allFocusMuscles.add(child.slug);
        }
      }
    }

    for (const ex of candidates) {
      const meta = ex.metadata ?? {};

      const complexity = meta.complexityScore ?? 0.5;
      const fComplexity = 1 / (1 + Math.abs(complexity * 3 - phaseLevel));
      const fFrequency = 0.5;
      const fAffinity = meta.phaseAffinity?.includes(phase) ? 1 : 0;

      const wData =
        (1 + ALPHA_1 * fComplexity) *
        (1 + ALPHA_2 * fFrequency) *
        (1 + ALPHA_3 * fAffinity);

      const recentHits = input.usedExercises.filter(
        (slug) => slug === ex.slug,
      ).length;
      const diversityScore = Math.min(
        1,
        Math.max(0.2, 1 - recentHits / DIVERSITY_WINDOW),
      );
      const vE = diversityScore;

      let pE = 0;
      const muscleWeights = [
        ...(meta.primaryMuscleWeights ?? []),
        ...(meta.secondaryMuscleWeights ?? []),
      ].map((mw) => ({ ...mw, slug: this.normalizeSlug(mw.slug) }));
      for (const mw of muscleWeights) {
        const fatigue = input.fatigueByMuscle[mw.slug] ?? 0;
        if (fatigue > THETA) {
          pE += mw.weight * (fatigue - THETA);
        }
      }
      pE = Math.min(1, pE);

      let wE = wData * (1 + DELTA * vE) * (1 - EPSILON * pE);

      // Session-aware boosts
      const primaryMuscleCount = meta.primaryMuscleWeights?.length ?? 0;
      const coversTarget = (meta.primaryMuscleWeights ?? []).some((mw) =>
        sessionTargets.includes(this.normalizeSlug(mw.slug)),
      );
      if (coversTarget) {
        wE *= 1.2;
      }

      // Compound bonus — stronger for strength/hypertrophy goals
      if (primaryMuscleCount > 1) {
        const compoundBonus = goalCfg.preferCompound ? 0.1 : 0.05;
        wE *= 1 + Math.min(0.35, (primaryMuscleCount - 1) * compoundBonus);
      }

      // Deprioritize stretching/mobility for strength-ish sessions
      const exType = (ex.exerciseType ?? '').toLowerCase();
      const isStretchLike =
        exType === 'stretching' ||
        ex.movementPattern === 'stretch' ||
        sessionAvoid.includes(exType);
      if (
        sessionType !== 'cardio' &&
        sessionType !== 'mobility' &&
        isStretchLike
      ) {
        wE *= 0.4;
      } else if (sessionAvoid.includes(exType)) {
        wE *= 0.7;
      }

      // Goal exercise type bonus/penalty
      if (goalCfg.exerciseTypeBonus.includes(exType)) {
        wE *= 1.3;
      }
      if (goalCfg.exerciseTypePenalty.includes(exType)) {
        wE *= 0.5;
      }

      // Focus muscle bonus — soft boost for exercises hitting focus group muscles
      const hitsFocus = (meta.primaryMuscleWeights ?? []).some((mw) =>
        allFocusMuscles.has(this.normalizeSlug(mw.slug)),
      );
      if (hitsFocus) {
        wE *= 1.3;
      }

      // Specific muscle bonus — stronger boost for precisely targeted muscles
      const hitsSpecific = (meta.primaryMuscleWeights ?? []).some((mw) =>
        specificSet.has(this.normalizeSlug(mw.slug)),
      );
      if (hitsSpecific) {
        wE *= 1.5;
      }

      // Goal-specific intensity preference
      if (input.goal === 'strength' && (meta.fatigueCost ?? 5) >= 7) {
        wE *= 1.15;
      }
      if (input.goal === 'endurance' && (meta.fatigueCost ?? 5) <= 4) {
        wE *= 1.1;
      }

      // Weekly volume awareness: muscles already at/above weekly max get deprioritized
      const scale = input.weeklyVolumeScale;
      for (const mw of meta.primaryMuscleWeights ?? []) {
        const slug = this.normalizeSlug(mw.slug);
        const weeklyDone = input.weeklyVolumeByMuscle[slug] ?? 0;
        const target = MUSCLE_WEEKLY_VOLUME_TARGETS[slug];
        if (target) {
          const scaledMax = target.max * scale;
          const scaledMin = target.min * scale;
          if (weeklyDone >= scaledMax) {
            wE *= 0.3;
          } else if (weeklyDone < scaledMin * 0.5) {
            wE *= 1.3;
          }
        }
      }

      // Gender-aware muscle preference
      if (input.gender === 'female') {
        const femaleLowerMuscles = new Set([
          'glutes',
          'hamstrings',
          'adductors',
          'abductors',
        ]);
        const hitsFemaleLower = (meta.primaryMuscleWeights ?? []).some((mw) =>
          femaleLowerMuscles.has(this.normalizeSlug(mw.slug)),
        );
        if (hitsFemaleLower) {
          wE *= 1.3;
        }
      } else if (input.gender === 'male') {
        const maleUpperMuscles = new Set([
          'chest',
          'shoulders',
          'side_delts',
          'lats',
        ]);
        const hitsMaleUpper = (meta.primaryMuscleWeights ?? []).some((mw) =>
          maleUpperMuscles.has(this.normalizeSlug(mw.slug)),
        );
        if (hitsMaleUpper) {
          wE *= 1.2;
        }
      }

      const sets = this.isCompoundExercise(ex)
        ? input.compoundSets
        : input.isolationSets;
      const restSec = input.restBetweenSetsSec;
      const totalTime = this.calculateExerciseTime(meta, sets, restSec);
      const timeUtilFactor = Math.min(
        1,
        totalTime / (input.sessionDurationMin * 60),
      );
      wE *= 0.9 + 0.1 * timeUtilFactor;

      // Primary lifts boost (strength goal)
      if (input.primaryLifts?.length) {
        const exPattern = (ex.movementPattern ?? '').toLowerCase();
        const slugLower = ex.slug.toLowerCase();
        const isPrimaryLift = input.primaryLifts.some((lift) => {
          if (lift === 'squat' && (exPattern.includes('squat') || slugLower.includes('squat'))) return true;
          if (lift === 'bench' && (exPattern.includes('bench') || slugLower.includes('bench'))) return true;
          if (lift === 'deadlift' && (exPattern.includes('deadlift') || slugLower.includes('deadlift'))) return true;
          if (lift === 'ohp' && (exPattern.includes('press') && !exPattern.includes('leg'))) return true;
          return false;
        });
        if (isPrimaryLift) {
          wE *= 1.5;
        }
      }

      // Cardio preference (weight_loss / endurance)
      if (input.cardioPreference && input.cardioPreference !== 'any') {
        const isLocomotion = ex.movementPattern === 'locomotion';
        if (isLocomotion) {
          const slugLower = ex.slug.toLowerCase();
          const matchesPreference =
            (input.cardioPreference === 'running' && (slugLower.includes('run') || slugLower.includes('sprint') || slugLower.includes('jog'))) ||
            (input.cardioPreference === 'cycling' && (slugLower.includes('cycl') || slugLower.includes('bike'))) ||
            (input.cardioPreference === 'rowing' && (slugLower.includes('row'))) ||
            (input.cardioPreference === 'jump_rope' && (slugLower.includes('jump') || slugLower.includes('skip'))) ||
            (input.cardioPreference === 'swimming' && (slugLower.includes('swim')));
          if (matchesPreference) {
            wE *= 1.4;
          } else {
            wE *= 0.7;
          }
        }
      }

      // Endurance type (endurance goal)
      if (input.enduranceType) {
        const isLocomotion = ex.movementPattern === 'locomotion';
        const isCardioType = (ex.exerciseType ?? '').toLowerCase() === 'cardio';
        const exType = (ex.exerciseType ?? '').toLowerCase();
        if (input.enduranceType === 'cardio') {
          if (isLocomotion || isCardioType) wE *= 1.3;
          else if (exType === 'strength') wE *= 0.7;
        } else if (input.enduranceType === 'muscular') {
          if (isLocomotion) wE *= 0.6;
          if (exType === 'endurance' || exType === 'hypertrophy') wE *= 1.2;
        }
      }

      // Glute growth goal — strong glute/hamstring bonus
      if (input.goal === 'glute_growth') {
        const hitsGlutes = (meta.primaryMuscleWeights ?? []).some((mw) =>
          GLUTE_MUSCLES.has(this.normalizeSlug(mw.slug)),
        );
        if (hitsGlutes) {
          wE *= input.gender === 'female' ? 1.7 : 1.5;
        }
      }

      // Age > 50: penalize plyometric, bonus stability
      if (input.age && input.age > 50) {
        const exType = (ex.exerciseType ?? '').toLowerCase();
        if (exType === 'plyometric') wE *= 0.5;
        if (exType === 'stability' || exType === 'rehab') wE *= 1.2;
      }

      // BMI-based scoring
      if (input.bmi) {
        if (input.bmi > 30) {
          const isBodyweight = (ex.equipments ?? []).length === 0 ||
            (ex.equipments ?? []).every((eq) =>
              ['bodyweight', 'body weight', 'none'].includes(eq.toLowerCase()));
          if (isBodyweight) wE *= 0.7;
        }
        if (input.bmi < 18.5) {
          const isHighImpact = (ex.exerciseType ?? '').toLowerCase() === 'plyometric' ||
            (ex.movementPattern ?? '') === 'locomotion';
          if (isHighImpact) wE *= 0.8;
        }
      }

      wE -= meta.riskLevel ?? 0;

      const contraTier = this.getWorstContraTier(
        ex,
        input.userContraindications,
      );
      if (contraTier) {
        wE *= CONTRA_TIER_MULTIPLIER[contraTier] ?? 1;
      }

      weights.set(ex.slug, Math.max(0.01, wE));
    }

    return weights;
  }

  private resolveSessionDuration(
    sessionDurationMin: number | null,
    level: string,
    goal: string,
  ): number {
    if (sessionDurationMin != null) return sessionDurationMin;
    const levelDurations = DEFAULT_SESSION_DURATION[level] ?? DEFAULT_SESSION_DURATION.intermediate;
    return levelDurations[goal] ?? levelDurations.default ?? 60;
  }

  private normalizeInput(input: WorkoutMILPInput): NormalizedWorkoutMILPInput {
    const level = input.experienceLevel ?? 'intermediate';
    const goal = input.goal ?? 'general_health';
    const gender = input.gender ?? 'male';
    const preset = EXPERIENCE_PRESETS[level] ?? EXPERIENCE_PRESETS.intermediate;
    const goalCfg = GOAL_CONFIG[goal] ?? GOAL_CONFIG.general_health;
    const repRange = GOAL_REP_RANGES[goal] ?? GOAL_REP_RANGES.general_health;

    const repsPerSet = repRange.default;

    const sessionDurationMin = this.resolveSessionDuration(
      input.sessionDurationMin,
      level,
      goal,
    );

    const focusMuscles = (input.focusMuscles ?? []).map((m) =>
      this.normalizeSlug(m),
    );
    const specificMuscles = (input.specificMuscles ?? []).map((m) =>
      this.normalizeSlug(m),
    );

    const focusGroupMinimums: Record<string, number> = {};
    for (const focus of focusMuscles) {
      focusGroupMinimums[focus] = FOCUS_GROUP_MIN_EXERCISES[focus] ?? 1;
    }

    if (gender === 'female') {
      for (const focus of focusMuscles) {
        if (['legs', 'core'].includes(focus)) {
          focusGroupMinimums[focus] = Math.max(
            focusGroupMinimums[focus] ?? 1,
            (FOCUS_GROUP_MIN_EXERCISES[focus] ?? 1) + 1,
          );
        }
      }
    }

    const focusGroupCount = focusMuscles.length || 1;
    const extraForGroups = Math.max(0, focusGroupCount - 1);
    let exerciseCount =
      input.exerciseCount ?? preset.exerciseCount + extraForGroups;

    const setsPerExercise =
      input.setsPerExercise ??
      Math.max(2, Math.round(preset.setsPerExercise * goalCfg.setsMultiplier));
    const restBetweenSetsSec = input.restBetweenSetsSec ?? goalCfg.restSec;

    const roleDefaults = SETS_BY_ROLE[level] ?? SETS_BY_ROLE.intermediate;
    const goalModifier = SETS_GOAL_MODIFIER[goal] ?? {
      compound: 0,
      isolation: 0,
    };
    const compoundSets =
      input.compoundSets ??
      Math.max(2, roleDefaults.compound + goalModifier.compound);
    const isolationSets =
      input.isolationSets ??
      Math.max(2, roleDefaults.isolation + goalModifier.isolation);

    const avgSetsPerExercise = (compoundSets + isolationSets) / 2;
    const estTimePerExercise =
      DEFAULT_PER_SET_TIME_SEC * avgSetsPerExercise +
      restBetweenSetsSec * Math.max(0, avgSetsPerExercise - 1);
    const maxByTime = Math.floor(
      (sessionDurationMin * 60) / estTimePerExercise,
    );
    exerciseCount = Math.min(exerciseCount, Math.max(2, maxByTime));

    const expandedFromFocus: string[] = [];
    for (const focus of focusMuscles) {
      const hierarchy = MUSCLE_HIERARCHY[focus];
      if (hierarchy) {
        for (const child of hierarchy) {
          if (child.priority >= 0.5) {
            expandedFromFocus.push(child.slug);
          }
        }
      } else {
        expandedFromFocus.push(focus);
      }
    }

    if (
      gender === 'female' &&
      focusMuscles.some((f) => ['legs', 'core'].includes(f))
    ) {
      if (!expandedFromFocus.includes('glutes'))
        expandedFromFocus.push('glutes');
      if (!expandedFromFocus.includes('hamstrings'))
        expandedFromFocus.push('hamstrings');
    }

    const mandatoryMuscles = [
      ...(input.mandatoryMuscles ?? []).map((m) => this.normalizeSlug(m)),
      ...expandedFromFocus,
      ...specificMuscles,
    ];
    const uniqueMandatory = [...new Set(mandatoryMuscles)];

    const normFatigue: Record<string, number> = {};
    for (const [k, v] of Object.entries(input.fatigueByMuscle)) {
      normFatigue[this.normalizeSlug(k)] = v;
    }

    const weeklyVolumeByMuscle: Record<string, number> = {};
    for (const [k, v] of Object.entries(input.weeklyVolumeByMuscle ?? {})) {
      weeklyVolumeByMuscle[this.normalizeSlug(k)] = v;
    }

    let weeklyVolumeScale = preset.weeklyVolumeScale;
    if (input.activityLevel) {
      const activityScale = ACTIVITY_VOLUME_SCALE[input.activityLevel] ?? 1.0;
      weeklyVolumeScale *= activityScale;
    }
    const ageBucket = getAgeBucket(input.age);
    weeklyVolumeScale *= AGE_VOLUME_SCALE[ageBucket] ?? 1.0;

    const ageRestBucket = getAgeRestBucket(input.age);
    const ageRestMod = AGE_REST_MODIFIER[ageRestBucket] ?? 1.0;
    const adjustedRestSec = Math.round(restBetweenSetsSec * ageRestMod);

    if (goal === 'glute_growth') {
      if (!focusMuscles.includes('legs') && !focusMuscles.includes('glutes')) {
        focusMuscles.push('legs');
      }
      if (!expandedFromFocus.includes('glutes')) expandedFromFocus.push('glutes');
      if (!expandedFromFocus.includes('hamstrings')) expandedFromFocus.push('hamstrings');
      if (!expandedFromFocus.includes('adductors')) expandedFromFocus.push('adductors');
      if (gender === 'female' && !expandedFromFocus.includes('abductors')) {
        expandedFromFocus.push('abductors');
      }
    }

    const bmi = computeBMI(input.weightKg, input.heightCm);

    return {
      userId: input.userId,
      sessionDurationMin,
      exerciseCount,
      setsPerExercise,
      compoundSets,
      isolationSets,
      restBetweenSetsSec: adjustedRestSec,
      repsPerSet,
      experienceLevel: level,
      goal,
      gender,
      focusMuscles,
      specificMuscles,
      focusGroupMinimums,
      availableEquipment: input.availableEquipment,
      phase: input.phase ?? DEFAULT_PHASE,
      fatigueByMuscle: normFatigue,
      usedExercises: input.usedExercises ?? [],
      mandatoryMuscles: uniqueMandatory,
      userContraindications: input.userContraindications ?? [],
      weeklyVolumeByMuscle,
      weeklyVolumeScale,
      cardioPreference: input.cardioPreference,
      primaryLifts: input.primaryLifts,
      enduranceType: input.enduranceType,
      age: input.age,
      bmi: bmi ?? undefined,
    };
  }

  private solveLP(
    candidates: ExerciseMILPData[],
    weights: Map<string, number>,
    input: NormalizedWorkoutMILPInput,
    coverage: CoverageCheck,
  ): LPSolution {
    const timeLimitSec = input.sessionDurationMin * 60;
    const N = input.exerciseCount;

    const model: Record<string, unknown> = {
      optimize: 'score',
      opType: 'max',
      constraints: {
        exerciseCount: { equal: N },
        timeLimit: { max: timeLimitSec },
      },
      variables: {},
      ints: {},
    };

    const allMuscles = new Set<string>();
    for (const ex of candidates) {
      const meta = ex.metadata ?? {};
      for (const mw of meta.primaryMuscleWeights ?? []) {
        allMuscles.add(this.normalizeSlug(mw.slug));
      }
    }
    for (const muscle of allMuscles) {
      (model.constraints as Record<string, unknown>)[`fatigue_${muscle}`] = {
        max: FATIGUE_LIMIT,
      };
    }

    if (coverage.expandedMandatory?.size) {
      for (const muscle of coverage.expandedMandatory) {
        if (coverage.coverable.has(muscle)) {
          (model.constraints as Record<string, unknown>)[
            `mandatory_${muscle}`
          ] = {
            min: 1,
          };
        }
      }
    }

    for (const [group, min] of Object.entries(input.focusGroupMinimums)) {
      (model.constraints as Record<string, unknown>)[`focusGroup_${group}`] = {
        min,
      };
    }

    (model.constraints as Record<string, unknown>)['pushPullBalance'] = {
      max: N,
    };
    (model.constraints as Record<string, unknown>)['pullPushBalance'] = {
      max: N,
    };

    const variationGroups = new Set<string>();
    for (const ex of candidates) {
      const vg = ex.metadata?.variationGroup;
      if (vg) variationGroups.add(vg);
    }
    for (const vg of variationGroups) {
      (model.constraints as Record<string, unknown>)[`vg_${vg}`] = { max: 1 };
    }

    for (const ex of candidates) {
      const meta = ex.metadata ?? {};
      const isCompound = this.isCompoundExercise(ex);
      const sets = isCompound ? input.compoundSets : input.isolationSets;
      const restSec = input.restBetweenSetsSec;
      const totalTime = this.calculateExerciseTime(meta, sets, restSec);
      const weight = weights.get(ex.slug) ?? 0.01;
      const isPush = ['push', 'press'].includes(ex.movementPattern ?? '');
      const isPull = ['pull', 'row'].includes(ex.movementPattern ?? '');

      const variable: Record<string, number> = {
        score: weight,
        exerciseCount: 1,
        timeLimit: totalTime,
        pushPullBalance: isPush ? 1 : isPull ? -1 : 0,
        pullPushBalance: isPull ? 1 : isPush ? -1 : 0,
      };

      for (const mw of meta.primaryMuscleWeights ?? []) {
        const slug = this.normalizeSlug(mw.slug);
        variable[`fatigue_${slug}`] = mw.weight * (meta.fatigueCost ?? 5) * 0.1;
      }

      if (coverage.expandedMandatory?.size) {
        const coveredMuscles = new Set<string>();
        for (const mw of meta.primaryMuscleWeights ?? []) {
          const slug = this.normalizeSlug(mw.slug);
          if (
            coverage.expandedMandatory.has(slug) &&
            coverage.coverable.has(slug)
          ) {
            coveredMuscles.add(slug);
          }
        }
        for (const mw of meta.secondaryMuscleWeights ?? []) {
          const slug = this.normalizeSlug(mw.slug);
          if (
            coverage.expandedMandatory.has(slug) &&
            coverage.coverable.has(slug)
          ) {
            coveredMuscles.add(slug);
          }
        }
        for (const muscle of coveredMuscles) {
          variable[`mandatory_${muscle}`] = 1;
        }
      }

      for (const [group] of Object.entries(input.focusGroupMinimums)) {
        const groupMuscles = this.getGroupMuscles(group);
        const hitsGroup = [
          ...(meta.primaryMuscleWeights ?? []),
          ...(meta.secondaryMuscleWeights ?? []),
        ].some((mw) => groupMuscles.has(this.normalizeSlug(mw.slug)));
        if (hitsGroup) {
          variable[`focusGroup_${group}`] = 1;
        }
      }

      const vg = meta.variationGroup;
      if (vg) {
        variable[`vg_${vg}`] = 1;
      }

      (model.variables as Record<string, Record<string, number>>)[ex.slug] =
        variable;
      (model.ints as Record<string, number>)[ex.slug] = 1;
    }

    const results: Record<string, any> = solver.Solve(model as never) as Record<
      string,
      any
    >;
    const isFeasible = results.feasible !== false;

    if (!isFeasible) {
      const greedySelected = this.greedyFallback(
        candidates,
        weights,
        input,
        coverage,
      );
      return { selected: greedySelected, usedFallback: true };
    }

    const selected: ExerciseMILPData[] = [];
    for (const ex of candidates) {
      if (results[ex.slug] && results[ex.slug] > 0.5) {
        selected.push(ex);
      }
    }

    if (
      selected.length < N ||
      !this.isFeasibleSelection(selected, input, coverage)
    ) {
      const greedySelected = this.greedyFallback(
        candidates,
        weights,
        input,
        coverage,
      );
      return { selected: greedySelected, usedFallback: true };
    }

    return { selected, usedFallback: false };
  }

  private isFeasibleSelection(
    selected: ExerciseMILPData[],
    input: NormalizedWorkoutMILPInput,
    coverage?: CoverageCheck,
  ): boolean {
    if (selected.length < input.exerciseCount) {
      return false;
    }

    const mandatory = coverage?.mandatory;
    if (mandatory && mandatory.length > 0) {
      for (const muscle of mandatory) {
        const expanded = this.expandMuscleGroup(muscle);
        const isCovered = expanded.some((exp) =>
          selected.some((ex) => {
            const allMW = [
              ...(ex.metadata?.primaryMuscleWeights ?? []),
              ...(ex.metadata?.secondaryMuscleWeights ?? []),
            ];
            return allMW.some((mw) => this.normalizeSlug(mw.slug) === exp);
          }),
        );
        if (!isCovered) {
          return false;
        }
      }
    }

    return true;
  }

  private checkCoverageFeasibility(
    candidates: ExerciseMILPData[],
    input: NormalizedWorkoutMILPInput,
  ): CoverageCheck {
    const mandatory = input.mandatoryMuscles;
    const coverable = new Set<string>();

    if (mandatory.length === 0) {
      return { mandatory, coverable, expandedMandatory: new Set() };
    }

    const expandedMandatory = new Set<string>();
    for (const m of mandatory) {
      const expanded = this.expandMuscleGroup(m);
      expanded.forEach((e) => expandedMandatory.add(e));
    }

    for (const ex of candidates) {
      const meta = ex.metadata ?? {};
      for (const mw of meta.primaryMuscleWeights ?? []) {
        const slug = this.normalizeSlug(mw.slug);
        if (expandedMandatory.has(slug)) coverable.add(slug);
      }
      for (const mw of meta.secondaryMuscleWeights ?? []) {
        const slug = this.normalizeSlug(mw.slug);
        if (expandedMandatory.has(slug)) coverable.add(slug);
      }
    }

    return { mandatory, coverable, expandedMandatory };
  }

  private detectSessionType(mandatory: string[]): SessionType {
    const hasUpper = mandatory.some((m) =>
      [
        'chest',
        'back',
        'shoulders',
        'lats',
        'upper_back',
        'traps',
        'biceps',
        'triceps',
      ].includes(m),
    );
    const hasLower = mandatory.some((m) =>
      [
        'quads',
        'quadriceps',
        'hamstrings',
        'glutes',
        'calves',
        'legs',
        'leg',
      ].includes(m),
    );

    if (hasUpper && hasLower) return 'full_body';
    if (hasUpper) return 'upper';
    if (hasLower) return 'lower';
    return 'general';
  }

  private greedyFallback(
    candidates: ExerciseMILPData[],
    weights: Map<string, number>,
    input: NormalizedWorkoutMILPInput,
    coverage?: CoverageCheck,
  ): ExerciseMILPData[] {
    const timeLimitSec = input.sessionDurationMin * 60;
    const N = input.exerciseCount;
    const restSec = input.restBetweenSetsSec;

    const sorted = [...candidates].sort(
      (a, b) => (weights.get(b.slug) ?? 0) - (weights.get(a.slug) ?? 0),
    );

    const selected: ExerciseMILPData[] = [];
    const usedGroups = new Set<string>();
    const coveredMandatory = new Set<string>();
    const groupExerciseCount: Record<string, number> = {};
    let totalTime = 0;

    const canSelect = (ex: ExerciseMILPData): boolean => {
      const meta = ex.metadata ?? {};
      const sets = this.isCompoundExercise(ex)
        ? input.compoundSets
        : input.isolationSets;
      const exerciseTime = this.calculateExerciseTime(meta, sets, restSec);
      if (totalTime + exerciseTime > timeLimitSec) return false;

      const vg = meta.variationGroup;
      if (vg && usedGroups.has(vg)) {
        const missingMandatory = coverage?.expandedMandatory
          ? [...coverage.expandedMandatory].filter(
              (m) => !coveredMandatory.has(m),
            )
          : [];
        if (missingMandatory.length === 0 && selected.length >= N - 1) {
          return false;
        }
      }

      return true;
    };

    const select = (ex: ExerciseMILPData): void => {
      const meta = ex.metadata ?? {};
      const sets = this.isCompoundExercise(ex)
        ? input.compoundSets
        : input.isolationSets;
      const exerciseTime = this.calculateExerciseTime(meta, sets, restSec);
      selected.push(ex);
      totalTime += exerciseTime;

      const vg = meta.variationGroup;
      if (vg) usedGroups.add(vg);

      for (const mw of meta.primaryMuscleWeights ?? []) {
        const slug = this.normalizeSlug(mw.slug);
        if (coverage?.expandedMandatory?.has(slug)) {
          coveredMandatory.add(slug);
        }
      }
      for (const mw of meta.secondaryMuscleWeights ?? []) {
        const slug = this.normalizeSlug(mw.slug);
        if (coverage?.expandedMandatory?.has(slug)) {
          coveredMandatory.add(slug);
        }
      }

      for (const [group] of Object.entries(input.focusGroupMinimums)) {
        const groupMuscles = this.getGroupMuscles(group);
        const hitsGroup = [
          ...(meta.primaryMuscleWeights ?? []),
          ...(meta.secondaryMuscleWeights ?? []),
        ].some((mw) => groupMuscles.has(this.normalizeSlug(mw.slug)));
        if (hitsGroup) {
          groupExerciseCount[group] = (groupExerciseCount[group] ?? 0) + 1;
        }
      }
    };

    // Phase 1: Cover mandatory muscles (expanded from focus groups + specific)
    if (coverage?.expandedMandatory?.size) {
      for (const muscle of coverage.expandedMandatory) {
        if (coveredMandatory.has(muscle)) continue;

        const best = sorted.find((ex) => {
          if (selected.includes(ex)) return false;
          if (!canSelect(ex)) return false;
          return (ex.metadata?.primaryMuscleWeights ?? []).some(
            (mw) => this.normalizeSlug(mw.slug) === muscle,
          );
        });

        if (best) {
          select(best);
        }
      }
    }

    // Phase 2: Ensure per-focus-group minimums
    for (const [group, min] of Object.entries(input.focusGroupMinimums)) {
      const currentCount = groupExerciseCount[group] ?? 0;
      const deficit = min - currentCount;
      if (deficit <= 0) continue;

      const groupMuscles = this.getGroupMuscles(group);
      let added = 0;
      for (const ex of sorted) {
        if (added >= deficit) break;
        if (selected.includes(ex)) continue;
        if (!canSelect(ex)) continue;

        const hitsGroup = [
          ...(ex.metadata?.primaryMuscleWeights ?? []),
          ...(ex.metadata?.secondaryMuscleWeights ?? []),
        ].some((mw) => groupMuscles.has(this.normalizeSlug(mw.slug)));

        if (hitsGroup) {
          select(ex);
          added++;
        }
      }
    }

    // Phase 3: Fill remaining slots preferring mandatory coverage
    for (const ex of sorted) {
      if (selected.length >= N) break;

      if (selected.includes(ex)) continue;
      if (!canSelect(ex)) continue;

      if (coverage?.expandedMandatory?.size) {
        const missingMandatory = [...coverage.expandedMandatory].filter(
          (muscle) => !coveredMandatory.has(muscle),
        );
        const supportsMissing = missingMandatory.some((muscle) =>
          (ex.metadata?.primaryMuscleWeights ?? []).some(
            (mw) => this.normalizeSlug(mw.slug) === muscle,
          ),
        );

        if (missingMandatory.length > 0 && !supportsMissing) {
          continue;
        }
      }

      select(ex);
    }

    // Phase 4: Relaxed — allow any exercise regardless of mandatory coverage
    if (selected.length < N) {
      for (const ex of sorted) {
        if (selected.length >= N) break;
        if (selected.includes(ex)) continue;
        if (!canSelect(ex)) continue;
        select(ex);
      }
    }

    return selected;
  }

  private fallbackSelection(
    candidates: ExerciseMILPData[],
    input: NormalizedWorkoutMILPInput,
    coverage?: CoverageCheck,
  ): WorkoutMILPOutput {
    const weights = this.calculateWeights(candidates, input);
    const selected = this.greedyFallback(candidates, weights, input, coverage);
    return this.buildOutput(
      selected.slice(0, input.exerciseCount),
      input,
      coverage,
      true,
    );
  }

  private buildOutput(
    selected: ExerciseMILPData[],
    input: NormalizedWorkoutMILPInput,
    coverage?: CoverageCheck,
    usedFallback = false,
  ): WorkoutMILPOutput {
    const totalLoadByMuscle: Record<string, number> = {};
    let totalTimeSec = 0;
    const restSec = input.restBetweenSetsSec;

    const exercises = selected.map((ex, i) => {
      const meta = ex.metadata ?? {};
      const isCompound = this.isCompoundExercise(ex);
      const sets = isCompound ? input.compoundSets : input.isolationSets;
      const exerciseTime = this.calculateExerciseTime(meta, sets, restSec);
      totalTimeSec += exerciseTime;

      for (const mw of meta.primaryMuscleWeights ?? []) {
        const slug = this.normalizeSlug(mw.slug);
        const load = (meta.fatigueCost ?? 5) * mw.weight;
        totalLoadByMuscle[slug] = (totalLoadByMuscle[slug] ?? 0) + load;
      }
      for (const mw of meta.secondaryMuscleWeights ?? []) {
        const slug = this.normalizeSlug(mw.slug);
        const load = (meta.fatigueCost ?? 5) * mw.weight * 0.3;
        totalLoadByMuscle[slug] = (totalLoadByMuscle[slug] ?? 0) + load;
      }

      return {
        exerciseSlug: ex.slug,
        sets,
        repsPerSet: input.repsPerSet,
        order: i + 1,
        restBetweenSetsSec: restSec,
        restAfterExerciseSec: isCompound
          ? Math.round(restSec * 1.5)
          : restSec,
      };
    });

    const unmetMandatory = coverage?.mandatory
      ? coverage.mandatory.filter((m) => {
          const expanded = this.expandMuscleGroup(m);
          return !expanded.some((e) => coverage.coverable.has(e));
        })
      : [];
    const partialCoverage = unmetMandatory.length > 0;

    return {
      exercises,
      totalLoadByMuscle,
      totalTimeSec,
      usedFallback,
      partialCoverage,
      unmetMandatory,
    };
  }

  private expandMuscleGroup(slug: string): string[] {
    const normalized = this.normalizeSlug(slug);
    return MUSCLE_GROUPS[normalized] ?? [normalized];
  }

  private getGroupMuscles(group: string): Set<string> {
    const hierarchy = MUSCLE_HIERARCHY[group];
    if (hierarchy) {
      return new Set(hierarchy.map((h) => h.slug));
    }
    const groupMembers = MUSCLE_GROUPS[group];
    if (groupMembers) {
      return new Set(groupMembers);
    }
    return new Set([group]);
  }

  private calculateExerciseTime(
    meta: ExerciseMetadata | undefined,
    sets: number,
    restSec: number,
  ): number {
    const perSetTime = meta?.timeCostSec ?? DEFAULT_PER_SET_TIME_SEC;
    const totalTime = perSetTime * sets + restSec * Math.max(0, sets - 1);
    return totalTime;
  }

  async computeFatigueAndHistory(
    userId: string,
    daysBack: number = 14,
  ): Promise<{
    fatigueByMuscle: Record<string, number>;
    usedExercises: string[];
  }> {
    const sessions = await this.sessionsRepository.findRecentCompletedByUserId(
      userId,
      daysBack,
    );

    const fatigueByMuscle: Record<string, number> = {};
    const exerciseCounts: Record<string, number> = {};

    for (const session of sessions) {
      for (const ex of session.exercises ?? []) {
        exerciseCounts[ex.exerciseSlug] =
          (exerciseCounts[ex.exerciseSlug] ?? 0) + 1;

        const exercise = await this.exercisesRepository.findBySlug(
          ex.exerciseSlug,
        );
        if (exercise?.metadata) {
          for (const mw of exercise.metadata.primaryMuscleWeights ?? []) {
            const slug = this.normalizeSlug(mw.slug);
            const load =
              (exercise.metadata.fatigueCost ?? 5) * mw.weight * ex.sets;
            fatigueByMuscle[slug] = (fatigueByMuscle[slug] ?? 0) + load;
          }
          for (const mw of exercise.metadata.secondaryMuscleWeights ?? []) {
            const slug = this.normalizeSlug(mw.slug);
            const load =
              (exercise.metadata.fatigueCost ?? 5) * mw.weight * 0.3 * ex.sets;
            fatigueByMuscle[slug] = (fatigueByMuscle[slug] ?? 0) + load;
          }
        }
      }
    }

    const usedExercises = Object.keys(exerciseCounts);

    return { fatigueByMuscle, usedExercises };
  }

  async computeWeeklyVolume(userId: string): Promise<Record<string, number>> {
    const sessions = await this.sessionsRepository.findRecentCompletedByUserId(
      userId,
      7,
    );

    const volumeByMuscle: Record<string, number> = {};

    for (const session of sessions) {
      for (const ex of session.exercises ?? []) {
        const exercise = await this.exercisesRepository.findBySlug(
          ex.exerciseSlug,
        );
        if (exercise?.metadata) {
          const allMW = [
            ...(exercise.metadata.primaryMuscleWeights ?? []),
            ...(exercise.metadata.secondaryMuscleWeights ?? []),
          ];
          for (const mw of allMW) {
            const slug = this.normalizeSlug(mw.slug);
            volumeByMuscle[slug] = (volumeByMuscle[slug] ?? 0) + ex.sets;
          }
        }
      }
    }

    return volumeByMuscle;
  }

  async computeMetrics(input: {
    exercises: { exerciseSlug: string; sets: number }[];
    restBetweenSetsSec?: number;
    bodyweightKg?: number;
    goal?: string;
  }): Promise<{
    totalSets: number;
    totalReps: number;
    estimatedTonnageKg: number;
    relativeIntensity: number;
    activeTimeSec: number;
    restTimeSec: number;
    estimatedCalories: number;
    muscleLoadScores: Record<string, number>;
    fatigueIndex: number;
  }> {
    const restSec = input.restBetweenSetsSec ?? 90;
    const bodyweight = input.bodyweightKg ?? 70;
    const goal = input.goal ?? 'general_health';
    const repRange = GOAL_REP_RANGES[goal] ?? GOAL_REP_RANGES.general_health;
    const repsPerSet = repRange.default;

    let totalSets = 0;
    let totalReps = 0;
    let estimatedTonnageKg = 0;
    let activeTimeSec = 0;
    let restTimeSec = 0;
    const muscleLoadScores: Record<string, number> = {};
    let totalFatigue = 0;

    for (let i = 0; i < input.exercises.length; i++) {
      const exInput = input.exercises[i];
      const exercise = await this.exercisesRepository.findBySlug(
        exInput.exerciseSlug,
      );
      const meta = exercise?.metadata;
      const sets = exInput.sets;
      totalSets += sets;
      totalReps += sets * repsPerSet;

      const isCompound =
        (meta?.primaryMuscleWeights?.length ?? 0) > 1 ||
        ['squat', 'deadlift', 'press', 'row', 'clean', 'jerk', 'snatch'].some(
          (p) => (exercise?.movementPattern ?? '').toLowerCase().includes(p),
        );
      const loadPerRep = isCompound ? bodyweight * 0.6 : bodyweight * 0.3;
      estimatedTonnageKg += sets * repsPerSet * loadPerRep;

      const perSetTime = meta?.timeCostSec ?? DEFAULT_PER_SET_TIME_SEC;
      activeTimeSec += perSetTime * sets;
      if (i < input.exercises.length) {
        restTimeSec += restSec * Math.max(0, sets - 1);
      }

      const allMW = [
        ...(meta?.primaryMuscleWeights ?? []),
        ...(meta?.secondaryMuscleWeights ?? []),
      ];
      for (const mw of allMW) {
        const slug = this.normalizeSlug(mw.slug);
        const fatigueCost = meta?.fatigueCost ?? 5;
        const load = mw.weight * sets * fatigueCost * 0.1;
        muscleLoadScores[slug] = (muscleLoadScores[slug] ?? 0) + load;
      }

      totalFatigue += (meta?.fatigueCost ?? 5) * sets;
    }

    const sessionCapacity = totalSets * 10;
    const fatigueIndex = Math.min(
      100,
      Math.round((totalFatigue / Math.max(1, sessionCapacity)) * 100),
    );

    const goalIntensity: Record<string, number> = {
      strength: 85,
      hypertrophy: 72,
      endurance: 55,
      weight_loss: 60,
      general_health: 65,
      rehab: 40,
      mobility: 35,
    };
    const relativeIntensity = goalIntensity[goal] ?? 65;

    const metByGoal: Record<string, number> = {
      strength: 3.5,
      hypertrophy: 5.0,
      endurance: 6.0,
      weight_loss: 5.5,
      general_health: 4.0,
      rehab: 2.5,
      mobility: 2.0,
    };
    const met = metByGoal[goal] ?? 4.0;
    const activeTimeMin = activeTimeSec / 60;
    const estimatedCalories = Math.round(
      (met * bodyweight * activeTimeMin) / 60,
    );

    return {
      totalSets,
      totalReps,
      estimatedTonnageKg: Math.round(estimatedTonnageKg),
      relativeIntensity,
      activeTimeSec,
      restTimeSec,
      estimatedCalories,
      muscleLoadScores,
      fatigueIndex,
    };
  }

  private normalizeSlug(slug: string): string {
    return (MUSCLE_NORMALIZATION[slug.toLowerCase()] ?? slug).toLowerCase();
  }

  private isCompoundExercise(ex: ExerciseMILPData): boolean {
    const meta = ex.metadata ?? {};
    if ((meta.primaryMuscleWeights?.length ?? 0) > 1) return true;
    const mp = (ex.movementPattern ?? '').toLowerCase();
    if (
      ['squat', 'deadlift', 'press', 'row', 'clean', 'jerk', 'snatch'].some(
        (p) => mp.includes(p),
      )
    )
      return true;
    const et = (ex.exerciseType ?? '').toLowerCase();
    if (et === 'compound' || et === 'strength') return true;
    return false;
  }
}

interface CoverageCheck {
  mandatory: string[];
  coverable: Set<string>;
  expandedMandatory: Set<string>;
}

interface LPSolution {
  selected: ExerciseMILPData[];
  usedFallback: boolean;
}
