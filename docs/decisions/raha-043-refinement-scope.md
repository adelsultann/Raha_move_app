# RAHA-043 — Alternative and Refined Recommendations Scope Decision

**Decision owner:** Adel (product-planner)
**Decision date:** 2026-08-31
**Status:** Approved for MVP implementation.

## Context

RAHA-043 lets a user reject a recommendation and receive an alternative. The
rejection vocabulary and how each reason refines the next recommendation were
not fully pinned across documents, and the loop must be provably terminating.

## Decisions

### 1. Rejection vocabulary uses five stable keys

| Key | Meaning | User label (en) |
|---|---|---|
| `too_easy` | The routine is too easy | Too easy |
| `too_difficult` | The routine is too difficult | Too difficult |
| `position` | The user cannot use the routine's position | I can't do this position |
| `discomfort` | The routine's area feels uncomfortable | This area feels uncomfortable |
| `other` | No specific feedback | Show me something else |

The analytics allowlist comment previously read `too_hard`; it is corrected to
`too_difficult` to match the product brief, `design-and-screens.md`, and
`database.md` ("too difficult"). The keys are stored language-neutral; labels
are localized in the ARB resources.

### 2. Constraint vs. preference refinement

- **Constraint (filtering):** `position` adds the rejected routine's position
  keys to an excluded-position set; `discomfort` adds its body-area keys to an
  excluded-area set. The engine excludes a candidate when *all* of its positions
  are excluded (position) or when *any* of its body areas is excluded
  (discomfort).
- **Preference (scoring):** `too_easy` raises and `too_difficult` lowers a
  difficulty override (clamped to `beginner`..`advanced`), which the engine uses
  instead of the experience-level-derived difficulty when scoring.
- **Neutral:** `other` only excludes the rejected routine.

The refinement is a versioned part of the engine request (`RecommendationRefinement`),
so the alternative sequence is deterministic and unit-tested, not widget-local.

### 3. Termination guarantee

Every rejection adds the current routine id to
`RecommendationRefinement.rejectedRoutineIds`, which grows monotonically. The
candidate set is finite, so the sequence reaches the empty state rather than
looping. The controller test rejects more times than there are candidates to
prove this.

### 4. "Edit the check-in" is a back-navigation affordance

When no alternative remains, the screen shows a calm explanation and an "Edit
your check-in" action that navigates back (to Today/Foundation, where a fresh
check-in can be started). A full in-place edit of a completed check-in is out of
scope and deferred to RAHA-060 (Today) / future check-in editing.

## Analytics

This task records the rejection in the persisted recommendation record
(`rejection_reason`, `rejected_at`, engine version, and the prior/new
recommendation ids share the check-in). It does **not** add the
`recommendation_rejected` analytics event, which remains part of the RAHA-015
event-catalog wiring alongside the recommendation funnel.

## Explicitly excluded

- Routine playback/session start (RAHA-050).
- Recommendation "shown"/"accepted"/"rejected" analytics events (RAHA-015).
- In-place editing of a completed check-in.
