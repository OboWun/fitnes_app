import { Pool } from 'pg';
import * as fs from 'fs';
import * as path from 'path';

async function seed() {
  const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
  });

  const dataDir = path.join(__dirname, '..', 'data');

  try {
    const schemaSql = fs.readFileSync(
      path.join(__dirname, '..', 'sql', 'schema.sql'),
      'utf-8',
    );
    await pool.query(schemaSql);
    console.log('Schema applied.');

    const muscles = JSON.parse(
      fs.readFileSync(path.join(dataDir, 'muscles.json'), 'utf-8'),
    );
    for (const m of muscles) {
      await pool.query(
        'INSERT INTO muscles (name, slug) VALUES ($1, $2) ON CONFLICT (slug) DO NOTHING',
        [m.name, m.slug],
      );
    }
    console.log(`Muscles: ${muscles.length} inserted.`);

    for (const m of muscles) {
      if (m.antagonists?.length) {
        for (const antSlug of m.antagonists) {
          await pool.query(
            `INSERT INTO muscle_antagonists (muscle_id, antagonist_id)
             SELECT m1.id, m2.id FROM muscles m1, muscles m2
             WHERE m1.slug = $1 AND m2.slug = $2
             ON CONFLICT DO NOTHING`,
            [m.slug, antSlug],
          );
        }
      }
    }
    console.log('Muscle antagonists inserted.');

    const bodyparts = JSON.parse(
      fs.readFileSync(path.join(dataDir, 'bodyparts.json'), 'utf-8'),
    );
    for (const bp of bodyparts) {
      await pool.query(
        'INSERT INTO bodyparts (name, slug) VALUES ($1, $2) ON CONFLICT (slug) DO NOTHING',
        [bp.name, bp.slug],
      );
    }
    console.log(`Bodyparts: ${bodyparts.length} inserted.`);

    const equipments = JSON.parse(
      fs.readFileSync(path.join(dataDir, 'equipments.json'), 'utf-8'),
    );
    for (const eq of equipments) {
      await pool.query(
        'INSERT INTO equipments (name, slug) VALUES ($1, $2) ON CONFLICT (slug) DO NOTHING',
        [eq.name, eq.slug],
      );
    }
    console.log(`Equipments: ${equipments.length} inserted.`);

    const contraindications = JSON.parse(
      fs.readFileSync(path.join(dataDir, 'contraindications.json'), 'utf-8'),
    );
    for (const c of contraindications) {
      await pool.query(
        'INSERT INTO contraindications (name, slug) VALUES ($1, $2) ON CONFLICT (slug) DO NOTHING',
        [c.name, c.slug],
      );
    }
    console.log(`Contraindications: ${contraindications.length} inserted.`);

    const exercises = JSON.parse(
      fs.readFileSync(path.join(dataDir, 'exercises.json'), 'utf-8'),
    );
    console.log(`Processing ${exercises.length} exercises...`);

    const batchSize = 100;
    for (let i = 0; i < exercises.length; i += batchSize) {
      const batch = exercises.slice(i, i + batchSize);
      const client = await pool.connect();
      try {
        await client.query('BEGIN');

        for (const ex of batch) {
          const gifUrl = ex.gifUrl?.replace('backend/media/', '/media/') || '';
          const exResult = await client.query(
            `INSERT INTO exercises (exercise_id, name, slug, gif_url, instructions, alias, exercise_type, description, confidence, difficulty, movement_pattern, variations)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
             ON CONFLICT (slug) DO NOTHING
             RETURNING id`,
            [
              ex.exerciseId,
              ex.name,
              ex.slug,
              gifUrl,
              ex.instructions || [],
              ex.alias || [],
              ex.exerciseType || null,
              ex.description || null,
              ex.confidence || null,
              ex.difficulty || null,
              ex.movementPattern || null,
              ex.variations || [],
            ],
          );

          if (exResult.rows.length === 0) continue;
          const exId = exResult.rows[0].id;

          if (ex.targetMuscles?.length) {
            const values = ex.targetMuscles
              .map(
                () =>
                  `(${exId}, (SELECT id FROM muscles WHERE slug = $1))`,
              )
              .join(',');
            const slugs = ex.targetMuscles;
            for (const slug of slugs) {
              await client.query(
                `INSERT INTO exercise_target_muscles (exercise_id, muscle_id)
                 SELECT $1, id FROM muscles WHERE slug = $2
                 ON CONFLICT DO NOTHING`,
                [exId, slug],
              );
            }
          }

          if (ex.secondaryMuscles?.length) {
            for (const slug of ex.secondaryMuscles) {
              await client.query(
                `INSERT INTO exercise_secondary_muscles (exercise_id, muscle_id)
                 SELECT $1, id FROM muscles WHERE slug = $2
                 ON CONFLICT DO NOTHING`,
                [exId, slug],
              );
            }
          }

          if (ex.bodyParts?.length) {
            for (const slug of ex.bodyParts) {
              await client.query(
                `INSERT INTO exercise_body_parts (exercise_id, bodypart_id)
                 SELECT $1, id FROM bodyparts WHERE slug = $2
                 ON CONFLICT DO NOTHING`,
                [exId, slug],
              );
            }
          }

          if (ex.equipments?.length) {
            for (const slug of ex.equipments) {
              await client.query(
                `INSERT INTO exercise_equipments (exercise_id, equipment_id)
                 SELECT $1, id FROM equipments WHERE slug = $2
                 ON CONFLICT DO NOTHING`,
                [exId, slug],
              );
            }
          }

          if (ex.contraindications?.length) {
            for (const c of ex.contraindications) {
              await client.query(
                `INSERT INTO exercise_contraindications (exercise_id, contraindication_id, severity)
                 SELECT $1, id, $3 FROM contraindications WHERE slug = $2
                 ON CONFLICT DO NOTHING`,
                [exId, c.slug, c.severity],
              );
            }
          }
        }

        await client.query('COMMIT');
        console.log(
          `  Batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(exercises.length / batchSize)} done.`,
        );
      } catch (err) {
        await client.query('ROLLBACK');
        throw err;
      } finally {
        client.release();
      }
    }

    console.log(`Exercises: ${exercises.length} processed.`);
    console.log('Seed completed successfully.');
  } catch (err) {
    console.error('Seed failed:', err);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

seed();
