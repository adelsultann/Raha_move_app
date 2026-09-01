# Raha Move Database Design

Related documents:

- [product-brief.md](product-brief.md) defines the product, audience, recommendation inputs, and roadmap.
- [design-and-screens.md](design-and-screens.md) defines the user journeys and information shown on each screen.
- [project-structure.md](project-structure.md) defines the Flutter, Drift, Supabase, repository, and offline-first architecture.
- [design-system.md](design-system.md) defines the visual foundation; it does not affect stored domain data.

## Purpose

Raha Move uses two coordinated relational databases:

- **Supabase Postgres** is the authoritative cloud database for accounts, published content, user history, progress, and synchronization.
- **Drift/SQLite** is the on-device database for fast local reads, offline routine playback, cached content, and pending user writes.

This document defines the logical schema, relationships, access rules, synchronization behavior, and migration strategy for the MVP. It is a design specification, not an executable migration.

## Design Principles

1. Use stable Raha Move IDs that do not depend on a footage provider, filename, or translated name.
2. Keep exercises, routines, routine steps, media assets, and completed sessions separate.
3. Store content translations as data so Arabic and English are first-class languages.
4. Keep recommendation logic explainable and versioned.
5. Record user activity locally first and synchronize it safely later.
6. Never trust the mobile client to award points, achievements, or subscription access.
7. Retain historical meaning when content changes by snapshotting essential session details.
8. Collect only data needed for personalization, delivery, safety, and progress.
9. Use soft retirement for published content; do not delete records referenced by history.
10. Apply Row Level Security to every user-facing Supabase table.

## System of Record

| Data | Cloud authority | Local behavior |
|---|---|---|
| Published exercises and routines | Supabase | Cached in Drift |
| Media metadata | Supabase | Cached in Drift; files use the device media cache |
| Guest identity | Supabase Auth anonymous user | Session retained securely on device |
| User profile and preferences | Supabase | Cached and editable offline |
| Check-ins and recommendation decisions | Supabase after sync | Created locally first |
| Routine sessions and feedback | Supabase after sync | Created and updated locally first |
| Saved routines | Supabase after sync | Optimistic local update |
| Points, streaks, achievements | Supabase/server functions | Cached read-only summary |
| Subscription entitlement | RevenueCat/backend integration | Cached with a short expiry |
| Raw provider imports and license records | Private backend only | Never shipped to the app |

Video bytes are stored in object storage and delivered through a CDN. The database stores metadata and storage keys, not video blobs or permanent signed URLs.

## Identifier and Time Conventions

- Use UUID primary keys for user-generated and ordinary relational records.
- Stable human-readable content IDs such as `raha_ex_000051` may be kept as unique public keys alongside UUID primary keys.
- Use lowercase snake_case for database names.
- Use `timestamptz` for instants and store them in UTC.
- Store the user's IANA timezone, such as `Asia/Riyadh`, when day boundaries matter.
- Use ISO 639-1 language codes: `ar` and `en` initially.
- Use integer seconds for routine and step durations.
- Use integers for points; never use floating-point values for rewards.
- Include `created_at` and `updated_at` on mutable synchronized records.
- User-created offline records receive their final UUID on the device, making retries idempotent.

## Relationship Overview

```text
auth.users
  └── profiles
      ├── user_preferences
      ├── reminder_schedules
      ├── check_ins ── recommendations ── routines
      ├── routine_sessions ── session_steps
      ├── saved_routines ── routines
      ├── user_achievements ── achievements
      └── point_ledger

content_providers
  ├── provider_exercises ── exercises
  └── media_assets ── exercises

exercises
  ├── exercise_translations
  ├── exercise_body_areas ── body_areas
  └── exercise_tags ── tags

routines
  ├── routine_translations
  ├── routine_steps ── exercises
  ├── routine_body_areas ── body_areas
  ├── routine_goals ── goals
  └── routine_positions ── movement_positions
```

## Enumerated Values

Postgres enums may be used for stable, closed workflow states. Product taxonomies that may expand should use lookup tables instead.

Suggested enums:

- `content_status`: `draft`, `review`, `published`, `retired`
- `difficulty_level`: `beginner`, `intermediate`, `advanced`
- `session_status`: `in_progress`, `completed`, `abandoned`
- `step_status`: `pending`, `completed`, `partial`, `skipped`
- `feedback_rating`: `much_better`, `little_better`, `same`, `less_comfortable`
- `media_type`: `video`, `image`, `animation`, `audio`
- `access_tier`: `free`, `premium`
- `sync_operation`: `upsert`, `delete`

Use lookup tables for body areas, goals, positions, equipment, routine contexts, tags, and achievements because content editors may add or localize them.

## Cloud Schema: Identity and Preferences

### `profiles`

One application profile per Supabase Auth user. Anonymous users receive a normal Auth UUID and can later link credentials without changing ownership.

| Column | Type | Notes |
|---|---|---|
| `user_id` | `uuid` PK/FK | References `auth.users(id)` with cascade on account deletion |
| `display_name` | `text` nullable | Optional; not required for onboarding |
| `preferred_locale` | `text` | `ar` or `en` |
| `timezone` | `text` | IANA timezone |
| `onboarding_completed_at` | `timestamptz` nullable | Null until setup is complete |
| `weekly_goal_days` | `smallint` | Check constraint from 1 to 7 |
| `created_at` | `timestamptz` | Server default `now()` |
| `updated_at` | `timestamptz` | Maintained by trigger |

Do not duplicate email, phone number, or authentication-provider details here unless the product has a clear display requirement; Supabase Auth owns those fields.

### `user_preferences`

| Column | Type | Notes |
|---|---|---|
| `user_id` | `uuid` PK/FK | One row per profile |
| `experience_level` | `difficulty_level` | Defaults to `beginner` |
| `sound_enabled` | `boolean` | Player preference |
| `vibration_enabled` | `boolean` | Transition preference |
| `download_on_wifi_only` | `boolean` | Media preference |
| `text_scale` | `numeric(3,2)` nullable | Only if app-level scaling is offered |
| `updated_at` | `timestamptz` | Used for synchronization |

Many-to-many preference tables hold flexible values:

- `user_preferred_positions(user_id, position_id)`
- `user_avoided_exercises(user_id, exercise_id, reason_code, note, created_at)`
- `user_body_area_preferences(user_id, body_area_id, preference_type)`

Free-text notes should be optional, length-limited, and excluded from analytics payloads.

### `reminder_schedules`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | Generated on device or server |
| `user_id` | `uuid` FK | Owner |
| `local_time` | `time` | Intended wall-clock time |
| `days_of_week` | `smallint[]` | Values 1 through 7 |
| `timezone` | `text` | IANA timezone used to schedule |
| `enabled` | `boolean` | Soft on/off state |
| `created_at` | `timestamptz` | Audit field |
| `updated_at` | `timestamptz` | Sync field |

## Cloud Schema: Content Catalog

### `content_providers`

Private registry for footage and metadata sources.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | Internal identifier |
| `key` | `text` unique | Example: `vital_animations` |
| `name` | `text` | Provider display name |
| `license_type` | `text` | Commercial, internal, or other |
| `license_reference` | `text` | Internal contract/document reference |
| `allowed_platforms` | `text[]` | Internal compliance metadata |
| `attribution_required` | `boolean` | Delivery requirement |
| `license_expires_at` | `timestamptz` nullable | If applicable |
| `internal_notes` | `text` nullable | Service-role access only |

Provider purchase documents and private notes must not be exposed through the mobile API.

### `exercises`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | Relational identifier |
| `public_id` | `text` unique | Stable Raha ID, e.g. `raha_ex_000051` |
| `status` | `content_status` | Publication lifecycle |
| `difficulty` | `difficulty_level` | Normalized difficulty |
| `access_tier` | `access_tier` | Free or premium |
| `default_points` | `smallint` | Content hint; server reward rules remain authoritative |
| `created_at` | `timestamptz` | Audit field |
| `updated_at` | `timestamptz` | Content sync cursor |

### `exercise_translations`

| Column | Type | Notes |
|---|---|---|
| `exercise_id` | `uuid` FK | Part of composite PK |
| `locale` | `text` | Part of composite PK |
| `name` | `text` | Required localized name |
| `description` | `text` nullable | Short description |
| `short_cue` | `text` nullable | Minimal player guidance |

Fallback order is the requested locale, then the configured content fallback (`en` initially). Publishing validation should require both Arabic and English for MVP content.

### `provider_exercises`

Maps provider records to stable Raha exercises and preserves import provenance.

| Column | Type | Notes |
|---|---|---|
| `provider_id` | `uuid` FK | Part of composite PK |
| `source_exercise_id` | `text` | Part of composite PK |
| `exercise_id` | `uuid` FK | Raha exercise |
| `source_payload` | `jsonb` | Raw normalized import evidence; private |
| `source_updated_at` | `timestamptz` nullable | Provider timestamp when available |
| `imported_at` | `timestamptz` | Last successful import |

Add a unique constraint on `(provider_id, source_exercise_id)` and make imports upsert against it.

### `media_assets`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | Stable media identity |
| `exercise_id` | `uuid` FK | Demonstrated exercise |
| `provider_id` | `uuid` FK nullable | Null for Raha-created media |
| `media_type` | `media_type` | Usually `video` |
| `storage_bucket` | `text` | Object-storage bucket |
| `storage_key` | `text` | Stable object path, not a signed URL |
| `mime_type` | `text` | Example: `video/mp4` |
| `width` | `integer` nullable | Pixels |
| `height` | `integer` nullable | Pixels |
| `duration_ms` | `integer` nullable | Clip duration |
| `checksum_sha256` | `text` | Cache validation and deduplication |
| `is_preferred` | `boolean` | One preferred playable asset per exercise/context |
| `status` | `content_status` | Delivery lifecycle |
| `updated_at` | `timestamptz` | Cache invalidation cursor |

A partial unique index should prevent multiple preferred published assets for the same exercise and media type. Storage access may use short-lived signed URLs created by a trusted function when licensing requires it.

### Content lookup tables

Each lookup table has an ID, stable key, sort order, active flag, and optional translation table:

- `body_areas` and `body_area_translations`
- `goals` and `goal_translations`
- `movement_positions` and `movement_position_translations`
- `equipment` and `equipment_translations`
- `routine_contexts` and `routine_context_translations`
- `tags` and `tag_translations`

Join tables use composite primary keys:

- `exercise_body_areas(exercise_id, body_area_id, relevance_weight)`
- `exercise_positions(exercise_id, position_id)`
- `exercise_equipment(exercise_id, equipment_id)`
- `exercise_goals(exercise_id, goal_id)`
- `exercise_tags(exercise_id, tag_id)`

### `routines`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | Relational identifier |
| `public_id` | `text` unique | Stable Raha routine ID |
| `status` | `content_status` | Publication lifecycle |
| `difficulty` | `difficulty_level` | Routine-level difficulty |
| `access_tier` | `access_tier` | Free or premium |
| `estimated_duration_seconds` | `integer` | Validated against steps during publishing |
| `version` | `integer` | Increment for a materially changed published routine |
| `published_at` | `timestamptz` nullable | Publication timestamp |
| `created_at` | `timestamptz` | Audit field |
| `updated_at` | `timestamptz` | Content sync cursor |

### `routine_translations`

| Column | Type | Notes |
|---|---|---|
| `routine_id` | `uuid` FK | Part of composite PK |
| `locale` | `text` | Part of composite PK |
| `name` | `text` | Localized title |
| `summary` | `text` | Intended-benefit wording without medical claims |

### `routine_steps`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | Stable step identity |
| `routine_id` | `uuid` FK | Parent routine |
| `exercise_id` | `uuid` FK | Movement to perform |
| `position` | `smallint` | Unique within a routine, starting at 1 |
| `duration_seconds` | `integer` nullable | Required for timed steps |
| `repetition_count` | `smallint` nullable | Required for repetition steps |
| `rest_after_seconds` | `smallint` | Defaults to 0 |
| `side_mode` | `text` nullable | None, alternating, left, right, or both |
| `is_optional` | `boolean` | Whether skipping affects completion |

Require exactly one of `duration_seconds` or `repetition_count`, unless a future step type explicitly supports another measure. Add a unique constraint on `(routine_id, position)`.

Routine classification joins:

- `routine_body_areas(routine_id, body_area_id, relevance_weight)`
- `routine_goals(routine_id, goal_id, relevance_weight)`
- `routine_positions(routine_id, position_id)`
- `routine_context_memberships(routine_id, context_id)`
- `routine_equipment(routine_id, equipment_id)`

### `content_releases`

Tracks coherent catalog versions for incremental synchronization.

| Column | Type | Notes |
|---|---|---|
| `id` | `bigint` generated PK | Monotonic release cursor |
| `version` | `text` unique | Human-readable release label |
| `published_at` | `timestamptz` | Availability time |
| `minimum_app_version` | `text` nullable | Compatibility gate |
| `manifest_checksum` | `text` | Validates the release manifest |

Published content changes should be attached to a release so devices can apply a consistent snapshot instead of mixing partially updated routines and steps.

## Cloud Schema: Check-ins and Recommendations

### `check_ins`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | Generated on device |
| `user_id` | `uuid` FK | Owner |
| `body_state` | `text` | Comfortable, stiff, tired, or tense taxonomy key |
| `goal_id` | `uuid` FK | Desired outcome |
| `available_minutes` | `smallint` | Allowed MVP values: 3, 5, 10, 15 |
| `position_id` | `uuid` FK nullable | Null means any position |
| `started_at` | `timestamptz` | First question shown |
| `completed_at` | `timestamptz` nullable | Null for an unfinished check-in |
| `created_at` | `timestamptz` | Audit field |
| `updated_at` | `timestamptz` | Sync field |

Selected areas are stored in `check_in_body_areas(check_in_id, body_area_id)`. Avoid a JSON answer blob for core MVP inputs because normalized columns are easier to validate, query, and evolve.

### `recommendations`

One check-in can produce several recommendations when the user requests alternatives.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | Generated on device or server |
| `user_id` | `uuid` FK | Denormalized owner for simple RLS |
| `check_in_id` | `uuid` FK | Source answers |
| `routine_id` | `uuid` FK | Recommended routine |
| `engine_version` | `text` | Example: `rules_v1` |
| `rank` | `smallint` | Candidate rank |
| `score` | `integer` | Comparable only within the engine version |
| `reason_codes` | `text[]` | Stable localized explanation inputs |
| `shown_at` | `timestamptz` | Impression time |
| `accepted_at` | `timestamptz` nullable | User started or chose it |
| `rejected_at` | `timestamptz` nullable | User requested another option |
| `rejection_reason` | `text` nullable | Too easy, too difficult, position, discomfort, other |

Store reason codes such as `body_area_match` and `seated_preference`, not a final localized sentence. The app generates Arabic or English copy from those codes and the captured inputs.

### `recommendation_rule_sets`

Versioned, server-managed configuration for reproducibility:

| Column | Type | Notes |
|---|---|---|
| `version` | `text` PK | Immutable once used in production |
| `configuration` | `jsonb` | Weights, exclusions, tie-breakers |
| `active_from` | `timestamptz` | Activation time |
| `retired_at` | `timestamptz` nullable | End of use |

The MVP can execute rules locally from a downloaded configuration. The version stored with each recommendation explains which rules produced it.

## Cloud Schema: Sessions and Progress

### Approved completion-schema authority

The approved RAHA-001 decision record is authoritative for session completion. This supersedes earlier database wording that omitted `partial` steps or represented a session only with `active_seconds` and `completed_step_count`.

- Step states are `pending`, `completed`, `partial`, and `skipped`.
- A step that begins playback and is then skipped remains `partial`, retains credited active duration, and records `skip_requested = true`.
- A routine session persists its scheduled and credited durations, all terminal-step counts, and `completion_policy_version` so historical completion decisions remain reproducible.
- Terminal sessions cannot return to `in_progress`; trusted server logic validates completion before derived rewards are awarded.
- MVP routine steps are timed only: `target_duration_seconds` is required. Repetition-only steps are deferred pending a versioned repetition-credit policy.
- An `in_progress` session expires to `abandoned` 24 hours after its latest credited activity. The expiry transition is idempotent.
- The offline-first MVP uses bounded device-reported active time as an input, not proof of attested playback. Trusted server logic caps and derives completion data from routine-bound steps before any authoritative reward processing.

### `routine_sessions`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | Generated on device before playback |
| `user_id` | `uuid` FK | Owner |
| `routine_id` | `uuid` FK | Source routine |
| `routine_version` | `integer` | Version used during playback |
| `recommendation_id` | `uuid` FK nullable | Null for Explore or repeat starts |
| `status` | `session_status` | Current lifecycle |
| `started_at` | `timestamptz` | Start instant |
| `completed_at` | `timestamptz` nullable | Completion instant |
| `target_duration_seconds` | `integer` | Scheduled routine duration snapshot |
| `actual_duration_seconds` | `integer` | Credited active duration; excludes paused, backgrounded, loading, and transition time |
| `total_step_count_snapshot` | `smallint` | Preserves historical context |
| `steps_completed` | `smallint` | Terminal `completed` step count |
| `steps_partial` | `smallint` | Terminal `partial` step count |
| `steps_skipped` | `smallint` | Terminal `skipped` step count |
| `completion_policy_version` | `text` | Version of the thresholds used to evaluate terminal completion |
| `source` | `text` | Recommendation, explore, saved, repeat, or bundled |
| `created_at` | `timestamptz` | Audit field |
| `updated_at` | `timestamptz` | Conflict-resolution field |

The session keeps the routine ID plus critical snapshots. Routine rows referenced by sessions are retired rather than deleted. A session is `completed` only when the versioned RAHA-001 completion policy evaluates both credited duration and skipped steps as eligible; otherwise a terminal session is `abandoned`.

### `session_steps`

| Column | Type | Notes |
|---|---|---|
| `session_id` | `uuid` FK | Part of composite PK |
| `routine_step_id` | `uuid` FK | Part of composite PK |
| `exercise_id_snapshot` | `uuid` | Exercise used at playback time |
| `position_snapshot` | `smallint` | Historical order |
| `status` | `step_status` | Pending, completed, partial, or skipped |
| `target_duration_seconds` | `integer` | Scheduled duration; required for every MVP step |
| `active_duration_seconds` | `integer` | Credited active time, capped at the target duration |
| `skip_requested` | `boolean` | Records an explicit Skip interaction without discarding credited partial activity |
| `started_at` | `timestamptz` nullable | Step start |
| `finished_at` | `timestamptz` nullable | Step finish |

### `session_feedback`

| Column | Type | Notes |
|---|---|---|
| `session_id` | `uuid` PK/FK | One feedback response per session |
| `user_id` | `uuid` FK | Denormalized owner for RLS |
| `rating` | `feedback_rating` | Before-and-after outcome |
| `uncomfortable_exercise_id` | `uuid` FK nullable | Optional follow-up when less comfortable |
| `note` | `text` nullable | Short, optional, private user note |
| `created_at` | `timestamptz` | Response time |
| `updated_at` | `timestamptz` | Sync field |

Feedback is self-reported well-being data, not a diagnosis. Access should be limited to the user and trusted backend roles.

### `saved_routines`

Composite primary key `(user_id, routine_id)` with `created_at` and optional `deleted_at`. A tombstone or explicit delete operation is necessary so an offline unsave can synchronize across devices.

### Progress summaries

The source of truth is completed sessions, feedback, and the point ledger. Server views or materialized summaries may serve the Progress screen:

- `user_weekly_progress`
- `user_body_area_progress`
- `user_feedback_summary`
- `user_current_streak`

Do not store a medically suggestive body score. Summary rows may be cached in Drift, but must be rebuildable from authoritative events.

## Cloud Schema: Gamification

### `point_ledger`

Use an append-only ledger rather than a mutable total.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | Server generated |
| `user_id` | `uuid` FK | Recipient |
| `points` | `integer` | Positive award or explicit correction |
| `reason_code` | `text` | Routine completion, milestone, correction |
| `rule_version` | `text` | Immutable policy version that produced the award |
| `source_type` | `text` | Session, achievement, challenge, admin |
| `source_id` | `uuid` nullable | Idempotency source |
| `created_at` | `timestamptz` | Award time |

Add a unique constraint on `(user_id, reason_code, source_type, source_id)` where `source_id` is not null. This prevents retrying a completed session from awarding points twice. Point-award rules are server-owned and versioned; every ledger row stores the rule version that created it.

### `achievements`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | Internal ID |
| `key` | `text` unique | Stable code such as `first_step` |
| `category` | `text` | Consistency, exploration, time, and so on |
| `criteria_version` | `integer` | Supports later rule changes |
| `criteria` | `jsonb` | Server-evaluated definition |
| `points` | `smallint` | Optional award |
| `status` | `content_status` | Lifecycle |

Localized names and descriptions belong in `achievement_translations(achievement_id, locale, name, description)`.

### `user_achievements`

| Column | Type | Notes |
|---|---|---|
| `user_id` | `uuid` FK | Part of composite PK |
| `achievement_id` | `uuid` FK | Part of composite PK |
| `earned_at` | `timestamptz` | Server award time |
| `source_id` | `uuid` nullable | Session or event that triggered it |
| `criteria_version` | `integer` | Rule version used |

### Streaks and recovery days

Streak state should be calculated by trusted server code from completed sessions, the user's timezone, and explicit recovery-day events. If a cached `user_streaks` row is added for speed, it is a derived projection rather than the authority.

Define a qualifying movement day precisely: at least one server-accepted completed session that meets the minimum completion rule. Use the timezone captured for the event so travel or later timezone changes do not rewrite history unexpectedly.

## Subscription Data

RevenueCat remains the entitlement authority. Supabase stores a minimal projection for backend authorization:

### `user_entitlements`

| Column | Type | Notes |
|---|---|---|
| `user_id` | `uuid` FK | User |
| `entitlement_key` | `text` | Example: `premium` |
| `is_active` | `boolean` | Current backend decision |
| `product_id` | `text` nullable | Store product |
| `expires_at` | `timestamptz` nullable | Null for non-expiring access |
| `environment` | `text` | Sandbox or production |
| `provider_event_id` | `text` unique | Webhook idempotency |
| `updated_at` | `timestamptz` | Projection freshness |

Only a trusted webhook or service role may write entitlement rows. The client may read its own effective entitlement but cannot grant itself access.

## Row Level Security and API Boundaries

Enable RLS on all exposed tables.

### User-owned tables

For profiles, preferences, reminders, check-ins, recommendations, sessions, feedback, and saved routines:

- `SELECT`: `user_id = auth.uid()`
- `INSERT`: `user_id = auth.uid()` and referenced parent rows also belong to the user
- `UPDATE`: `user_id = auth.uid()` with ownership unchanged
- `DELETE`: only where deletion is part of product behavior; otherwise use a controlled RPC or tombstone

Child tables without `user_id` require an `exists` ownership check through their parent, or should include a denormalized immutable `user_id` to keep policies simple and fast.

### Content tables

- Authenticated and anonymous app users may read only `published` content compatible with their app version.
- Draft, review, provider import, license, and internal-note data is service-role only.
- Mobile clients cannot write catalog content.
- Premium playback authorization is checked through an entitlement-aware function; merely hiding premium rows in the UI is insufficient.

### Server-owned tables

The point ledger, achievements awarded, streak projections, and entitlements are read-only to the client. Trusted database functions, edge functions, or webhook handlers perform writes.

Use explicit column lists in views and RPC return types. Never expose `source_payload`, provider notes, license documents, webhook payloads, or service credentials.

## Drift Local Database

Drift mirrors only the data needed by the app and adds local synchronization metadata. It is not a byte-for-byte copy of Postgres.

### Local content tables

- `local_exercises`
- `local_exercise_translations`
- `local_media_assets`
- `local_body_areas` and localized labels
- `local_goals` and localized labels
- `local_positions` and localized labels
- `local_routines`
- `local_routine_translations`
- `local_routine_steps`
- Local join tables required for recommendation filtering
- `local_content_release`

### Local user tables

- `local_profile`
- `local_user_preferences`
- `local_reminder_schedules`
- `local_check_ins` and `local_check_in_body_areas`
- `local_recommendations`
- `local_routine_sessions`
- `local_session_steps`
- `local_session_feedback`
- `local_saved_routines`
- Cached progress, achievement, point, and entitlement projections

### Synchronization metadata

Each locally editable row includes:

- `sync_state`: `synced`, `pending_create`, `pending_update`, `pending_delete`, or `failed`
- `local_updated_at`: device timestamp for UI ordering only
- `server_updated_at`: last accepted cloud timestamp
- `last_sync_error`: nullable diagnostic code, not a raw sensitive response

Use a durable `sync_outbox` table:

| Column | Purpose |
|---|---|
| `id` | Monotonic local queue ID |
| `entity_type` | Check-in, session, feedback, saved routine, preference |
| `entity_id` | Stable UUID of the affected record |
| `operation` | Upsert or delete |
| `payload` | Versioned JSON payload |
| `attempt_count` | Retry tracking |
| `next_attempt_at` | Exponential backoff |
| `created_at` | Queue ordering |

Write the domain row and its outbox entry in one Drift transaction. This prevents an app termination between saving user progress and queuing its upload.

Video files remain outside SQLite. A local media index may record storage key, checksum, local path, byte size, last access time, and cache state.

## Synchronization Protocol

### Content pull

1. Read the last successfully applied content release from Drift.
2. Request the next compatible release manifest.
3. Download changed rows and tombstones.
4. Validate IDs, relationships, release checksum, and minimum app version.
5. Apply the entire release in one Drift transaction.
6. Mark the release current only after the transaction succeeds.
7. Download media lazily; bundled starter content remains available meanwhile.

### User-data push

1. Save the action locally and enqueue an outbox operation.
2. Send operations in dependency order: check-in, recommendation, session, steps, feedback.
3. Upsert by client-generated UUID.
4. Treat an identical repeated request as success.
5. Let trusted backend logic validate completion and award derived progress once.
6. Remove the outbox item only after a confirmed response.

### User-data pull

After pushing, pull changes newer than the last server cursor for the signed-in user. This supports multiple devices and restores. Use server-issued cursors or monotonically ordered change records rather than relying solely on device clocks.

### Conflict rules

- Append-only events such as completed sessions and point entries are merged by ID.
- Preferences use server `updated_at`; a later explicit edit wins.
- Saved routines use an operation timestamp or tombstone so unsave actions are not resurrected.
- An in-progress session is owned by the most recently active device; a completed session cannot return to `in_progress`.
- Server-derived points, achievements, streaks, and entitlements always override local projections.
- Content releases are atomic and server-authoritative.

Clock skew must not decide rewards or security-sensitive state.

## Deletion and Retention

### Account deletion

An account-deletion workflow should:

1. Re-authenticate or otherwise verify the request as required by platform policy.
2. Mark the request for trusted backend processing.
3. Delete or anonymize user-owned data according to the privacy policy.
4. Delete the Supabase Auth user after dependent cleanup succeeds.
5. Clear the local Drift database, cached tokens, and downloaded private media metadata.

Foreign keys from user-owned tables should normally cascade from the profile/auth identity. Analytics systems need their own deletion or anonymization procedure.

### Content retention

Published exercises and routines referenced by session history are set to `retired`; they are not hard-deleted. Media delivery can be disabled while historical names and relationships remain available.

### Suggested retention decisions before launch

- Maximum age of unfinished check-ins
- Maximum age of abandoned sessions
- Retention of optional free-text notes
- Raw import payload retention
- Sync error log retention
- Account-deletion grace period

These must be confirmed in the privacy policy and reviewed against applicable Saudi and launch-market requirements.

## Indexes and Constraints

At minimum, add indexes for:

- Every foreign key used in joins or RLS ownership checks
- `exercises(status, updated_at)`
- `routines(status, access_tier, updated_at)`
- `routine_steps(routine_id, position)` unique
- Catalog join tables in both traversal directions where needed
- `media_assets(exercise_id, status, is_preferred)`
- `check_ins(user_id, completed_at desc)`
- `recommendations(user_id, shown_at desc)`
- `routine_sessions(user_id, started_at desc)`
- `routine_sessions(user_id, status, updated_at)`
- `session_feedback(user_id, created_at desc)`
- `point_ledger(user_id, created_at desc)`
- `user_achievements(user_id, earned_at desc)`
- `sync_outbox(next_attempt_at)` locally

Important checks include:

- Positive timed-step and routine durations; repetition-only steps are deferred from MVP
- Weekly goal between 1 and 7
- Available minutes limited to supported values for the MVP
- Completed sessions require `completed_at`
- `completed_at >= started_at`
- Non-negative target/actual session duration, step active duration, and step counts
- `actual_duration_seconds <= target_duration_seconds`
- `active_duration_seconds <= target_duration_seconds`
- Completed sessions require the configured completion threshold and skipped-step allowance; terminal sessions cannot return to `in_progress`
- Locale restricted to supported values until a locale registry is introduced
- One translation per entity and locale
- One provider mapping per provider source ID
- One point award per idempotent source

## Migrations and Environments

- Keep Supabase SQL migrations in version control and apply them in order.
- Keep Drift schema versions and migration tests in the Flutter repository.
- Never edit a migration that has reached a shared environment; add a new migration.
- Maintain separate development, staging, and production Supabase projects.
- Seed development and test environments with synthetic users and license-safe sample content.
- Do not copy production user data into development.
- Back up Postgres before destructive production migrations.
- Test forward Drift migrations from every supported application schema version.
- Deploy backward-compatible database changes before releasing mobile code that depends on them.

Recommended rollout order:

```text
Add nullable column/table
  -> deploy backend support
  -> release app that reads/writes it
  -> backfill and validate
  -> add stricter constraint in a later migration
```

## MVP Implementation Order

1. Identity, profiles, preferences, and RLS foundations.
2. Content providers, exercises, translations, media, routines, and routine steps.
3. Lookup and classification tables needed by the rules engine.
4. Atomic content releases and Drift content caching.
5. Check-ins, recommendation records, and engine-version configuration.
6. Routine sessions, step progress, feedback, and the sync outbox.
7. Saved routines and Progress-screen views.
8. Server-owned point ledger, achievements, and streak projections.
9. Entitlement projection when subscriptions enter scope.

## Decisions Still to Confirm

- Whether session notes are needed at all; omitting them reduces sensitive free text.
- Which premium catalog metadata is visible before purchase.
- The precise streak and recovery-day rules.
- Media signing and CDN rules required by each footage license.
- Launch-market privacy retention periods and data residency requirements.

These choices change behavior or policy, but they do not require restructuring the core schema described above.
