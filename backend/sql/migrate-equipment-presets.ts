import { Pool } from 'pg';

async function migrate() {
  const pool = new Pool({
    connectionString:
      process.env.DATABASE_URL ??
      'postgresql://postgres:postgres@localhost:5432/fitness_app',
  });

  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS equipment_presets (
        id TEXT PRIMARY KEY,
        user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        slug TEXT NOT NULL,
        is_system BOOLEAN NOT NULL DEFAULT false,
        equipment_slugs TEXT[] NOT NULL DEFAULT '{}',
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        UNIQUE(user_id, slug)
      )
    `);
    console.log('Table equipment_presets created.');

    await pool.query(
      'CREATE INDEX IF NOT EXISTS idx_ep_user ON equipment_presets(user_id)',
    );
    await pool.query(
      'CREATE INDEX IF NOT EXISTS idx_ep_system ON equipment_presets(is_system) WHERE is_system = true',
    );

    const { rows } = await pool.query('SELECT slug FROM equipments');
    const existingSlugs = new Set(rows.map((r: { slug: string }) => r.slug));

    const SYSTEM_PRESETS = [
      {
        id: 'preset-gym-full',
        name: 'Тренажёрный зал (полный)',
        slug: 'gym-full',
        keywords: [
          'barbell',
          'dumbbell',
          'cable',
          'kettlebell',
          'smith machine',
          'ez barbell',
          'olympic barbell',
          'resistance band',
          'stability ball',
          'medicine ball',
          'trap bar',
          'leverage machine',
          'sled machine',
          'hammer',
          'rope',
          'band',
          'weighted',
          'roller',
          'wheel roller',
          'bosu ball',
          'stationary bike',
          'elliptical machine',
          'skierg machine',
          'stepmill machine',
          'upper body ergometer',
        ],
      },
      {
        id: 'preset-gym-basic',
        name: 'Тренажёрный зал (базовый)',
        slug: 'gym-basic',
        keywords: [
          'barbell',
          'dumbbell',
          'cable',
          'ez barbell',
          'olympic barbell',
          'resistance band',
        ],
      },
      {
        id: 'preset-home',
        name: 'Домашняя тренировка',
        slug: 'home',
        keywords: [
          'dumbbell',
          'kettlebell',
          'resistance band',
          'stability ball',
          'band',
          'weighted',
          'roller',
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
        keywords: ['resistance band', 'rope', 'band'],
      },
    ];

    for (const preset of SYSTEM_PRESETS) {
      const matchedSlugs = preset.keywords.filter((k) =>
        existingSlugs.has(k),
      );

      await pool.query(
        `INSERT INTO equipment_presets (id, user_id, name, slug, is_system, equipment_slugs)
         VALUES ($1, NULL, $2, $3, true, $4)
         ON CONFLICT (id) DO UPDATE SET name = $2, equipment_slugs = $4, updated_at = NOW()`,
        [preset.id, preset.name, preset.slug, matchedSlugs],
      );

      console.log(
        `  Preset "${preset.name}": ${matchedSlugs.length} equipment matched -> [${matchedSlugs.join(', ')}]`,
      );
    }

    console.log('Equipment presets seeded successfully.');
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

migrate();
