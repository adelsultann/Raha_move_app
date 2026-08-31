# RAHA-040 — Daily Check-in Scope Decision

**Decision owner:** Adel (product-planner)
**Decision date:** 2026-08-30
**Status:** Approved for MVP implementation.

## Context

RAHA-040 builds the five-step daily check-in. Two document conflicts had to be
resolved before implementation, and the check-in persists into taxonomy
foreign-key columns that the bundled starter content did not fully seed.

## Decisions

### 1. Body-state vocabulary uses four values

The daily check-in's first question uses the four-value vocabulary already
authoritative in `database.md` and enforced by the Supabase `check_ins`
constraint:

```text
comfortable, stiff, tired, tense
```

`design-and-screens.md` lists five options by splitting stiffness into
"a little stiff" and "very stiff". That gradation is deferred: it would require
a backend migration to relax the `body_state` check constraint and adds little
MVP value. The four stable keys above are used in the UI, the local record, and
the wire payload.

**Review trigger:** Revisit when recommendation quality would benefit from a
stiffness-gradation signal, at which point a forward migration expands the
`body_state` constraint.

### 2. Check-in options are a fixed, product-defined MVP vocabulary

The option set is the closed product vocabulary from `design-and-screens.md`:

| Step | Stable keys |
|---|---|
| Body state | `comfortable`, `stiff`, `tired`, `tense` |
| Desired outcome (goal) | `ease_stiffness`, `move_more_freely`, `feel_energized`, `relax`, `desk_break` |
| Body areas (multi-select) | `neck`, `shoulders`, `upper_back`, `lower_back`, `hips`, `knees`, `full_body` |
| Available time | `3`, `5`, `10`, `15` minutes |
| Position | `seated`, `standing`, `floor`, or `any` (persisted as `null`) |

These keys are stable and language-neutral; their labels are localized in the
application ARB resources (same approach as RAHA-032's preferred positions).
The same keys are what RAHA-041's recommendation engine will match against
routine taxonomy assignments, so the check-in vocabulary is deliberately not
driven by whatever content happens to be cached on-device.

### 3. The full check-in taxonomy is seeded in the bundled starter content

`check_ins.goal_key`, `check_ins.position_key`, and
`check_in_body_areas.body_area_key` are foreign keys to `local_taxonomies.key`.
The bundled starter catalog previously seeded only `neck`, `shoulders`,
`ease_stiffness`, and `seated`, so a check-in referencing `standing`, `hips`,
`move_more_freely`, etc. would fail the foreign key (the same layering issue
documented in RAHA-032 for positions).

The bundled starter manifest is therefore expanded to seed the full MVP goal,
body-area, and position vocabulary (with Arabic and English labels), and its
canonical manifest checksum is recomputed. This is the content-release-owned
home for taxonomy and is required by RAHA-041 regardless of this task.

### 4. Body state and time are not taxonomy

Body state is stored as the free `body_state` text column and time is the
`available_minutes` integer; neither is a taxonomy foreign key. They are fixed
domain enums with the stable values above.

### 5. Entry point is temporary

There is no Today screen yet (RAHA-060). The check-in is exposed through a typed
`CheckInRoute` and a temporary "start today's check-in" action on the placeholder
`FoundationRoute`. RAHA-060 replaces that affordance with the real Today screen.

## Analytics

Completing a check-in records `check_in_completed` with only scalar, categorical
properties: `body_state`, `goal_key`, `available_minutes`, `position_key`
(`any` when null), and `body_area_count`. The selected body-area keys themselves
are not sent to analytics; they live in the synced check-in record
(`check_in_body_areas`) and are analyzed server-side. No free text, names, or
identifiers are collected.

## Explicitly excluded

- Recommendations, alternatives, and the recommendation explanation (RAHA-041,
  RAHA-042, RAHA-043).
- Routine playback and session recording (RAHA-050–RAHA-052).
- The Today screen and responsive shell (RAHA-060, RAHA-012 shell work).
- Backend schema changes: this task does not alter any shared migration.
