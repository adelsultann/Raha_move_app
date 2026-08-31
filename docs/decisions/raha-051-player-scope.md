# RAHA-051 — Focused routine player scope

**Decision owner:** Adel (product-planner)
**Decision date:** 2026-08-31
**Status:** Approved for MVP implementation. The video-renderer binding remains a
fast-follow once real, playable media is delivered (RAHA-052 media readiness and
RAHA-082 production media).

## User outcome

A user who has accepted a recommended routine can follow a focused, distraction-free
player that loops the movement demonstration, shows where they are in the routine,
keeps time honestly (only active playback time counts), and lets them pause, resume,
skip, go back, and finish — without pressure, ads, streaks, or unrelated navigation.

## Scope boundaries

### In scope (RAHA-051)

- The full-screen routine player route and screen (no bottom navigation, ads,
  streak pressure, or unrelated actions).
- A deterministic player controller owning the playback session state machine:
  current step, per-step terminal state (`pending`/`completed`/`partial`/`skipped`),
  credited active seconds (capped at each step's target duration), pause/resume,
  previous/next/skip, and completion.
- Large per-step timer (MVP steps are timed only; repetition-count display is
  deferred until a repetition-credit policy exists).
- Localized movement name, routine position indicator ("Movement 2 of 6"),
  optional short cue, and the next movement name.
- A looping demonstration area behind a Raha-owned interface. Pause freezes it;
  resume continues from the saved state.
- Preload of the next playable media asset while the current step is active.
- Backgrounding pauses the routine; foregrounding offers a consistent resume
  state (the player stays paused and does not silently auto-resume).
- Keep-awake during active playback, released on pause/completion/exit.
- Sound and vibration on step transitions, honoring user and operating-system
  settings.
- `routine_started` analytics emission (once) with only allowlisted categorical
  properties.

### Out of scope (owned by later tasks)

- **Durable session persistence, restore, abandon, exit-confirmation, and
  duplicate-finish guards** belong to RAHA-052. RAHA-051 keeps the session model
  correct in memory (the exact `routine_sessions`/`session_steps` write path and
  completion-policy evaluation already live in `LocalUserDataRepository.saveSessionWithSteps`).
- **Completion threshold / reward award** belongs to RAHA-052/RAHA-070.
- **Post-routine feedback** belongs to RAHA-053.

## Decisions

### 1. Demonstration rendering (placeholder now, video later)

The player's demonstration area is behind a Raha-owned interface
(`RoutineDemonstration`) that supports `play`/`pause`/`stop` and loops while
playing. RAHA-051 ships a looping, testable placeholder demonstration (a calm,
repeating animation of the current movement) because no playable media is
deliverable yet: the bundled starter catalog's media assets are `status: pending`
with no checksum, the Free50 fixture is a non-committed dev/test artifact, and the
production mobility library is purchased later (RAHA-082/RAHA-084).

The real `video_player`-backed renderer is a drop-in behind the same interface and
is deferred until playable media is delivered. This follows the project rule that
plugin-dependent playback sits behind Raha Move interfaces with fakes in tests.

**Review trigger:** bind the demonstration to delivered MP4 files when real
playable media becomes available; re-run the player golden/visual checks then.

### 2. Keep-awake via `wakelock_plus` behind an interface

The screen stays awake during active playback using `wakelock_plus`, wrapped in a
`ScreenWakeLock` interface (`enable`/`disable`) so widget tests use a fake and the
native plugin never leaks into the domain or presentation logic. Keep-awake is
enabled when playback starts/resumes and released on pause, completion, and exit.

### 3. Transition sound/vibration behind an interface

Step-transition feedback is a `TransitionFeedback` interface with a production
implementation using Flutter's built-in `SystemSound` (click) and `HapticFeedback`
(light impact) — no additional native plugin. It is gated by the user's
`sound_enabled`/`vibration_enabled` preferences and, because both primitives honor
the OS mute/haptics settings, the OS settings are respected automatically.

### 4. Media resolution for the player

The player loads a localized `RoutinePlaybackPlan` (ordered steps with step id,
exercise id, localized name and cue, duration, and the resolved `MediaDelivery`)
from the local Drift cache. It reuses the RAHA-050 media-selection rule (prefer the
published preferred playable asset, otherwise the first published playable asset).
Readiness (RAHA-050) already prepared the media before start, so the player only
preloads the next asset (`RoutineMediaPlaybackCoordinator.preloadAfterStep`).

### 5. Session model stays in memory for this task

`RoutinePlaybackSession` is the canonical "session model" the controller mutates on
each action. Its step-state rules mirror RAHA-001:

- a step that reaches its full duration is `completed` with credited time = target;
- a step that starts playback and is then skipped is `partial` (credited active time
  preserved, `skipRequested = true`);
- a step skipped before playback is `skipped` with 0 credited seconds;
- credited seconds never exceed the step target and pause/resume never double-count.

## Assumptions

- MVP routine steps are timed only (`duration_seconds`); the player shows a countdown
  timer. Repetition-only steps remain deferred.
- The player is entered only after the RAHA-050 readiness check returns `ready`.
- Analytics consent is honored by the existing `AnalyticsService`; the player emits
  only `routine_started` with `routine_id`, `session_id`, `source`, and
  `recommendation_id` (when present).

## Non-blocking risks

- The looping demonstration is a placeholder until real playable media is delivered;
  the acceptance criterion "loops the current demonstration" is met through the
  looping placeholder behind the media interface, and the video renderer is a
  tracked fast-follow.
