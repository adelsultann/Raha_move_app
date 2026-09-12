# RAHA-071 — Streaks and recovery policy

**Decision owner:** Adel (product-planner)  
**Decision date:** 2026-09-11  
**Status:** Approved for MVP implementation.

## User outcome

Users can notice a steady movement habit without pressure. A missed day is met
with a neutral invitation to return when it feels right.

## Approved rule: `streak_v1`

- A qualifying movement day contains at least one server-accepted routine
  session completed under the versioned RAHA-001 completion policy.
- The server determines completion time. Each session's validated IANA timezone
  snapshot determines its historical movement date, so later travel, timezone
  changes, and device-clock changes cannot rewrite or award a streak.
- One qualifying day starts a one-day streak. A qualifying day immediately after
  the latest qualifying day extends it. Multiple routines on one day count once.
- When the latest qualifying day is older than yesterday in the user's current
  stored timezone, the current streak is zero until another qualifying day. The
  longest historical streak remains visible in the server projection.
- Recovery tokens, recovery days, and streak protection are **not included in
  the MVP**. No client or server state is created for them.
- The server-derived streak projection overrides the local estimate after sync.
  Local estimates are never milestones or rewards, so delayed sync cannot
  duplicate a celebration.

## User-facing language

- English: “{days}-day movement streak” / “Every movement day counts. Start
  again whenever it feels right.”
- Arabic: “سلسلة حركة لمدة {days} أيام” / “كل يوم حركة له قيمة. ابدأ من جديد
  عندما يناسبك ذلك.”

This language describes participation, never failure, health, diagnosis, or a
reason to ignore discomfort.

## Migration and review trigger

Historical server-accepted sessions are recalculated under `streak_v1`; their
session timezone snapshots preserve their original dates. A future rule must
use a new immutable version and retain the historical projection meaning.

Review after a meaningful beta sample, or earlier if streak copy appears to
create pressure or users need a different rest-friendly behavior.
