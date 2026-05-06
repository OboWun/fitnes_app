import { Inject, Injectable } from '@nestjs/common';
import { EXERCISES_REPOSITORY, WORKOUT_SESSIONS_REPOSITORY } from '../common/repositories/index.js';
import type { IExercisesRepository, IWorkoutSessionsRepository, ExerciseMILPData } from '../common/repositories/index.js';
import type { ExerciseMetadata, WorkoutSession } from '../entities/index.js';
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

type SessionType = 'upper' | 'lower' | 'full_body' | 'push' | 'pull' | 'cardio' | 'mobility' | 'general';

const SESSION_TARGETS: Record<SessionType, string[]> = {
  upper: ['chest', 'back', 'shoulders', 'lats', 'upper_back', 'traps'],
  push: ['chest', 'shoulders', 'triceps'],
  pull: ['back', 'lats', 'upper_back', 'traps', 'biceps'],
  lower: ['quads', 'hamstrings', 'glutes', 'calves'],
  full_body: ['chest', 'back', 'shoulders', 'quads', 'hamstrings', 'glutes', 'lats', 'upper_back'],
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
  back: ['lats', 'upper_back', 'traps', 'rhomboids', 'rear_delts', 'lower_back'],
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

const SEVERITY_MAP: Record<string, number> = {
  forbidden: 0.0,
  not_recommended: 0.5,
  low_weight: 0.8,
};

const DEFAULT_PER_SET_TIME_SEC = 40;
const DEFAULT_REST_BETWEEN_SETS_SEC = 90;

export interface WorkoutMILPInput {
  userId: string;
  sessionDurationMin: number;
  exerciseCount: number;
  setsPerExercise: number;
  restBetweenSetsSec?: number;
  availableEquipment: string[];
  phase?: string;
  fatigueByMuscle: Record<string, number>;
  usedExercises: string[];
  mandatoryMuscles?: string[];
  userContraindications?: string[];
}

export interface WorkoutMILPOutput {
  exercises: {
    exerciseSlug: string;
    sets: number;
    order: number;
  }[];
  totalLoadByMuscle: Record<string, number>;
  totalTimeSec: number;
  usedFallback?: boolean;
  partialCoverage?: boolean;
  unmetMandatory?: string[];
}

@Injectable()
export class WorkoutMilpService {
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

    const coverageCheck = this.checkCoverageFeasibility(candidates, normalizedInput);

    if (candidates.length < normalizedInput.exerciseCount) {
      return this.fallbackSelection(candidates, normalizedInput, coverageCheck);
    }

    // 3. Calculate weights for each candidate
    const weights = this.calculateWeights(candidates, normalizedInput);

    // 4. Build and solve LP
    const selected = this.solveLP(candidates, weights, normalizedInput, coverageCheck);

    // 5. Build output
    return this.buildOutput(selected, normalizedInput, coverageCheck);
  }

  private async loadAllExercises(): Promise<ExerciseMILPData[]> {
    const result = await this.exercisesRepository.findForMILP(1, 2000);
    return result.data;
  }

  private filterCandidates(
    exercises: ExerciseMILPData[],
    input: WorkoutMILPInput,
  ): ExerciseMILPData[] {
    const normalizeEquipment = (slug: string): string =>
      slug.toLowerCase().replace(/[-_\s]/g, '');

    const isBodyweightEquipment = (slug: string): boolean => {
      const normalized = normalizeEquipment(slug);
      return ['bodyweight', 'bodyweight', 'bodyweight', 'none', 'body'].includes(normalized);
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

  private calculateWeights(
    candidates: ExerciseMILPData[],
    input: WorkoutMILPInput,
  ): Map<string, number> {
    const weights = new Map<string, number>();
    const phase = input.phase ?? DEFAULT_PHASE;
    const phaseLevel = PHASE_LEVEL[phase] ?? 1;
    const sessionType = this.detectSessionType(input.mandatoryMuscles ?? []);
    const sessionTargets = SESSION_TARGETS[sessionType] ?? [];
    const sessionAvoid = SESSION_DEPRIORITIZE[sessionType] ?? [];

    for (const ex of candidates) {
      const meta = ex.metadata ?? {};

      // w_data = (1 + α1*f_complexity) * (1 + α2*f_frequency) * (1 + α3*f_affinity)
      const complexity = meta.complexityScore ?? 0.5;
      const fComplexity = 1 / (1 + Math.abs(complexity * 3 - phaseLevel));
      const fFrequency = 0.5; // no history yet
      const fAffinity = meta.phaseAffinity?.includes(phase) ? 1 : 0;

      const wData =
        (1 + ALPHA_1 * fComplexity) *
        (1 + ALPHA_2 * fFrequency) *
        (1 + ALPHA_3 * fAffinity);

      // Diversity: V_e (graded on recent use count within a short window)
      const recentHits = input.usedExercises.filter((slug) => slug === ex.slug).length;
      const diversityScore = Math.min(1, Math.max(0.2, 1 - recentHits / DIVERSITY_WINDOW));
      const vE = diversityScore;

      // Fatigue penalty: P_e
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

      // w_e = w_data * (1 + δ*V_e) * (1 - ε*P_e)
      let wE = wData * (1 + DELTA * vE) * (1 - EPSILON * pE);

      // Session-aware boosts
      const primaryMuscleCount = meta.primaryMuscleWeights?.length ?? 0;
      const coversTarget = (meta.primaryMuscleWeights ?? []).some((mw) =>
        sessionTargets.includes(this.normalizeSlug(mw.slug)),
      );
      if (coversTarget) {
        wE *= 1.2; // soft bonus for session targets
      }

      // Prefer compound exercises in strength sessions
      if (primaryMuscleCount > 1) {
        wE *= 1 + Math.min(0.25, (primaryMuscleCount - 1) * 0.05);
      }

      // Deprioritize stretching/mobility for strength-ish sessions (upper/lower/push/pull/full_body)
      const exType = (ex.exerciseType ?? '').toLowerCase();
      const isStretchLike = exType === 'stretching' || ex.movementPattern === 'stretch' || sessionAvoid.includes(exType);
      if (sessionType !== 'cardio' && sessionType !== 'mobility' && isStretchLike) {
        wE *= 0.4;
      } else if (sessionAvoid.includes(exType)) {
        wE *= 0.7;
      }

      // Mild reward for using more of the time budget (avoid ultra-short sets dominating)
      const sets = input.setsPerExercise;
      const restSec = input.restBetweenSetsSec ?? DEFAULT_REST_BETWEEN_SETS_SEC;
      const totalTime = this.calculateExerciseTime(meta, sets, restSec);
      const timeUtilFactor = Math.min(1, totalTime / (input.sessionDurationMin * 60));
      wE *= 0.9 + 0.1 * timeUtilFactor;

      // Contra penalty (soft: not_recommended, low_weight)
      if (input.userContraindications?.length && ex.contraindications?.length) {
        for (const c of ex.contraindications) {
          if (
            input.userContraindications.includes(c.slug) &&
            c.severity !== 'forbidden'
          ) {
            wE *= SEVERITY_MAP[c.severity] ?? 1;
          }
        }
      }

      // Risk penalty
      wE -= meta.riskLevel ?? 0;

      weights.set(ex.slug, Math.max(0.01, wE));
    }

    return weights;
  }

  private normalizeInput(input: WorkoutMILPInput): WorkoutMILPInput {
    const normMandatory = (input.mandatoryMuscles ?? []).map((m) => this.normalizeSlug(m));
    const normFatigue: Record<string, number> = {};
    for (const [k, v] of Object.entries(input.fatigueByMuscle)) {
      normFatigue[this.normalizeSlug(k)] = v;
    }

    const normUsed = input.usedExercises ?? [];

    return {
      ...input,
      mandatoryMuscles: normMandatory,
      fatigueByMuscle: normFatigue,
      usedExercises: normUsed,
    };
  }

  private solveLP(
    candidates: ExerciseMILPData[],
    weights: Map<string, number>,
    input: WorkoutMILPInput,
    coverage: CoverageCheck,
  ): ExerciseMILPData[] {
    const timeLimitSec = input.sessionDurationMin * 60;
    const N = input.exerciseCount;

    // Build model for javascript-lp-solver
    const model: Record<string, unknown> = {
      optimize: 'score',
      opType: 'max',
      constraints: {
        exerciseCount: { equal: N },
        timeLimit: { max: timeLimitSec },
      } as Record<string, unknown>,
      variables: {} as Record<string, Record<string, number>>,
      ints: {} as Record<string, number>,
    };

    // Add fatigue limit constraints per muscle
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

    // Add mandatory muscle constraints (use expanded muscles from groups like 'back' -> [lats, upper_back, traps])
    if (coverage.expandedMandatory?.size) {
      for (const muscle of coverage.expandedMandatory) {
        if (coverage.coverable.has(muscle)) {
          (model.constraints as Record<string, unknown>)[`mandatory_${muscle}`] = {
            min: 1,
          };
        }
      }
    }

    // Add push/pull balance constraints
    (model.constraints as Record<string, unknown>)['pushPullBalance'] = { max: 1 };
    (model.constraints as Record<string, unknown>)['pullPushBalance'] = { max: 1 };

    // Track variation groups
    const variationGroups = new Set<string>();
    for (const ex of candidates) {
      const vg = ex.metadata?.variationGroup;
      if (vg) variationGroups.add(vg);
    }
    for (const vg of variationGroups) {
      (model.constraints as Record<string, unknown>)[`vg_${vg}`] = { max: 1 };
    }

    // Add variables
    for (const ex of candidates) {
      const meta = ex.metadata ?? {};
      const sets = input.setsPerExercise;
      const restSec = input.restBetweenSetsSec ?? DEFAULT_REST_BETWEEN_SETS_SEC;
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

      // Fatigue per muscle
      for (const mw of meta.primaryMuscleWeights ?? []) {
        const slug = this.normalizeSlug(mw.slug);
        variable[`fatigue_${slug}`] = mw.weight * (meta.fatigueCost ?? 5) * 0.1;
      }

      // Mandatory muscles (only those coverable, use expanded mandatory set)
      // Use 1 for binary coverage: any exercise hitting this muscle contributes 1
      if (coverage.expandedMandatory?.size) {
        const coveredMuscles = new Set<string>();
        for (const mw of meta.primaryMuscleWeights ?? []) {
          const slug = this.normalizeSlug(mw.slug);
          if (coverage.expandedMandatory.has(slug) && coverage.coverable.has(slug)) {
            coveredMuscles.add(slug);
          }
        }
        for (const mw of meta.secondaryMuscleWeights ?? []) {
          const slug = this.normalizeSlug(mw.slug);
          if (coverage.expandedMandatory.has(slug) && coverage.coverable.has(slug)) {
            coveredMuscles.add(slug);
          }
        }
        for (const muscle of coveredMuscles) {
          variable[`mandatory_${muscle}`] = 1;
        }
      }

      // Variation group
      const vg = meta.variationGroup;
      if (vg) {
        variable[`vg_${vg}`] = 1;
      }

      (model.variables as Record<string, Record<string, number>>)[ex.slug] = variable;
      (model.ints as Record<string, number>)[ex.slug] = 1;
    }

    // Solve
    const results: Record<string, number> = solver.Solve(model as never) as Record<string, number>;

    // Extract selected exercises
    const selected: ExerciseMILPData[] = [];
    for (const ex of candidates) {
      if (results[ex.slug] && results[ex.slug] > 0.5) {
        selected.push(ex);
      }
    }

    // If solver couldn't find exact N or missed mandatory coverage, fall back.
    if (selected.length < N || !this.isFeasibleSelection(selected, input, coverage)) {
      return this.greedyFallback(candidates, weights, input, coverage);
    }

    return selected;
  }

  private isFeasibleSelection(selected: ExerciseMILPData[], input: WorkoutMILPInput, coverage?: CoverageCheck): boolean {
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

  private checkCoverageFeasibility(candidates: ExerciseMILPData[], input: WorkoutMILPInput): CoverageCheck {
    const mandatory = input.mandatoryMuscles ?? [];
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
    const hasUpper = mandatory.some((m) => ['chest', 'back', 'shoulders', 'lats', 'upper_back', 'traps', 'biceps', 'triceps'].includes(m));
    const hasLower = mandatory.some((m) => ['quads', 'quadriceps', 'hamstrings', 'glutes', 'calves', 'legs', 'leg'].includes(m));

    if (hasUpper && hasLower) return 'full_body';
    if (hasUpper) return 'upper';
    if (hasLower) return 'lower';
    return 'general';
  }

  private greedyFallback(
    candidates: ExerciseMILPData[],
    weights: Map<string, number>,
    input: WorkoutMILPInput,
    coverage?: CoverageCheck,
  ): ExerciseMILPData[] {
    const timeLimitSec = input.sessionDurationMin * 60;
    const N = input.exerciseCount;
    const sets = input.setsPerExercise;
    const restSec = input.restBetweenSetsSec ?? DEFAULT_REST_BETWEEN_SETS_SEC;

    const sorted = [...candidates].sort(
      (a, b) => (weights.get(b.slug) ?? 0) - (weights.get(a.slug) ?? 0),
    );

    const selected: ExerciseMILPData[] = [];
    const usedGroups = new Set<string>();
    const coveredMandatory = new Set<string>();
    let totalTime = 0;

    const canSelect = (ex: ExerciseMILPData): boolean => {
      const meta = ex.metadata ?? {};
      const exerciseTime = this.calculateExerciseTime(meta, sets, restSec);
      if (totalTime + exerciseTime > timeLimitSec) return false;

      const vg = meta.variationGroup;
      if (vg && usedGroups.has(vg)) {
        const missingMandatory = coverage?.expandedMandatory
          ? [...coverage.expandedMandatory].filter((m) => !coveredMandatory.has(m))
          : [];
        if (missingMandatory.length === 0 && selected.length >= N - 1) {
          return false;
        }
      }

      return true;
    };

    const select = (ex: ExerciseMILPData): void => {
      const meta = ex.metadata ?? {};
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
    };

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

    return selected;
  }

  private fallbackSelection(
    candidates: ExerciseMILPData[],
    input: WorkoutMILPInput,
    coverage?: CoverageCheck,
  ): WorkoutMILPOutput {
    const weights = this.calculateWeights(candidates, input);
    const selected = this.greedyFallback(candidates, weights, input, coverage);
    return this.buildOutput(selected.slice(0, input.exerciseCount), input, coverage, true);
  }

  private buildOutput(
    selected: ExerciseMILPData[],
    input: WorkoutMILPInput,
    coverage?: CoverageCheck,
    usedFallback = false,
  ): WorkoutMILPOutput {
    const totalLoadByMuscle: Record<string, number> = {};
    let totalTimeSec = 0;
    const sets = input.setsPerExercise;
    const restSec = input.restBetweenSetsSec ?? DEFAULT_REST_BETWEEN_SETS_SEC;

    const exercises = selected.map((ex, i) => {
      const meta = ex.metadata ?? {};
      const exerciseTime = this.calculateExerciseTime(meta, sets, restSec);
      totalTimeSec += exerciseTime;

      // Calculate load per muscle
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
        sets: input.setsPerExercise,
        order: i + 1,
      };
    });

    const unmetMandatory = coverage?.mandatory
      ? coverage.mandatory.filter((m) => {
          const expanded = this.expandMuscleGroup(m);
          return !expanded.some((e) => coverage.coverable.has(e));
        })
      : [];
    const partialCoverage = unmetMandatory.length > 0;

    return { exercises, totalLoadByMuscle, totalTimeSec, usedFallback, partialCoverage, unmetMandatory };
  }

  private expandMuscleGroup(slug: string): string[] {
    const normalized = this.normalizeSlug(slug);
    return MUSCLE_GROUPS[normalized] ?? [normalized];
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
  ): Promise<{ fatigueByMuscle: Record<string, number>; usedExercises: string[] }> {
    const sessions = await this.sessionsRepository.findRecentCompletedByUserId(userId, daysBack);

    const fatigueByMuscle: Record<string, number> = {};
    const exerciseCounts: Record<string, number> = {};

    for (const session of sessions) {
      for (const ex of session.exercises ?? []) {
        exerciseCounts[ex.exerciseSlug] = (exerciseCounts[ex.exerciseSlug] ?? 0) + 1;

        const exercise = await this.exercisesRepository.findBySlug(ex.exerciseSlug);
        if (exercise?.metadata) {
          for (const mw of exercise.metadata.primaryMuscleWeights ?? []) {
            const slug = this.normalizeSlug(mw.slug);
            const load = (exercise.metadata.fatigueCost ?? 5) * mw.weight * ex.sets;
            fatigueByMuscle[slug] = (fatigueByMuscle[slug] ?? 0) + load;
          }
          for (const mw of exercise.metadata.secondaryMuscleWeights ?? []) {
            const slug = this.normalizeSlug(mw.slug);
            const load = (exercise.metadata.fatigueCost ?? 5) * mw.weight * 0.3 * ex.sets;
            fatigueByMuscle[slug] = (fatigueByMuscle[slug] ?? 0) + load;
          }
        }
      }
    }

    const usedExercises = Object.keys(exerciseCounts);

    return { fatigueByMuscle, usedExercises };
  }

  private normalizeSlug(slug: string): string {
    return (MUSCLE_NORMALIZATION[slug.toLowerCase()] ?? slug).toLowerCase();
  }
}

interface CoverageCheck {
  mandatory: string[];
  coverable: Set<string>;
  expandedMandatory: Set<string>;
}
