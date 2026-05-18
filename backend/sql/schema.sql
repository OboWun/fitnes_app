DROP FUNCTION IF EXISTS find_exercise_full_by_slug(TEXT) CASCADE;
DROP FUNCTION IF EXISTS find_exercises_with_relations(TEXT[], TEXT[], TEXT[], TEXT, INT, INT) CASCADE;

DROP TABLE IF EXISTS exercise_contraindications CASCADE;
DROP TABLE IF EXISTS exercise_equipments CASCADE;
DROP TABLE IF EXISTS exercise_body_parts CASCADE;
DROP TABLE IF EXISTS exercise_secondary_muscles CASCADE;
DROP TABLE IF EXISTS exercise_target_muscles CASCADE;
DROP TABLE IF EXISTS exercises CASCADE;
DROP TABLE IF EXISTS muscle_antagonists CASCADE;
DROP TABLE IF EXISTS muscles CASCADE;
DROP TABLE IF EXISTS bodyparts CASCADE;
DROP TABLE IF EXISTS equipments CASCADE;
DROP TABLE IF EXISTS contraindications CASCADE;
DROP TABLE IF EXISTS user_contraindications CASCADE;
DROP TABLE IF EXISTS workout_exercises CASCADE;
DROP TABLE IF EXISTS scheduled_workouts CASCADE;
DROP TABLE IF EXISTS workout_templates CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE bodyparts (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL
);

CREATE TABLE equipments (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL
);

CREATE TABLE muscles (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL
);

CREATE TABLE contraindications (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL
);

CREATE TABLE muscle_antagonists (
  muscle_id INT NOT NULL REFERENCES muscles(id) ON DELETE CASCADE,
  antagonist_id INT NOT NULL REFERENCES muscles(id) ON DELETE CASCADE,
  PRIMARY KEY (muscle_id, antagonist_id)
);

CREATE TABLE exercises (
  id SERIAL PRIMARY KEY,
  exercise_id TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  gif_url TEXT NOT NULL,
  instructions TEXT[] NOT NULL DEFAULT '{}',
  alias TEXT[] DEFAULT '{}',
  exercise_type TEXT,
  description TEXT,
  confidence NUMERIC(3,2),
  difficulty TEXT,
  movement_pattern TEXT,
  variations TEXT[] DEFAULT '{}',
  metadata JSONB DEFAULT '{}'
);

CREATE TABLE exercise_target_muscles (
  exercise_id INT NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  muscle_id INT NOT NULL REFERENCES muscles(id),
  PRIMARY KEY (exercise_id, muscle_id)
);

CREATE TABLE exercise_secondary_muscles (
  exercise_id INT NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  muscle_id INT NOT NULL REFERENCES muscles(id),
  PRIMARY KEY (exercise_id, muscle_id)
);

CREATE TABLE exercise_body_parts (
  exercise_id INT NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  bodypart_id INT NOT NULL REFERENCES bodyparts(id),
  PRIMARY KEY (exercise_id, bodypart_id)
);

CREATE TABLE exercise_equipments (
  exercise_id INT NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  equipment_id INT NOT NULL REFERENCES equipments(id),
  PRIMARY KEY (exercise_id, equipment_id)
);

CREATE TABLE exercise_contraindications (
  exercise_id INT NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  contraindication_id INT NOT NULL REFERENCES contraindications(id),
  severity TEXT NOT NULL CHECK (severity IN ('forbidden', 'not_recommended', 'low_weight')),
  PRIMARY KEY (exercise_id, contraindication_id)
);

CREATE INDEX idx_etm_muscle ON exercise_target_muscles(muscle_id);
CREATE INDEX idx_esm_muscle ON exercise_secondary_muscles(muscle_id);
CREATE INDEX idx_ebp_bodypart ON exercise_body_parts(bodypart_id);
CREATE INDEX idx_ee_equipment ON exercise_equipments(equipment_id);
CREATE INDEX idx_ec_contraindication ON exercise_contraindications(contraindication_id);
CREATE INDEX idx_exercises_name ON exercises USING gin (name gin_trgm_ops);
CREATE INDEX idx_exercises_type ON exercises(exercise_type);
CREATE INDEX idx_exercises_difficulty ON exercises(difficulty);
CREATE INDEX idx_exercises_movement ON exercises(movement_pattern);

CREATE TABLE users (
  id TEXT PRIMARY KEY,
  device_id TEXT UNIQUE NOT NULL,
  name TEXT,
  weight NUMERIC(5,1) CHECK (weight BETWEEN 20 AND 300),
  height NUMERIC(5,1) CHECK (height BETWEEN 50 AND 300),
  age INT CHECK (age BETWEEN 10 AND 120),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'
);

-- migration: add metadata to exercises and users
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}';
ALTER TABLE users ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}';

CREATE TABLE user_contraindications (
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  contraindication_id INT NOT NULL REFERENCES contraindications(id),
  PRIMARY KEY (user_id, contraindication_id)
);

CREATE TABLE workout_templates (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE workout_exercises (
  id SERIAL PRIMARY KEY,
  template_id TEXT NOT NULL REFERENCES workout_templates(id) ON DELETE CASCADE,
  exercise_slug TEXT NOT NULL,
  sets INT NOT NULL,
  reps INT,
  rest_between_sets INT,
  rest_after_exercise INT,
  sort_order INT NOT NULL
);

CREATE TABLE scheduled_workouts (
  id TEXT PRIMARY KEY,
  template_id TEXT NOT NULL REFERENCES workout_templates(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  day_of_week TEXT NOT NULL,
  time TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_we_template ON workout_exercises(template_id);
CREATE INDEX idx_sw_user ON scheduled_workouts(user_id);
CREATE INDEX idx_sw_template ON scheduled_workouts(template_id);

CREATE TABLE training_blocks (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  index INTEGER NOT NULL,
  duration_weeks INTEGER NOT NULL DEFAULT 1,
  goal TEXT,
  target_muscles TEXT[],
  metadata JSONB DEFAULT '{}'
);

CREATE TABLE workout_sessions (
  id TEXT PRIMARY KEY,
  block_id TEXT NOT NULL REFERENCES training_blocks(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  day_of_week TEXT NOT NULL,
  time TEXT,
  status TEXT DEFAULT 'planned',
  metadata JSONB DEFAULT '{}'
);

CREATE TABLE workout_session_exercises (
  session_id TEXT NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_slug TEXT NOT NULL,
  sets INTEGER NOT NULL,
  ordering INTEGER NOT NULL,
  metadata JSONB DEFAULT '{}',
  PRIMARY KEY (session_id, exercise_slug)
);

CREATE INDEX idx_tb_user ON training_blocks(user_id);
CREATE INDEX idx_ws_block ON workout_sessions(block_id);
CREATE INDEX idx_ws_user ON workout_sessions(user_id);
CREATE INDEX idx_wse_session ON workout_session_exercises(session_id);

ALTER TABLE equipments ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE equipments ADD COLUMN IF NOT EXISTS image_url TEXT;

CREATE TABLE weight_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(50) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  weight NUMERIC(5,2) NOT NULL CHECK (weight > 0 AND weight < 500),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_weight_logs_user_created ON weight_logs(user_id, created_at DESC);

-- migration: add metadata to workout_templates
ALTER TABLE workout_templates ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}';

CREATE OR REPLACE FUNCTION find_exercise_full_by_slug(p_slug TEXT)
RETURNS JSONB AS $$
SELECT jsonb_build_object(
  'exerciseId', e.exercise_id,
  'name', e.name,
  'slug', e.slug,
  'gifUrl', e.gif_url,
  'instructions', e.instructions,
  'alias', e.alias,
  'exerciseType', e.exercise_type,
  'description', e.description,
  'confidence', e.confidence,
  'difficulty', e.difficulty,
  'movementPattern', e.movement_pattern,
  'variations', e.variations,
  'targetMuscles', (
    SELECT coalesce(json_agg(json_build_object('name', m.name, 'slug', m.slug)), '[]'::json)
    FROM exercise_target_muscles etm JOIN muscles m ON m.id = etm.muscle_id
    WHERE etm.exercise_id = e.id
  ),
  'secondaryMuscles', (
    SELECT coalesce(json_agg(json_build_object('name', m.name, 'slug', m.slug)), '[]'::json)
    FROM exercise_secondary_muscles esm JOIN muscles m ON m.id = esm.muscle_id
    WHERE esm.exercise_id = e.id
  ),
  'bodyParts', (
    SELECT coalesce(json_agg(json_build_object('name', bp.name, 'slug', bp.slug)), '[]'::json)
    FROM exercise_body_parts ebp JOIN bodyparts bp ON bp.id = ebp.bodypart_id
    WHERE ebp.exercise_id = e.id
  ),
  'equipments', (
    SELECT coalesce(json_agg(json_build_object('name', eq.name, 'slug', eq.slug)), '[]'::json)
    FROM exercise_equipments ee JOIN equipments eq ON eq.id = ee.equipment_id
    WHERE ee.exercise_id = e.id
  ),
  'contraindications', (
    SELECT coalesce(json_agg(json_build_object('slug', c.slug, 'severity', ec.severity)), '[]'::json)
    FROM exercise_contraindications ec JOIN contraindications c ON c.id = ec.contraindication_id
    WHERE ec.exercise_id = e.id
  )
)
FROM exercises e
WHERE e.slug = p_slug;
$$ LANGUAGE sql STABLE;
