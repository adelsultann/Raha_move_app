# RAHA-053 — Post-routine feedback scope

**Decision owner:** Adel (product-planner)
**Decision date:** 2026-09-01
**Status:** Approved for MVP implementation.

## User outcome

After a completed routine, a user can optionally give a four-value post-routine
feedback response that persists locally before synchronization, safely affects
future recommendations, and emits only privacy-safe analytics.

## Approved decisions

### 1. Feedback is optional

The completion UI clearly offers a localized **"Skip for now"** action. Skipping
does not save feedback, and the user can leave the flow immediately. Only an
explicit choice (`much_better`, `little_better`, `same`, `less_comfortable`)
creates a feedback record.

### 2. Safety-approved `less_comfortable` copy

Selecting `less_comfortable` shows calm, safety-approved copy with no medical
claims:

- EN: `Thanks for sharing that. Please stop for today and choose a comfortable option next time.`
- AR: `شكرًا لإخبارنا. توقّف لليوم واختر خيارًا مريحًا في المرة القادمة.`

The acknowledgment uses a restrained, non-celebratory visual state (muted
`self_improvement` icon and neutral surface colors; no celebration icon, points,
streaks, or rewards).

### 3. Completion summary shows verified active minutes only

Until RAHA-070, the completion summary shows the verified active minutes (the
credited active duration floored to whole minutes) only. It does **not** show
points, streaks, reward, or provisional reward state.

## Scope boundaries

### In scope (RAHA-053)

- Four language-neutral feedback values: `much_better`, `little_better`,
  `same`, `less_comfortable`.
- A single feedback response per completed session, saved locally (atomically
  with its sync outbox operation) before any synchronization. Persist-once is
  durable: the data boundary never overwrites an existing response, and a
  re-opened completion UI reads the stored answer and shows the acknowledgment
  without re-writing or re-emitting `feedback_submitted`.
- Re-using the existing `LocalSessionFeedback` table, `LocalUserDataRepository.saveFeedback`,
  and the `session_feedback` wire/sync plumbing — no new tables or migrations.
- `less_comfortable` shows the approved copy and a restrained visual state; the
  categorical response becomes a **routine-level prior-feedback signal** in
  recommendation history (see below).
- `feedback_submitted` analytics with only the allowlisted categorical
  `feedback_rating` plus stable `session_id`/`routine_id` (no locale, no free
  text, no identifiers), gated by `AnalyticsService` consent.
- Arabic RTL and English LTR, stable keys/semantics, 56 dp interactions, and
  200% text-scale/compact layout handling for the feedback flow.
- Loading/save-error/retry state that preserves the selected response.

### Recommendation input (`less_comfortable`)

A categorical `less_comfortable` response feeds future recommendations through
an aggregate, exercise-agnostic signal — no free text and no unapproved exercise
follow-up:

- `RecommendationHistory.lessComfortableRoutineIds` collects the routine behind
  each completed session whose feedback was `less_comfortable` (resolved through
  the session → routine link).
- The rules engine applies the existing, versioned `discomfort_penalty` to a
  candidate whose routine id is in that set, alongside the existing
  exercise-level `uncomfortable_exercise_ids` signal, and records the
  `less_comfortable_routine` reason code for an accurate, non-medical
  explanation ("You found this routine less comfortable before.").

This is deterministic and safety-aligned: the same history always deprioritizes
the same routine, and it never claims a diagnosis or identifies a specific
movement.

### Out of scope (owned by later tasks)

- The optional `uncomfortable_exercise_id` follow-up question. RAHA-053 stores
  only the categorical rating; the exercise-level discomfort penalty continues to
  read `uncomfortable_exercise_id`, which remains null until that follow-up is
  added. The routine-level signal above does not depend on it.
- Points, streaks, rewards, and provisional reward display (RAHA-070 / RAHA-072).

## Non-blocking risks

- The pre-existing `PlayerControls` "Finish" control overflows at 200% text scale
  on a compact screen (RAHA-051 scope). RAHA-053's feedback layout is scrollable
  and overflow-safe; the player-control overflow is tracked separately for
  RAHA-051/RAHA-080.
- Arabic active-minutes copy uses the CLDR plural form; reviewed wording may
  evolve when brand tone is finalized.
