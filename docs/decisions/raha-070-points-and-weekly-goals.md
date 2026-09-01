# RAHA-070 — Points and weekly goals policy

**Decision owner:** Adel (product-planner)  
**Decision date:** 2026-09-01  
**Status:** Approved for MVP implementation.

## User outcome

After completing a suitable routine, a user sees calm recognition of their
participation and can track a weekly movement-day goal without being encouraged

## Approved decisions

### 1. Points rule: `points_completion_v1`

- The trusted server awards **10 points** for each qualifying completed routine
  session.
- A session qualifies only when it is `completed` under the versioned RAHA-001
  completion policy. Abandoned and in-progress sessions receive no points.
- The award source is the completed `session_id`. The append-only point ledger
  enforces one award for that source, including after duplicate finalization
  requests or offline synchronization retries.
- Every ledger award records the rule version `points_completion_v1` so a later
  policy does not change the historical meaning of an award.
- Points have no cash value, entitlement, subscription, or purchase effect in
  the MVP.

Points are not increased for duration, intensity, range of motion, feedback
rating, streak length, referrals, or completing a routine despite discomfort.
There are no multipliers, daily caps, leaderboards, or competitive comparisons
in the MVP.

### 2. Weekly movement goal: `movement_day_v1`

- A user selects a goal from **1 through 7 movement days**; the initial default
  is **3 movement days**.
- A movement day is a local calendar day containing at least one qualifying
  completed routine session. Multiple qualifying sessions on that day advance
  the weekly goal once.
- Weeks run Monday through Sunday in the user's stored IANA timezone. The
  timezone associated with the completed session preserves historical day
  boundaries if the user later changes timezone.
- Extra qualifying routines on the same movement day each receive their normal
  10-point award, but do not increase that week's movement-day count again.

### 3. Offline projection and reconciliation

- The client immediately projects a qualifying local completion into the weekly
  movement-day total while offline.
- It may show the corresponding `10 points pending confirmation` state, but
  must not present that projection as authoritative or add it again after sync.
- After synchronization, the server-owned point ledger and weekly-progress
  projection replace local estimates by source/session identity. Server results
  are authoritative.

### 4. Analytics and user-facing tone

- The application records `points_awarded` only after a server-confirmed award,
  subject to analytics consent.
- Its allowlisted properties are `rule_version`, `point_amount`, and
  `source_type`; it contains no body-state answers, feedback, free text, or
  direct identifiers.
- Arabic and English UI copy must describe points as gentle recognition of
  completed movement, not health, diagnosis, fitness rank, or a reason to
  ignore discomfort.

## Implementation boundaries

- Point creation is trusted-server-only. Mobile clients may read authoritative
  ledger/progress projections and create only their local projections.
- The server validates the final session against its routine-bound completion
  policy before creating a point award.
- RAHA-071 owns streak and recovery rules; RAHA-072 owns achievements and the
  combined reward summary.

## Review trigger

Review after a meaningful beta sample, or earlier if points appear to encourage
repeated short-session farming, pressure users into unwanted activity, or make
