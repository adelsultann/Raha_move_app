# RAHA-032 — Basic Preferences Scope Decision

**Decision owner:** Adel (product-planner)
**Decision date:** 2026-08-30
**Status:** Approved for MVP implementation.

## Context

RAHA-032 requires capturing and persisting the basic preferences that
"immediately affect the experience": movement experience, permitted/preferred
positions, weekly goal, reminder interest, and optional movement constraints
"approved for the MVP". The acceptance criteria had no recorded approval for
what the MVP movement constraints are, and the local Drift schema models only
position constraints via `local_preferred_positions`.

## Decisions

### 1. Movement constraints = permitted positions only

The only movement constraint captured at setup is **permitted/preferred
positions** (`seated`, `standing`, `floor`). No body-area sensitivity flags and
no per-exercise avoidance are captured at setup in the MVP. Those concerns
already surface through the daily check-in (which body areas) and post-routine
feedback ("area feels uncomfortable"), and are the recommendation engine's
future refinement inputs (RAHA-043).

Rationale: keeps the setup minimal, non-medical, and consistent with the local
schema. It also avoids asking a beginner to self-diagnose a sensitivity during
onboarding.

### 2. Reminder interest = boolean opt-in

"Reminder interest" is stored as a boolean `reminder_interest` on
`local_user_preferences`. The full reminder schedule (time, days of week) is
out of scope and owned by RAHA-065. At setup the user only expresses interest.

### 3. Preferred positions persist as a stable key list on the preferences row

Preferred positions are a small, closed, product-defined vocabulary
(`seated`, `standing`, `floor`) with stable language-neutral keys. They are
persisted as `preferred_positions_json` (a JSON list of stable keys, empty list
means "any position") on `local_user_preferences`, **not** through the
FK-constrained `local_preferred_positions` table.

Rationale:

- `local_preferred_positions.position_key` is a foreign key to
  `local_taxonomies.key`. At first-run setup the bundled starter content seeds
  only the `seated` position taxonomy key, so writing `standing`/`floor` through
  that table would fail the foreign key, or would require the preferences
  feature to seed content taxonomy (a layering violation).
- The position vocabulary is a product constant, not content-provided data, so
  it is safe to own it in the preferences domain.
- `local_preferred_positions` remains forward-looking; a later content/taxonomy
  task can reconcile to the normalized table once the full position vocabulary
  ships in content releases.

### 4. Preference synchronization is deferred

Saving preferences is local-first and atomic (one Drift transaction), consistent
with the existing RAHA-025 note that preferences have no wire contract yet. They
are available offline immediately and will synchronize later when the
preference push/pull shape is defined. `sync_state` is set to `pendingUpdate` so
future sync work can discover unsynced preference rows.

## Required vs optional fields

- **Experience level**: required; the capture UI starts unselected and does not
  allow continuing until one of `beginner`/`intermediate`/`advanced` is chosen.
- **Weekly goal**: a bounded value 1–7 movement days with a gentle default of 3.
- **Preferred positions**: optional; empty selection means "any position".
- **Reminder interest**: optional; defaults to "not now".

## Explicitly excluded

Height, weight, age, diagnosis, and unrelated profile data are not captured or
stored by this task.

## Review trigger

Revisit when the recommendation engine (RAHA-041) consumes preferences, or when
the preference push/pull wire contract is defined, or when the full position
vocabulary ships in content releases (which would allow a normalized
`local_preferred_positions` representation).
