import { Pool } from 'pg';

const SYSTEM_PRESETS = [
  {
    id: 'preset-gym-full',
    name: 'Тренажёрный зал (полный)',
    slug: 'gym-full',
    keywords: [
      'barbell', 'dumbbell', 'cable', 'kettlebell', 'smith machine',
      'bench', 'ez barbell', 'olympic barbell', 'resistance band',
      'stability ball', 'medicine ball', 'trap bar',
      'leverage machine', 'sled machine', 'hammer',
      'rope', 'band', 'weighted', 'roller', 'wheel roller',
      'bosu ball', 'stationary bike', 'elliptical machine',
      'skierg machine', 'stepmill machine', 'upper body ergometer',
    ],
  },
  {
    id: 'preset-gym-basic',
    name: 'Тренажёрный зал (базовый)',
    slug: 'gym-basic',
    keywords: [
      'barbell', 'dumbbell', 'cable', 'bench', 'ez barbell',
      'pull-up bar', 'resistance band',
    ],
  },
  {
    id: 'preset-home',
    name: 'Домашняя тренировка',
    slug: 'home',
    keywords: [
      'dumbbell', 'kettlebell', 'resistance band', 'stability ball',
      'band', 'weighted', 'roller',
    ],
  },
  {
    id: 'preset-bodyweight',
    name: 'Только вес тела',
    slug: 'bodyweight-only',
    keywords: [] as string[],
  },
  {
    id: 'preset-outdoor',
    name: 'Уличная площадка',
    slug: 'outdoor',
    keywords: [
      'bar', 'resistance band', 'rope', 'band',
    ],
  },
];

async function seed() {
  const pool = new Pool({
    connectionString:
      process.env.DATABASE_URL ??
      'postgresql://postgres:postgres@localhost:5432/fitness_app',
  });

  try {
    const { rows } = await pool.query('SELECT slug FROM equipments');
    const existingSlugs = new Set(rows.map((r: { slug: string }) => r.slug));

    for (const preset of SYSTEM_PRESETS) {
      const matchedSlugs = preset.keywords.filter((k) => existingSlugs.has(k));

      await pool.query(
        `INSERT INTO equipment_presets (id, user_id, name, slug, is_system, equipment_slugs)
         VALUES ($1, NULL, $2, $3, true, $4)
         ON CONFLICT (id) DO UPDATE SET name = $2, equipment_slugs = $4, updated_at = NOW()`,
        [preset.id, preset.name, preset.slug, matchedSlugs],
      );

      console.log(
        `Preset "${preset.name}": ${matchedSlugs.length} equipment matched`,
      );
    }

    console.log('Equipment presets seeded successfully.');
  } catch (err) {
    console.error('Seed failed:', err);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

seed();
