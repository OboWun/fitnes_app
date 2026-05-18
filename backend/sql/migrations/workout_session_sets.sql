CREATE TABLE workout_session_sets (
  session_id          TEXT NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_slug       TEXT NOT NULL,
  set_number          INT NOT NULL,
  set_type            TEXT NOT NULL DEFAULT 'working',

  planned_weight_kg   NUMERIC(6,2),
  planned_reps        INT,
  planned_duration_sec INT,
  planned_distance_m  NUMERIC(8,1),

  actual_weight_kg    NUMERIC(6,2),
  actual_reps         INT,
  actual_duration_sec INT,
  actual_distance_m   NUMERIC(8,1),
  actual_rpe          NUMERIC(3,1),

  completed_at        TIMESTAMPTZ,

  PRIMARY KEY (session_id, exercise_slug, set_number)
);

CREATE INDEX idx_wss_session ON workout_session_sets(session_id);
CREATE INDEX idx_wss_exercise ON workout_session_sets(exercise_slug);
