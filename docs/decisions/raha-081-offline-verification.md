# RAHA-081 Offline, Degraded-Network, and Recovery Verification

**Decision owner:** Adel  
**Decision date:** 2026-09-13  
**Status:** Approved for internal test release candidates only

## Scope

The starter catalog includes two approved **internal testing** demonstrations:

- `assets/starter_content/media/videos/neck.gif`
- `assets/starter_content/media/videos/shoulder.mp4`

They are app-bundled assets, not provider identities, remote storage keys, or
signed URLs. Their manifest records a SHA-256 checksum, published delivery
status, and the narrow `asset:` delivery-reference form. The app verifies the
checksum before considering a bundled asset ready; no network authorization,
download, or private-media cache is required for this starter routine.

The existing RAHA-026 fixture restrictions still apply. These files are only
for internal development and internal, non-distributed test release candidates.
They must not enter beta or production distribution. RAHA-082 and RAHA-084
remain responsible for replacing them with licensed production mobility media
and recording the private licensing evidence.

## Acceptance evidence

`integration_test/offline_routine_test.dart` runs on an Android emulator with
no content or user-data network transport. It verifies that a fresh local
database can:

1. apply the bundled catalog while the content source is unavailable;
2. save a compatible check-in and create a deterministic local recommendation;
3. checksum-verify the two bundled starter demonstrations;
4. complete the routine, save categorical feedback, and show provisional local
   progress;
5. retain all queued actions while synchronization is unavailable; and
6. synchronize each logical action exactly once after recovery, without
   duplicating completed progress.

Run the internal release-candidate journey with:

```powershell
flutter test integration_test/offline_routine_test.dart -d emulator-5554
```

The focused unit and repository suites continue to cover recovery states that
cannot safely be combined into a single device journey: low storage, corrupt
cache, failed or expired media authorization, server timeouts, interrupted
content releases, bounded sync retries, and idempotent recovery.

## Remaining release gate

This evidence does **not** authorize beta or production distribution. Before
either distribution, replace the testing media with approved production assets,
re-run this journey against that package, and complete RAHA-082/RAHA-084.
