const fs = require('fs');
const path = require('path');

const filePath = path.join(process.cwd(), 'data', 'exercises.json');

const exerciseTypeValues = new Set([
  'strength',
  'hypertrophy',
  'endurance',
  'mobility',
  'stability',
  'cardio',
  'plyometric',
  'rehab',
  'stretching',
]);

const movementPatterns = new Set([
  'push',
  'pull',
  'squat',
  'hinge',
  'lunge',
  'carry',
  'rotate',
  'anti_rotate',
  'jump',
  'crawl',
  'press',
  'row',
  'curl',
  'extension',
  'flexion',
  'abduction',
  'adduction',
  'rotation',
  'stabilization',
  'locomotion',
  'stretch',
]);

const difficultyValues = new Set(['beginner', 'intermediate', 'advanced']);

const muscleNames = {
  traps: 'трапециевидные мышцы',
  shoulders: 'плечевой пояс',
  deltoids: 'дельтовидные мышцы',
  delts: 'дельтовидные мышцы',
  triceps: 'трицепсы',
  biceps: 'бицепсы',
  forearms: 'предплечья',
  chest: 'грудные мышцы',
  pectorals: 'грудные мышцы',
  lats: 'широчайшие мышцы спины',
  back: 'мышцы спины',
  'upper back': 'верх спины',
  'lower back': 'поясница',
  abs: 'мышцы кора',
  core: 'мышцы кора',
  waist: 'мышцы кора',
  glutes: 'ягодичные мышцы',
  quadriceps: 'квадрицепсы',
  hamstrings: 'бицепсы бедра',
  calves: 'икроножные мышцы',
  abductors: 'отводящие мышцы бедра',
  adductors: 'приводящие мышцы бедра',
  'upper arms': 'мышцы верхней части рук',
  'lower arms': 'мышцы предплечий',
  'upper legs': 'мышцы ног',
  'lower legs': 'мышцы голени',
  neck: 'мышцы шеи',
  cardio: 'сердечно-сосудистую выносливость',
};

const bodyPartNames = {
  chest: 'грудной клетке',
  back: 'спине',
  shoulders: 'плечах',
  neck: 'шее',
  waist: 'коре',
  cardio: 'сердечно-сосудистой системе',
  'upper arms': 'верхней части рук',
  'lower arms': 'предплечьях',
  'upper legs': 'ногах',
  'lower legs': 'голенях',
};

const equipmentNames = {
  band: 'эспандером',
  barbell: 'штангой',
  dumbbell: 'гантелями',
  kettlebell: 'гирей',
  cable: 'блоком',
  'body weight': 'собственным весом',
  'leverage machine': 'рычажным тренажёром',
  'stationary bike': 'велотренажёром',
  'exercise ball': 'фитболом',
  'stability ball': 'фитболом',
  'bosu ball': 'BOSU-мячом',
  hammer: 'молотом',
  rope: 'канатом',
  'smith machine': 'машиной Смита',
  machine: 'тренажёром',
};

const translationCache = new Map();

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function uniqueStrings(values) {
  return [...new Set(values.map((value) => value.trim()).filter(Boolean))];
}

function humanizeSlug(slug) {
  return slug
    .replace(/[()]/g, ' ')
    .replace(/[-_]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function titleCaseFirst(text) {
  if (!text) return text;
  return text.charAt(0).toUpperCase() + text.slice(1);
}

function cleanupTranslatedName(text, exercise) {
  let result = text
    .replace(/\s+/g, ' ')
    .replace(/\bbody weight\b/gi, 'собственным весом')
    .replace(/\bbodyweight\b/gi, 'собственным весом')
    .replace(/\bstability ball\b/gi, 'фитболом')
    .replace(/\bexercise ball\b/gi, 'фитболом')
    .replace(/\bbosu ball\b/gi, 'BOSU-мячом')
    .replace(/\bbarbell\b/gi, 'штангой')
    .replace(/\bdumbbell\b/gi, 'гантелями')
    .replace(/\bkettlebell\b/gi, 'гирей')
    .replace(/\bband\b/gi, 'эспандером')
    .replace(/\bcable\b/gi, 'блоком')
    .replace(/\bleverage machine\b/gi, 'рычажным тренажёром')
    .replace(/\bstationary bike\b/gi, 'велотренажёром')
    .replace(/\bsmith machine\b/gi, 'машиной Смита')
    .replace(/\brope\b/gi, 'канатом')
    .replace(/\bhammer\b/gi, 'молотом');

  if (exercise.equipments?.includes('band')) {
    result = result.replace(/\bлент(а|ой|ы|у|е|ею|ом)?\b/gi, 'эспандером');
  }

  return titleCaseFirst(result.replace(/\s+/g, ' ').trim());
}

async function translateText(text) {
  if (translationCache.has(text)) {
    return translationCache.get(text);
  }

  const promise = (async () => {
    let lastError;
    for (let attempt = 1; attempt <= 4; attempt++) {
      try {
        const params = new URLSearchParams({ client: 'gtx', sl: 'auto', tl: 'ru', dt: 't', q: text });
        const res = await fetch(`https://translate.googleapis.com/translate_a/single?${params.toString()}`);
        if (!res.ok) {
          throw new Error(`Translate request failed: ${res.status} ${res.statusText}`);
        }

        const json = await res.json();
        const translated = json?.[0]?.[0]?.[0];
        if (typeof translated !== 'string') {
          throw new Error('Unexpected translation response shape');
        }

        return translated.replace(/\n$/u, '').trim();
      } catch (error) {
        lastError = error;
        await new Promise((resolve) => setTimeout(resolve, 250 * attempt));
      }
    }

    throw lastError;
  })();

  translationCache.set(text, promise);
  return promise;
}

function chooseNormalizedName(translated, fallback, exercise) {
  const translatedScore = (translated.match(/[А-Яа-яЁё]/g) || []).length - (translated.match(/[A-Za-z]/g) || []).length * 2;
  const fallbackScore = (fallback.match(/[А-Яа-яЁё]/g) || []).length - (fallback.match(/[A-Za-z]/g) || []).length * 2;
  const selected = translatedScore >= fallbackScore ? translated : fallback;
  return cleanupTranslatedName(selected, exercise);
}

function inferMovementPattern(exercise) {
  const source = `${exercise.slug} ${exercise.name}`.toLowerCase();

  const rules = [
    ['stretch', ['stretch', 'растяж', 'mobility']],
    ['cardio', ['stationary bike', 'bike', 'run', 'runner', 'cardio', 'rowing', 'skip', 'jump rope']],
    ['jump', ['jump', 'plyo', 'burpee', 'depth jump', 'box jump', 'hop']],
    ['carry', ['carry', 'farmer', 'suitcase', 'waiter', 'overhead carry']],
    ['anti_rotate', ['pallof', 'anti rotate', 'anti-rotate']],
    ['rotation', ['twist', 'rotation', 'rotary', 'windmill', 'woodchop']],
    ['squat', ['squat', 'hack', 'pistol', 'curtsy', 'wall sit']],
    ['lunge', ['lunge', 'split squat', 'step up', 'step-up', 'forward lunge', 'reverse lunge']],
    ['hinge', ['deadlift', 'romanian', 'stiff leg', 'good morning', 'hip thrust', 'glute bridge', 'swing']],
    ['row', ['row', 'pulldown', 'pull down', 'lat', 'reverse fly', 'face pull']],
    ['curl', ['curl', 'preacher', 'hammer curl', 'biceps curl']],
    ['extension', ['extension', 'kickback', 'pushdown', 'triceps']],
    ['flexion', ['crunch', 'sit-up', 'sit up', 'knee raise', 'leg raise', 'bend']],
    ['abduction', ['abduction', 'abduct', 'lateral raise']],
    ['adduction', ['adduction', 'adduct', 'fly', 'crossover']],
    ['press', ['press', 'bench', 'incline', 'decline', 'shoulder press', 'overhead press']],
    ['push', ['push up', 'push-up', 'dip', 'planche', 'handstand push', 'floor press']],
    ['pull', ['pull up', 'pull-up', 'chin up', 'chin-up', 'pulling']],
    ['stabilization', ['plank', 'hold', 'stability', 'balance', 'isometric']],
    ['crawl', ['crawl', 'bear crawl', 'lizard crawl']],
    ['locomotion', ['walk', 'run', 'march', 'bike', 'cycle']],
  ];

  for (const [pattern, keywords] of rules) {
    if (keywords.some((keyword) => source.includes(keyword))) {
      return pattern;
    }
  }

  if (exercise.bodyParts.includes('cardio')) return 'locomotion';
  if (exercise.targetMuscles.some((m) => ['abs', 'core', 'waist'].includes(m))) return 'flexion';
  if (exercise.targetMuscles.some((m) => ['biceps'].includes(m))) return 'curl';
  if (exercise.targetMuscles.some((m) => ['triceps'].includes(m))) return 'extension';
  return 'stabilization';
}

function inferExerciseType(exercise, movementPattern) {
  if (movementPattern === 'stretch') return 'stretching';
  if (movementPattern === 'stabilization') return 'stability';
  if (movementPattern === 'cardio' || movementPattern === 'locomotion') return 'cardio';
  if (movementPattern === 'jump') return 'plyometric';
  if (movementPattern === 'crawl') return 'endurance';
  if (['curl', 'extension', 'abduction', 'adduction', 'flexion', 'rotation', 'anti_rotate'].includes(movementPattern)) {
    return 'hypertrophy';
  }
  return 'strength';
}

function inferDifficulty(exercise, movementPattern) {
  const source = `${exercise.slug} ${exercise.name}`.toLowerCase();
  const advancedKeywords = ['one arm', 'single arm', 'one leg', 'single leg', 'archer', 'handstand', 'planche', 'turkish get up', 'judo flip', 'bosu', 'suspended', 'unstable', 'olympic', 'snatch', 'clean', 'depth jump', 'pistol'];
  const beginnerKeywords = ['stretch', 'stationary bike', 'walk', 'cycle', 'curl', 'extension', 'abduction', 'adduction'];

  if (movementPattern === 'stretch') return 'beginner';
  if (movementPattern === 'cardio' || movementPattern === 'locomotion') return 'beginner';
  if (advancedKeywords.some((keyword) => source.includes(keyword))) return 'advanced';
  if (beginnerKeywords.some((keyword) => source.includes(keyword))) return 'beginner';
  return 'intermediate';
}

function muscleLabel(slug) {
  return muscleNames[slug] || slug;
}

function bodyPartLabel(slug) {
  return bodyPartNames[slug] || slug;
}

function equipmentLabel(slug) {
  return equipmentNames[slug] || slug;
}

function buildDescription(exercise, movementPattern, exerciseType) {
  const muscles = uniqueStrings(exercise.targetMuscles.slice(0, 2).map(muscleLabel));
  const musclesText = muscles.length === 1 ? muscles[0] : muscles.join(' и ');
  const equipmentText = uniqueStrings(exercise.equipments.slice(0, 2).map(equipmentLabel)).join(' и ');
  const bodyText = uniqueStrings(exercise.bodyParts.slice(0, 1).map(bodyPartLabel))[0] || 'теле';

  const movementSentences = {
    stretch: `Растягивает и улучшает подвижность в ${bodyText}.`,
    stabilization: `Развивает контроль корпуса и устойчивость в ${bodyText}.`,
    cardio: 'Помогает развивать общую выносливость и поддерживать кардионагрузку.',
    plyometric: 'Развивает взрывную силу, скорость и координацию.',
    squat: 'Основная нагрузка приходится на ягодицы, квадрицепсы и мышцы задней поверхности бедра.',
    hinge: 'Смещение нагрузки идёт в ягодицы, бицепсы бедра и разгибатели спины.',
    lunge: 'Хорошо нагружает ягодицы, квадрицепсы и мышцы стабилизации таза.',
    carry: 'Укрепляет хват, корпус и стабилизаторы плечевого пояса.',
    rotate: 'Нагружает косые мышцы живота и улучшает контроль корпуса.',
    anti_rotate: 'Тренирует сопротивление вращению и контроль корпуса.',
    jump: 'Развивает взрывную силу ног и координацию.',
    crawl: 'Тренирует координацию, выносливость и стабилизацию корпуса.',
    press: 'Включает грудные мышцы, плечи и трицепсы.',
    push: 'Включает грудные мышцы, плечи и трицепсы.',
    pull: 'Прорабатывает мышцы спины, задние дельты и бицепсы.',
    row: 'Прорабатывает мышцы спины, задние дельты и бицепсы.',
    curl: 'Изолирует бицепсы и мышцы предплечий.',
    extension: 'Смещает акцент на трицепсы и разгибатели рук.',
    flexion: 'Нагружает мышцы кора и сгибатели туловища.',
    abduction: 'Развивает отводящие мышцы и стабилизаторы таза.',
    adduction: 'Нагружает приводящие мышцы и внутреннюю поверхность бедра.',
    rotation: 'Развивает вращательную силу корпуса и контроль движения.',
    locomotion: 'Развивает общую работоспособность и выносливость.',
  };

  const introByType = {
    strength: 'Силовое упражнение',
    hypertrophy: 'Упражнение для гипертрофии',
    endurance: 'Упражнение на выносливость',
    mobility: 'Упражнение на мобильность',
    stability: 'Упражнение на стабилизацию',
    cardio: 'Кардиоупражнение',
    plyometric: 'Плиометрическое упражнение',
    rehab: 'Восстановительное упражнение',
    stretching: 'Растягивающее упражнение',
  };

  const intro = introByType[exerciseType] || 'Упражнение';
  const equipmentSentence = equipmentText ? ` Выполняется с ${equipmentText}.` : '';
  const targetSentence = musclesText ? ` Для ${musclesText}.` : '';
  const movementSentence = movementSentences[movementPattern] || 'Подходит для развития общей физической формы.';

  return `${intro}${targetSentence}${equipmentSentence} ${movementSentence}`.replace(/\s+/g, ' ').trim();
}

function buildAlias(exercise, normalizedName) {
  const aliases = [normalizedName];
  const original = exercise.name?.trim();
  if (original && original !== normalizedName) aliases.push(original);
  aliases.push(titleCaseFirst(humanizeSlug(exercise.slug)));

  const stripped = normalizedName
    .replace(/^((С|Со|На|В|Для)\s+)?(Эспандером|Гантелями|Штангой|Гирей|Блоком|Собственным весом|Рычажным тренажёром|Велотренажёром|Фитболом|BOSU-мячом)\s+/i, '')
    .trim();
  if (stripped && stripped !== normalizedName) aliases.push(stripped);

  return uniqueStrings(aliases);
}

function computeConfidence(exercise, normalizedName, alias, movementPattern, exerciseType, difficulty, description) {
  const latinPenalty = (exercise.name.match(/[A-Za-z]/g) || []).length > 0 ? 0.08 : 0;
  const nameScore = (normalizedName.match(/[А-Яа-яЁё]/g) || []).length > (normalizedName.match(/[A-Za-z]/g) || []).length ? 0.18 : 0.1;
  const movementScore = movementPatterns.has(movementPattern) ? 0.18 : 0.08;
  const typeScore = exerciseTypeValues.has(exerciseType) ? 0.14 : 0.08;
  const difficultyScore = difficultyValues.has(difficulty) ? 0.08 : 0.04;
  const aliasScore = alias.length >= 2 ? 0.06 : 0.03;
  const descriptionScore = description ? 0.08 : 0.02;
  const dataCompleteness = (exercise.targetMuscles.length ? 0.05 : 0) + (exercise.bodyParts.length ? 0.03 : 0) + (exercise.equipments.length ? 0.03 : 0);

  return Number(clamp(0.45 + nameScore + movementScore + typeScore + difficultyScore + aliasScore + descriptionScore + dataCompleteness - latinPenalty, 0, 1).toFixed(2));
}

function scoreVariation(base, candidate) {
  if (base.slug === candidate.slug) return -1;
  let score = 0;
  if (base.movementPattern === candidate.movementPattern) score += 4;
  if (base.exerciseType === candidate.exerciseType) score += 1.5;
  if (base.difficulty === candidate.difficulty) score += 0.5;
  for (const muscle of base.targetMuscles) if (candidate.targetMuscles.includes(muscle)) score += 1.5;
  for (const bodyPart of base.bodyParts) if (candidate.bodyParts.includes(bodyPart)) score += 0.75;
  for (const equipment of base.equipments) if (candidate.equipments.includes(equipment)) score += 1.25;
  return score;
}

function chooseVariations(base, allExercises) {
  return allExercises
    .map((candidate) => ({ slug: candidate.slug, score: scoreVariation(base, candidate) }))
    .filter((item) => item.score > 0)
    .sort((a, b) => b.score - a.score || a.slug.localeCompare(b.slug))
    .slice(0, 4)
    .map((item) => item.slug);
}

async function normalizeExercise(exercise) {
  const translatedName = await translateText(exercise.name).catch(() => exercise.name);
  const slugFallback = await translateText(humanizeSlug(exercise.slug)).catch(() => humanizeSlug(exercise.slug));
  const normalizedName = chooseNormalizedName(translatedName, slugFallback, exercise);
  const movementPattern = inferMovementPattern(exercise);
  const exerciseType = inferExerciseType(exercise, movementPattern);
  const difficulty = inferDifficulty(exercise, movementPattern);
  const alias = buildAlias(exercise, normalizedName);
  const description = buildDescription(exercise, movementPattern, exerciseType);
  const confidence = computeConfidence(exercise, normalizedName, alias, movementPattern, exerciseType, difficulty, description);

  return {
    ...exercise,
    name: normalizedName,
    alias,
    exerciseType,
    description,
    confidence,
    difficulty,
    movementPattern,
  };
}

async function main() {
  const raw = fs.readFileSync(filePath, 'utf8');
  const exercises = JSON.parse(raw);
  if (!Array.isArray(exercises)) {
    throw new Error('exercises.json must contain an array');
  }

  const normalized = [];
  for (let i = 0; i < exercises.length; i++) {
    normalized.push(await normalizeExercise(exercises[i]));
    if ((i + 1) % 100 === 0 || i === exercises.length - 1) {
      console.log(`Normalized ${i + 1}/${exercises.length}`);
    }
  }

  for (const exercise of normalized) {
    exercise.variations = chooseVariations(exercise, normalized);
  }

  fs.writeFileSync(filePath, `${JSON.stringify(normalized, null, 2)}\n`, 'utf8');
  console.log('Exercises enriched successfully');
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
