# CONTEXT: MILP Workout Planning

## Purpose
Document the current state of Workout MILP debugging, the observed failure modes, and the most likely fixes.

## Current Symptom
- Workout generation often returns the same small set of accessory exercises.
- In target sessions, chest/back are underrepresented or missing.
- Generated plans can fill time poorly and ignore the intended training focus.

## What Is Already Implemented
- `Exercise.metadata` and `User.metadata` exist.
- MILP services are present for single workout and weekly plan generation.
- Exercise metadata was backfilled in the DB.
- A solver fallback path exists when the LP solution is incomplete.

## Observed Problems
1. `mandatoryMuscles` are not strong enough to guarantee real coverage.
2. The objective favors safe, short, low-risk exercises over target muscles.
3. Diversity is too coarse and does not penalize repeated patterns enough.
4. Fallback can still produce a weak, non-targeted result.
5. Metadata quality influences the optimizer too much when target muscles are poorly represented.
6. A fixed bonus for `chest`/`back` would be wrong for lower-body, cardio, or mobility sessions.

## Likely Root Causes
1. Coverage is treated as a constraint, but not as a strong optimization signal.
2. Anti-repetition is binary instead of contextual.
3. The candidate pool is not session-aware enough.
4. Accessory/stretching exercises are too competitive in the default score space.
5. Some exercises have metadata that makes them look useful across too many contexts.

## Reference Notes From `hybrid_model.ipynb`
1. The notebook uses a hybrid approach:
   - data-driven weights
   - fatigue and recovery dynamics
   - structural constraints
2. It does not hardcode a permanent bonus for one muscle pair.
3. It relies on session structure and context.
4. Better general solution: reward coverage only inside the current target session type.

## Recommended Direction
1. Make the session type explicit.
   - Examples: `push`, `pull`, `lower`, `upper`, `full_body`, `cardio`, `mobility`.
2. Derive target muscles from session type.
   - Chest/back are important only in relevant upper-body sessions.
3. Add a positive objective bonus for required coverage.
4. Keep `mandatoryMuscles` as hard constraints, but add a soft bonus so the solver prefers them earlier.
5. Strengthen diversity with recency and pattern distance, not just a binary used/not-used flag.
6. Reduce accessory dominance by lowering their effective score in strength sessions.
7. Keep soft fallback, but mark partial solutions explicitly.

## Validation Criteria
1. Given a chest/back session, chest and back appear in the result.
2. Lower-body or cardio sessions do not get pulled toward chest/back bonuses.
3. Stretching and mobility no longer dominate strength-oriented outputs.
4. The solver path and fallback path are distinguishable.
5. The total plan uses most of the available time when feasible.

## Notes
- Do not use a universal chest/back bonus.
- Prefer contextual scoring based on the current workout goal.
- Keep the document updated as the implementation changes.
