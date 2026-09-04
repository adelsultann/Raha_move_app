# RAHA-061 Explore Scope Decision

**Decision owner:** Adel
**Decision date:** 2026-09-04
**Status:** Approved for MVP implementation

## Decision

Explore categories use the existing localized `routine_context` taxonomy. The
initial approved contexts are desk breaks, morning mobility, evening
relaxation, and everyday mobility. Explore shows only contexts attached to
published routines in the locally cached catalog.

Body area remains a filter rather than a duplicate category. The Explore
experience continues to present guided routines, not an exercise encyclopedia.

RAHA-061 reserves a visible save-action location on routine details but does
not implement save state or save/unsave interactions. RAHA-062 owns those
offline-first mutations, synchronization, idempotency, and conflict handling.

## Rationale

The existing context taxonomy is already localized and content-release-backed,
so it supports offline browsing without introducing a second, ambiguous
category taxonomy. Deferring save behavior preserves the dependency boundary
between RAHA-061 and RAHA-062 and prevents a control that suggests persistence
before its local-first and synchronization behavior is implemented.

## Review trigger

Review when content editors need a browsing grouping that cannot be expressed
as a routine context, or when RAHA-062 implements saved routines.
