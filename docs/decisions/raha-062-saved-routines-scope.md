# RAHA-062 saved routines scope

- **Owner/date:** Engineering, 2026-09-04
- **Decision:** Until RAHA-064 Profile, Saved routines are opened from a localized Explore app-bar action.
- **Eligibility:** Only `published` routines with the `free` access tier can be newly saved. Premium and subscription behavior is intentionally out of scope.
- **Offline/conflicts:** The implementation delegates writes to `LocalUserDataRepository.saveSavedRoutine`, preserving its atomic outbox and tombstone/timestamp behavior. Repeated saves and unsaves are idempotent.
- **Unavailable history:** A retained saved row remains visible when catalog content is retired or unplayable. Its localized title is retained when present, and playback/navigation is disabled with a localized explanation.
- **Telemetry:** `saved_routine_changed` is emitted only through the existing consent-gated analytics interface, using allowlisted `routine_id` and `saved` properties.
