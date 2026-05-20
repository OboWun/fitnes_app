import { Inject, Injectable } from '@nestjs/common';
import {
  WORKOUT_DIALOGS_REPOSITORY,
  USERS_REPOSITORY,
  EQUIPMENTS_REPOSITORY,
  EQUIPMENT_PRESETS_REPOSITORY,
} from '../common/repositories/index.js';
import type {
  IWorkoutDialogsRepository,
  IUsersRepository,
  IEquipmentsRepository,
  IEquipmentPresetsRepository,
} from '../common/repositories/index.js';
import type { WorkoutDialog } from '../entities/index.js';
import type { Equipment } from '../entities/equipment.entity.js';
import type { EquipmentPreset } from '../entities/equipment-preset.entity.js';

type StepId =
  | 'plan_type'
  | 'goal'
  | 'experience'
  | 'focus_muscles'
  | 'equipment_preset'
  | 'equipment'
  | 'frequency'
  | 'days'
  | 'duration'
  | 'advanced_settings'
  | 'split'
  | 'activity_level'
  | 'cardio_preference'
  | 'primary_lifts'
  | 'endurance_type'
  | 'target_weight';

const STEP_ORDER: StepId[] = [
  'plan_type',
  'goal',
  'experience',
  'focus_muscles',
  'equipment_preset',
  'equipment',
  'frequency',
  'days',
  'duration',
  'advanced_settings',
  'split',
  'activity_level',
  'cardio_preference',
  'primary_lifts',
  'endurance_type',
  'target_weight',
];

interface StepDefinition {
  question: string;
  description?: string;
  inputType: 'single_choice' | 'multi_choice' | 'number';
  canSkip: boolean;
  getOptions: (ctx: StepContext) => { value: string; label: string }[];
}

interface StepContext {
  planType?: string;
  collectedParams: Record<string, unknown>;
  equipmentFromDb?: Equipment[];
  equipmentPresets?: EquipmentPreset[];
}

const GOAL_OPTIONS = [
  { value: 'strength', label: 'Сила' },
  { value: 'hypertrophy', label: 'Рост мышц (гипертрофия)' },
  { value: 'glute_growth', label: 'Накачать ягодицы' },
  { value: 'recomposition', label: 'Рельеф / подтянутое тело' },
  { value: 'endurance', label: 'Выносливость' },
  { value: 'weight_loss', label: 'Похудение' },
  { value: 'general_health', label: 'Общее здоровье' },
  { value: 'rehab', label: 'Реабилитация' },
  { value: 'mobility', label: 'Мобильность и растяжка' },
];

const EXPERIENCE_OPTIONS = [
  { value: 'beginner', label: 'Новичок (стаж до 1 года)' },
  { value: 'intermediate', label: 'Средний (1–3 года)' },
  { value: 'advanced', label: 'Продвинутый (3+ года)' },
];

const FOCUS_MUSCLE_OPTIONS = [
  { value: 'chest', label: 'Грудь' },
  { value: 'back', label: 'Спина' },
  { value: 'legs', label: 'Ноги' },
  { value: 'shoulders', label: 'Плечи' },
  { value: 'arms', label: 'Руки' },
  { value: 'core', label: 'Кор (пресс, поясница)' },
  { value: 'full_body', label: 'Всё тело (без акцента)' },
];

const FREQUENCY_OPTIONS = [
  { value: 'auto', label: 'Автоматически (рекомендуется)' },
  { value: '2', label: '2 раза в неделю' },
  { value: '3', label: '3 раза в неделю' },
  { value: '4', label: '4 раза в неделю' },
  { value: '5', label: '5 раз в неделю' },
  { value: '6', label: '6 раз в неделю' },
];

const DAYS_OPTIONS = [
  { value: 'monday', label: 'Понедельник' },
  { value: 'tuesday', label: 'Вторник' },
  { value: 'wednesday', label: 'Среда' },
  { value: 'thursday', label: 'Четверг' },
  { value: 'friday', label: 'Пятница' },
  { value: 'saturday', label: 'Суббота' },
  { value: 'sunday', label: 'Воскресенье' },
];

const DURATION_OPTIONS = [
  { value: 'auto', label: 'Автоматически (рекомендуется)' },
  { value: '20', label: '20 минут' },
  { value: '30', label: '30 минут' },
  { value: '45', label: '45 минут' },
  { value: '60', label: '60 минут' },
  { value: '75', label: '75 минут' },
  { value: '90', label: '90 минут' },
  { value: '120', label: '120 минут' },
];

const SPLIT_OPTIONS = [
  { value: 'auto', label: 'Автоматически (рекомендуется)' },
  { value: 'full_body', label: 'Фулбоди (всё тело)' },
  { value: 'upper_lower', label: 'Верх/Низ' },
  { value: 'ppl', label: 'Тяни/Толкай/Ноги (PPL)' },
];

const ACTIVITY_LEVEL_OPTIONS = [
  { value: 'sedentary', label: 'Сидячий (офис, минимум движения)' },
  { value: 'light', label: 'Лёгкий (прогулки, 1-2 тренировки)' },
  { value: 'moderate', label: 'Умеренный (регулярные тренировки)' },
  { value: 'active', label: 'Активный (ежедневные нагрузки)' },
];

const CARDIO_PREFERENCE_OPTIONS = [
  { value: 'any', label: 'Любое (без предпочтений)' },
  { value: 'running', label: 'Бег' },
  { value: 'cycling', label: 'Велосипед' },
  { value: 'rowing', label: 'Гребля' },
  { value: 'jump_rope', label: 'Скакалка' },
  { value: 'swimming', label: 'Плавание' },
];

const PRIMARY_LIFTS_OPTIONS = [
  { value: 'squat', label: 'Приседания' },
  { value: 'bench', label: 'Жим лёжа' },
  { value: 'deadlift', label: 'Становая тяга' },
  { value: 'ohp', label: 'Жим стоя (OHP)' },
];

const ENDURANCE_TYPE_OPTIONS = [
  { value: 'muscular', label: 'Мышечная выносливость (больше повторений)' },
  { value: 'cardio', label: 'Кардио (больше аэробных)' },
  { value: 'mixed', label: 'Смешанная' },
];

const STEP_DEFINITIONS: Record<StepId, StepDefinition> = {
  plan_type: {
    question: 'Что вы хотите получить?',
    inputType: 'single_choice',
    canSkip: false,
    getOptions: () => [
      { value: 'generate', label: 'Одну тренировку' },
      { value: 'weekly', label: 'План на неделю' },
    ],
  },
  goal: {
    question: 'Какова ваша основная цель?',
    description: 'Это определит диапазон повторений и отдых между подходами',
    inputType: 'single_choice',
    canSkip: false,
    getOptions: () => GOAL_OPTIONS,
  },
  experience: {
    question: 'Какой у вас уровень подготовки?',
    description: 'Это влияет на объём нагрузки и количество упражнений',
    inputType: 'single_choice',
    canSkip: false,
    getOptions: () => EXPERIENCE_OPTIONS,
  },
  focus_muscles: {
    question: 'На какие мышечные группы сделать акцент?',
    description:
      'Можно выбрать несколько. Выберите «Всё тело» для сбалансированной тренировки.',
    inputType: 'multi_choice',
    canSkip: true,
    getOptions: () => FOCUS_MUSCLE_OPTIONS,
  },
  equipment_preset: {
    question: 'Выберите оборудование или пресет',
    description:
      'Выберите готовый набор оборудования или «Выбрать вручную» для точной настройки',
    inputType: 'single_choice',
    canSkip: true,
    getOptions: (ctx) => {
      const result: { value: string; label: string }[] = [];
      const systemPresets = (ctx.equipmentPresets ?? []).filter(
        (p) => p.isSystem,
      );
      const userPresets = (ctx.equipmentPresets ?? []).filter(
        (p) => !p.isSystem,
      );
      for (const p of systemPresets) {
        result.push({ value: `preset:${p.id}`, label: p.name });
      }
      if (userPresets.length > 0) {
        for (const p of userPresets) {
          result.push({ value: `preset:${p.id}`, label: p.name });
        }
      }
      result.push({ value: 'manual', label: 'Выбрать вручную' });
      result.push({
        value: 'bodyweight_only',
        label: 'Только со своим весом',
      });
      return result;
    },
  },
  equipment: {
    question: 'Какое оборудование вам доступно?',
    description:
      'Можно выбрать несколько. Если ничего — выберите «Только со своим весом».',
    inputType: 'multi_choice',
    canSkip: true,
    getOptions: (ctx) => {
      const items = ctx.equipmentFromDb ?? [];
      const result = items.map((e) => ({ value: e.slug, label: e.name }));
      result.unshift({
        value: 'bodyweight_only',
        label: 'Только со своим весом',
      });
      return result;
    },
  },
  frequency: {
    question: 'Сколько тренировок в неделю вы планируете?',
    description: 'Выберите «Автоматически» — и мы подберём оптимальное количество',
    inputType: 'single_choice',
    canSkip: false,
    getOptions: () => FREQUENCY_OPTIONS,
  },
  days: {
    question: 'В какие дни вам удобно тренироваться?',
    description: 'Выберите дни, в которые вы сможете тренироваться',
    inputType: 'multi_choice',
    canSkip: false,
    getOptions: () => DAYS_OPTIONS,
  },
  duration: {
    question: 'Сколько минут длится ваша тренировка?',
    description: 'Выберите «Автоматически» — и мы подберём оптимальное время',
    inputType: 'single_choice',
    canSkip: false,
    getOptions: () => DURATION_OPTIONS,
  },
  advanced_settings: {
    question: 'Хотите настроить тренировки подробнее?',
    description: 'Рекомендуемые настройки подходят большинству. Выберите «Настроить» для точной настройки.',
    inputType: 'single_choice',
    canSkip: true,
    getOptions: () => [
      { value: 'recommended', label: 'Рекомендуемые настройки' },
      { value: 'manual', label: 'Настроить вручную' },
    ],
  },
  split: {
    question: 'Какой тип сплита предпочитаете?',
    description: 'Распределение мышечных групп по дням',
    inputType: 'single_choice',
    canSkip: true,
    getOptions: () => SPLIT_OPTIONS,
  },
  activity_level: {
    question: 'Какой у вас уровень повседневной активности?',
    description: 'Влияет на общий объём нагрузки',
    inputType: 'single_choice',
    canSkip: true,
    getOptions: () => ACTIVITY_LEVEL_OPTIONS,
  },
  cardio_preference: {
    question: 'Какой вид кардио предпочитаете?',
    inputType: 'single_choice',
    canSkip: true,
    getOptions: () => CARDIO_PREFERENCE_OPTIONS,
  },
  primary_lifts: {
    question: 'Вокруг каких базовых движений строить программу?',
    description: 'Можно выбрать несколько. Эти упражнения будут приоритетными.',
    inputType: 'multi_choice',
    canSkip: true,
    getOptions: () => PRIMARY_LIFTS_OPTIONS,
  },
  endurance_type: {
    question: 'Какой тип выносливости развиваем?',
    inputType: 'single_choice',
    canSkip: true,
    getOptions: () => ENDURANCE_TYPE_OPTIONS,
  },
  target_weight: {
    question: 'Какой ваш целевой вес (кг)?',
    description: 'Используется для отслеживания прогресса',
    inputType: 'number',
    canSkip: true,
    getOptions: () => [],
  },
};

@Injectable()
export class WorkoutDialogService {
  constructor(
    @Inject(WORKOUT_DIALOGS_REPOSITORY)
    private readonly dialogsRepository: IWorkoutDialogsRepository,
    @Inject(USERS_REPOSITORY)
    private readonly usersRepository: IUsersRepository,
    @Inject(EQUIPMENTS_REPOSITORY)
    private readonly equipmentsRepository: IEquipmentsRepository,
    @Inject(EQUIPMENT_PRESETS_REPOSITORY)
    private readonly presetsRepository: IEquipmentPresetsRepository,
  ) {}

  async startDialog(userId: string): Promise<{
    dialog: WorkoutDialog;
    step: StepId;
    question: string;
    description?: string;
    inputType: string;
    options: { value: string; label: string }[];
    canSkip: boolean;
  }> {
    const user = await this.usersRepository.findById(userId);
    const collectedParams: Record<string, unknown> = {};

    if (user?.metadata?.goal) {
      collectedParams.goal = user.metadata.goal;
    }
    if (user?.metadata?.experienceLevel) {
      collectedParams.experienceLevel = user.metadata.experienceLevel;
    }
    if (
      user?.metadata?.availableEquipment &&
      user.metadata.availableEquipment.length > 0
    ) {
      collectedParams.availableEquipment = user.metadata.availableEquipment;
    }

    const firstStep = this.getNextStep(collectedParams, undefined);
    if (firstStep === 'complete') {
      throw new Error('No steps available');
    }
    const dialog = await this.dialogsRepository.create({
      userId,
      currentStep: firstStep,
      collectedParams,
    });

    const ctx = await this.buildContext(dialog);
    const def = STEP_DEFINITIONS[firstStep];
    const options = def.getOptions(ctx);

    return {
      dialog,
      step: firstStep,
      question: def.question,
      description: def.description,
      inputType: def.inputType,
      options,
      canSkip: def.canSkip,
    };
  }

  async answerStep(
    dialogId: string,
    answer: string,
  ): Promise<
    | {
        completed: false;
        dialog: WorkoutDialog;
        step: StepId;
        question: string;
        description?: string;
        inputType: string;
        options: { value: string; label: string }[];
        canSkip: boolean;
      }
    | {
        completed: true;
        dialog: WorkoutDialog;
        planType: string;
        params: Record<string, unknown>;
      }
  > {
    const dialog = await this.dialogsRepository.findById(dialogId);
    if (!dialog) {
      throw new Error('Dialog not found');
    }

    const currentStep = dialog.currentStep as StepId;

    const validationCtx = await this.buildContext(dialog);
    const stepDef = STEP_DEFINITIONS[currentStep];
    if (stepDef.inputType === 'single_choice') {
      const validOptions = stepDef.getOptions(validationCtx).map((o) => o.value);
      if (!validOptions.includes(answer)) {
        return {
          completed: false,
          dialog,
          step: currentStep,
          question: stepDef.question,
          description: stepDef.description,
          inputType: stepDef.inputType,
          options: stepDef.getOptions(validationCtx),
          canSkip: stepDef.canSkip,
        };
      }
    }

    this.applyAnswer(dialog.collectedParams, currentStep, answer);

    if (
      currentStep === 'equipment_preset' &&
      dialog.collectedParams.equipmentPresetId
    ) {
      const presetId = dialog.collectedParams.equipmentPresetId as string;
      const preset = await this.presetsRepository.findById(presetId);
      if (preset) {
        dialog.collectedParams.availableEquipment = preset.equipmentSlugs;
      }
      delete dialog.collectedParams.equipmentPresetId;
    }

    let planType = dialog.planType;
    if (currentStep === 'plan_type') {
      planType = answer;
    }

    const nextStep = this.getNextStep(dialog.collectedParams, planType);

    if (nextStep === 'complete') {
      const updated = await this.dialogsRepository.update(dialogId, {
        currentStep: 'complete',
        planType,
        collectedParams: dialog.collectedParams,
      });

      const params = this.buildFinalParams(dialog.collectedParams, planType);

      return {
        completed: true,
        dialog: updated ?? dialog,
        planType: planType ?? 'generate',
        params,
      };
    }

    const updated = await this.dialogsRepository.update(dialogId, {
      currentStep: nextStep,
      planType,
      collectedParams: dialog.collectedParams,
    });

    const effectiveDialog = updated ?? dialog;
    effectiveDialog.currentStep = nextStep;
    effectiveDialog.planType = planType;

    const ctx = await this.buildContext(effectiveDialog);
    const def = STEP_DEFINITIONS[nextStep];
    const options = def.getOptions(ctx);

    return {
      completed: false,
      dialog: effectiveDialog,
      step: nextStep,
      question: def.question,
      description: def.description,
      inputType: def.inputType,
      options,
      canSkip: def.canSkip,
    };
  }

  async deleteDialog(dialogId: string, userId: string): Promise<boolean> {
    const dialog = await this.dialogsRepository.findById(dialogId);
    if (!dialog || dialog.userId !== userId) {
      return false;
    }
    return this.dialogsRepository.delete(dialogId);
  }

  async getState(dialogId: string): Promise<{
    dialog: WorkoutDialog;
    step: StepId;
    question: string;
    description?: string;
    inputType: string;
    options: { value: string; label: string }[];
    canSkip: boolean;
  } | null> {
    const dialog = await this.dialogsRepository.findById(dialogId);
    if (!dialog) return null;

    if (dialog.currentStep === 'complete') {
      return null;
    }

    const step = dialog.currentStep as StepId;
    const ctx = await this.buildContext(dialog);
    const def = STEP_DEFINITIONS[step];
    const options = def.getOptions(ctx);

    return {
      dialog,
      step,
      question: def.question,
      description: def.description,
      inputType: def.inputType,
      options,
      canSkip: def.canSkip,
    };
  }

  private getNextStep(
    collected: Record<string, unknown>,
    planType?: string,
  ): StepId | 'complete' {
    const effectivePlan =
      planType ?? (collected.planType as string | undefined);

    const isWeekly = effectivePlan === 'weekly';
    const isGenerate = effectivePlan === 'generate';
    const goal = collected.goal as string | undefined;
    const isManual =
      collected.advancedSettings === 'manual';

    const goalHasWeightLoss = goal === 'weight_loss';
    const goalHasStrength = goal === 'strength' || goal === 'glute_growth';
    const goalHasEndurance = goal === 'endurance';

    for (const step of STEP_ORDER) {
      if (step === 'plan_type') {
        if (collected.planType) continue;
        return step;
      }

      if (step === 'focus_muscles' && isWeekly) continue;
      if (step === 'frequency' && !isWeekly) continue;
      if (step === 'days' && !isWeekly) continue;
      if (step === 'split' && !isWeekly) continue;

      // Advanced settings gate
      if (step === 'advanced_settings') {
        if (collected.advancedSettings !== undefined) continue;
        return step;
      }

      // Steps after advanced_settings gate — only if manual
      if (
        step === 'split' ||
        step === 'activity_level' ||
        step === 'cardio_preference' ||
        step === 'primary_lifts' ||
        step === 'endurance_type' ||
        step === 'target_weight'
      ) {
        if (!isManual) continue;
      }

      // Goal-specific filtering
      if (step === 'split' && !isWeekly) continue;
      if (step === 'cardio_preference' && !goalHasWeightLoss && !goalHasEndurance) continue;
      if (step === 'primary_lifts' && !goalHasStrength) continue;
      if (step === 'endurance_type' && !goalHasEndurance) continue;
      if (step === 'target_weight' && !goalHasWeightLoss) continue;

      // Auto-skip days when frequency is auto
      if (step === 'days' && collected.trainingCountPerWeek === null) continue;

      // Skip already-answered steps
      if (step === 'goal' && collected.goal) continue;
      if (step === 'experience' && collected.experienceLevel) continue;
      if (step === 'focus_muscles' && collected.focusMuscles) continue;
      if (
        step === 'equipment_preset' &&
        collected.availableEquipment &&
        !collected.equipmentPresetManual
      )
        continue;
      if (step === 'equipment_preset' && collected.equipmentPresetManual)
        continue;
      if (step === 'equipment' && collected.availableEquipment) continue;
      if (step === 'frequency' && collected.trainingCountPerWeek !== undefined) continue;
      if (step === 'days' && collected.availableDays) continue;
      if (step === 'duration' && collected.sessionDurationMin !== undefined) continue;
      if (step === 'split' && collected.splitType) continue;
      if (step === 'activity_level' && collected.activityLevel) continue;
      if (step === 'cardio_preference' && collected.cardioPreference) continue;
      if (step === 'primary_lifts' && collected.primaryLifts) continue;
      if (step === 'endurance_type' && collected.enduranceType) continue;
      if (step === 'target_weight' && collected.targetWeightKg) continue;

      return step;
    }

    return 'complete';
  }

  private applyAnswer(
    collected: Record<string, unknown>,
    step: StepId,
    answer: string,
  ): void {
    switch (step) {
      case 'plan_type':
        collected.planType = answer;
        break;
      case 'goal':
        collected.goal = answer;
        break;
      case 'experience':
        collected.experienceLevel = answer;
        break;
      case 'focus_muscles': {
        if (answer === 'full_body') {
          collected.focusMuscles = [];
        } else {
          const existing = (collected.focusMuscles as string[]) ?? [];
          const set = new Set(existing);
          for (const v of answer.split(',')) {
            if (set.has(v)) {
              set.delete(v);
            } else {
              set.add(v);
            }
          }
          collected.focusMuscles = [...set];
        }
        break;
      }
      case 'equipment_preset': {
        if (answer === 'bodyweight_only') {
          collected.availableEquipment = [];
        } else if (answer === 'manual') {
          collected.equipmentPresetManual = true;
        } else if (answer.startsWith('preset:')) {
          collected.equipmentPresetId = answer.slice('preset:'.length);
        }
        break;
      }
      case 'equipment': {
        if (answer === 'bodyweight_only') {
          collected.availableEquipment = [];
        } else {
          const existing = (collected.availableEquipment as string[]) ?? [];
          const set = new Set(existing);
          for (const v of answer.split(',')) {
            if (set.has(v)) {
              set.delete(v);
            } else {
              set.add(v);
            }
          }
          collected.availableEquipment = [...set];
        }
        break;
      }
      case 'frequency':
        if (answer === 'auto') {
          collected.trainingCountPerWeek = null;
        } else {
          collected.trainingCountPerWeek = parseInt(answer, 10);
        }
        break;
      case 'days': {
        const existing = (collected.availableDays as string[]) ?? [];
        const set = new Set(existing);
        for (const v of answer.split(',')) {
          if (set.has(v)) {
            set.delete(v);
          } else {
            set.add(v);
          }
        }
        collected.availableDays = [...set];
        break;
      }
      case 'duration':
        if (answer === 'auto') {
          collected.sessionDurationMin = null;
        } else {
          collected.sessionDurationMin = parseInt(answer, 10);
        }
        break;
      case 'advanced_settings':
        collected.advancedSettings = answer;
        break;
      case 'split':
        collected.splitType = answer;
        break;
      case 'activity_level':
        collected.activityLevel = answer;
        break;
      case 'cardio_preference':
        collected.cardioPreference = answer;
        break;
      case 'primary_lifts': {
        const existing = (collected.primaryLifts as string[]) ?? [];
        const set = new Set(existing);
        for (const v of answer.split(',')) {
          if (set.has(v)) {
            set.delete(v);
          } else {
            set.add(v);
          }
        }
        collected.primaryLifts = [...set];
        break;
      }
      case 'endurance_type':
        collected.enduranceType = answer;
        break;
      case 'target_weight':
        collected.targetWeightKg = parseFloat(answer);
        break;
    }
  }

  private buildFinalParams(
    collected: Record<string, unknown>,
    planType?: string,
  ): Record<string, unknown> {
    const effective = planType ?? (collected.planType as string);

    const base: Record<string, unknown> = {
      experienceLevel: collected.experienceLevel ?? 'intermediate',
      goal: collected.goal ?? 'general_health',
      availableEquipment: collected.availableEquipment ?? [],
      sessionDurationMin: collected.sessionDurationMin ?? null,
      activityLevel: collected.activityLevel ?? undefined,
      cardioPreference: collected.cardioPreference ?? undefined,
      primaryLifts: collected.primaryLifts ?? undefined,
      enduranceType: collected.enduranceType ?? undefined,
      targetWeightKg: collected.targetWeightKg ?? undefined,
    };

    if (effective === 'weekly') {
      return {
        ...base,
        availableDays: collected.availableDays ?? [],
        trainingCountPerWeek: collected.trainingCountPerWeek ?? null,
        splitType: collected.splitType ?? 'auto',
      };
    }

    return {
      ...base,
      focusMuscles: collected.focusMuscles ?? [],
    };
  }

  private async buildContext(dialog: WorkoutDialog): Promise<StepContext> {
    const allEquipment = await this.equipmentsRepository.findAll();
    const systemPresets = await this.presetsRepository.findSystemPresets();
    let userPresets: EquipmentPreset[] = [];
    if (dialog.userId) {
      userPresets = await this.presetsRepository.findByUserId(dialog.userId);
    }
    return {
      planType:
        dialog.planType ??
        (dialog.collectedParams.planType as string | undefined),
      collectedParams: dialog.collectedParams,
      equipmentFromDb: allEquipment,
      equipmentPresets: [...systemPresets, ...userPresets],
    };
  }
}
