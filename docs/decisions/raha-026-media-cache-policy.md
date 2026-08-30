# RAHA-026 Media Cache Policy

**Decision owner:** Adel  
**Decision date:** 2026-08-30  
**Status:** Approved for MVP implementation

## Decision

- The device media cache has a maximum size of **500 MiB** (`500 * 1024 * 1024` bytes).
- When space is needed, Raha Move evicts verified media by least-recently-used access time. Media for the active routine and the next requested preload are pinned during preparation and are never eviction candidates.
- Automatic routine preparation and next-media preloading use Wi-Fi only. A user who explicitly starts a routine may download its required active media on cellular data.
- If storage is insufficient, the app first evicts eligible least-recently-used media. If the required download still cannot fit, it preserves verified and pinned media and returns a recoverable storage-needed state. The presentation layer must provide localized guidance to free storage or retry; it must not discard an otherwise usable routine cache.
- Cached media is playable only after its published version and SHA-256 checksum are verified. A changed or corrupt entry is replaced only after replacement bytes pass verification and are committed.
- Catalog metadata contains only opaque delivery references. A trusted, entitlement- and license-aware resolver creates any short-lived download URL. The URL is a transient capability: it is never persisted, logged, reported in errors, or used as media identity.
- Every remote cache entry is scoped to the Supabase authenticated or anonymous user that authorized it and records the entitlement required at download time. A cache hit is allowed only for the active owner and a currently active entitlement projection.
- Logout, account switching, account deletion, and entitlement loss invoke a fail-closed purge. If private bytes cannot be deleted, the transition reports a blocking purge error instead of forgetting the cache index or exposing the file to the next account.
- The trusted resolver is the authenticated `resolve-media-delivery` Supabase Edge Function. It derives the caller from the verified JWT, reads private catalog/storage metadata with the service role, checks server-owned entitlement state, and signs only objects in the private `exercise-media` bucket for five minutes.

## Rationale

This preserves a dependable offline routine experience without uncontrolled device storage use or automatic cellular-data consumption. Pinning protects the routine the user is preparing to follow, while checksum/version validation prevents stale or corrupt bytes from being treated as playable.

## Review triggers

- Device-storage telemetry or support evidence shows that 500 MiB is unsuitable.
- The approved media license, entitlement model, or CDN authorization method changes.
- Product enables an explicit download setting with behavior beyond this MVP policy.
