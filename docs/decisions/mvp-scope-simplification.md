# MVP scope simplification

**Status:** Accepted
**Affected work:** RAHA-032, RAHA-040–043, RAHA-063, RAHA-070–072

## Decision

The first MVP release uses a direct routine-browsing journey:

```text
Onboarding -> Home -> Browse routines -> Routine details -> Player
  -> Completion feedback -> Home
```

The following features are deferred from the default MVP build:

- movement preference collection and editing;
- the daily check-in and personalized recommendation journey;
- points, weekly goals, streaks, achievements, reward summaries, and the
  Progress navigation destination.

Language, accessibility, sound, vibration, download settings, saved routines,
session history, resumable playback, verified active minutes, and post-routine
feedback remain in scope.

## Implementation boundary

The deferred implementations and data structures remain in the repository.
Compile-time feature switches remove their routes and user-interface entry
points from the default build. A forward database migration stops new server
reward awards without deleting historical records or tables.

Re-enabling a deferred feature requires product review, updated acceptance
criteria, client switches, and—when gamification is restored—a new forward
database migration that reinstates the approved server award rules.

## Reason

This reduces onboarding friction and narrows the first release to the smallest
complete value loop: find a safe routine, play it, and record feedback. It also
allows personalization and motivation mechanics to be validated with user
evidence before they become part of the core experience.
