CREATE TABLE training_plans (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT false,
  source TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tp_user ON training_plans(user_id);
CREATE INDEX idx_tp_active ON training_plans(user_id, is_active) WHERE is_active = true;

CREATE TABLE training_plan_schedule (
  plan_id TEXT NOT NULL REFERENCES training_plans(id) ON DELETE CASCADE,
  day_of_week TEXT NOT NULL,
  workout_template_id TEXT NOT NULL REFERENCES workout_templates(id) ON DELETE CASCADE,
  time TEXT,
  name TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  PRIMARY KEY (plan_id, day_of_week)
);

CREATE TABLE training_plan_sessions (
  id TEXT PRIMARY KEY,
  plan_id TEXT NOT NULL REFERENCES training_plans(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  started_at DATE NOT NULL,
  current_week INT NOT NULL DEFAULT 1,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tps_plan ON training_plan_sessions(plan_id);
CREATE INDEX idx_tps_user_active ON training_plan_sessions(user_id, status);

ALTER TABLE workout_sessions ADD COLUMN IF NOT EXISTS plan_session_id TEXT REFERENCES training_plan_sessions(id) ON DELETE CASCADE;
ALTER TABLE workout_sessions ADD COLUMN IF NOT EXISTS week_number INT DEFAULT 1;
ALTER TABLE workout_sessions ALTER COLUMN block_id DROP NOT NULL;
ALTER TABLE workout_sessions DROP CONSTRAINT IF EXISTS workout_sessions_block_id_fkey;
