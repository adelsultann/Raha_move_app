# Raha Move Tasks and Acceptance Criteria

## Purpose

This document converts the Raha Move product, design, architecture, database, and asset specifications into an implementation-ready MVP backlog. It is the shared delivery contract for product, design, engineering, content, and quality assurance.

The MVP proves the core hypothesis: a user who feels stiff can complete a short, suitable movement routine more consistently when Raha Move chooses it, explains the choice, and makes it easy to finish.

Related specifications:

- [Product brief](product-brief.md)
- [Design and screens](design-and-screens.md)
- [Design system](design-system.md)
- [Project structure](project-structure.md)
- [Database design](database.md)
- [Asset structure](assets_strcture.md)

## Delivery Conventions

### Priority

| Priority | Meaning |
|---|---|
| P0 | Required for the first usable MVP and release candidate. |
| P1 | Required before public launch, but not necessarily for the first internal prototype. |
| P2 | Valuable follow-up work that must not delay MVP validation. |

### Status

Use one status per task: `Not started`, `In progress`, `Blocked`, `In review`, or `Done`.

### Acceptance criteria syntax

Functional criteria use **Given / When / Then** where that makes behavior easier to verify. Criteria that describe static quality gates use direct, measurable statements.

### Global definition of ready

A task is ready for implementation when:

- Its user outcome, priority, dependencies, and acceptance criteria are understood.
- Required designs and Arabic and English copy exist, or the task explicitly includes producing them.
- Data, analytics, security, and accessibility implications have been identified.
- Any licensed media needed by the task is approved for the intended use.
- Open decisions that could materially change the implementation are resolved in an architecture decision record (ADR) or product decision note.

### Global definition of done

A task is done only when:

- All task-specific acceptance criteria pass.
- User-facing behavior works in Arabic RTL and English LTR.
- Loading, empty, error, offline, and retry states are handled where applicable.
- Accessibility labels, focus order, contrast, touch targets, and text scaling have been checked.
- Unit, widget, repository, golden, or integration tests have been added in proportion to the risk.
- Analytics record the agreed events without personal or sensitive free-text data.
- No provider IDs, private asset URLs, credentials, license documents, or production secrets are exposed to the client or repository.
- Generated code is current, static analysis passes, tests pass, and the Android debug build succeeds in CI.
- Relevant documentation is updated and the work has been reviewed.

## MVP Scope and Release Boundary

### Included

- Flutter application for Android and iOS.
- Arabic and English localization with complete RTL and LTR support.
- Guest-first onboarding and basic preferences.
- Five-step daily check-in.
- Transparent, rules-based routine recommendation and explanation.
- Alternative recommendation requests.
- Provider-independent exercise and routine catalog.
- Focused routine player with local progress persistence.
- Before-and-after feedback.
- Today, Explore, Progress, and Profile destinations.
- Saved routines, basic points, weekly goals, streaks, and achievements.
- Local-first data, content synchronization, media caching, and a bundled starter routine.
- Product analytics, crash reporting, privacy controls, and release quality gates.

### Explicitly deferred

- Social feeds and competitive leaderboards.
- Advanced physical assessments or medical diagnosis.
- AI-generated recommendations.
- Full warm-up categories for gym or sports.
- Family or social challenges.
- Advanced adaptive difficulty.
- Dark mode unless separately approved.
- Paid subscriptions and purchase flows until entitlement scope is confirmed.

## Milestone 0 — Product and Engineering Decisions

### RAHA-001 — Resolve MVP decision log

**Priority:** P0  
**Owner:** Product + Engineering  
**Dependencies:** None

Record the decisions that affect schema, synchronization, analytics, and completion behavior before feature implementation begins.

**Acceptance criteria**

- An ADR or decision note states whether recommendations run entirely on-device or use an online backend function.
- The minimum completion threshold is defined, including how skipped steps and partial time affect completion.
- The handling of unfinished check-ins is defined: device-only, synchronized, or automatically expired.
- The guest identity and account-upgrade behavior is defined, including whether guest history is preserved after registration.
- MVP retention periods are defined for unfinished check-ins, abandoned sessions, sync diagnostics, and account deletion.
- The supported Android and iOS versions and the initial compact-phone test size are recorded.
- Every decision has an owner, decision date, rationale, and review trigger.

#### Approved MVP decision record

**Decision owner:** Adel  
**Decision date:** 2026-08-22  
**Status:** Approved for MVP implementation, except where a legal review is explicitly required before public launch.

##### Recommendation execution

The MVP recommendation engine runs entirely on-device. It queries the local Drift cache of normalized exercise and routine metadata; no backend function participates in recommendation selection.

- Recommendation rules, weights, candidate filtering, and tie-breaking are versioned local configuration, not hardcoded in widgets.
- Every persisted recommendation records the routine ID, check-in ID, reason keys, and `recommendationPolicyVersion` so later rule tuning does not rewrite historical decisions.
- The backend remains responsible for delivering validated content releases and synchronizing completed recommendation records. It does not select the MVP recommendation.
- **Review trigger:** Revisit if content or personalization cannot fit safely in the local catalog, if real-time server signals become product-critical, or when more advanced personalization is introduced.

##### Routine completion threshold

A routine session becomes terminal only through explicit abandonment or completion evaluation. It is marked **completed** only when both conditions hold:

```text
actualDurationSeconds >= 0.80 * targetDurationSeconds
stepsSkipped <= floor(0.20 * totalSteps)
```

Otherwise, a terminal session is **abandoned**. Abandoned sessions remain available for funnel and drop-off analysis but do not count toward completed-routine totals, weekly goals, points, achievements, streaks, or movement-day statistics.

The maximum skipped-step allowance uses `floor` so its behavior is unambiguous for short routines. For example, a 3-step routine permits 0 skipped steps, a 5-step routine permits 1, and a 10-step routine permits 2.

Only active playback time counts toward `actualDurationSeconds`; paused, backgrounded, loading, and transition time do not. Time is credited per scheduled step and cannot be inflated by replaying a movement:

```text
creditedStepSeconds = min(actualStepTime, targetStepTime)
actualDurationSeconds = sum(creditedStepSeconds for all scheduled steps)
```

**Step states**

| State | Definition | Duration contribution |
|---|---|---:|
| `completed` | The planned step timer reaches its end. | Up to the step target duration |
| `partial` | Playback started but the user left the step before its planned end. | Elapsed active time, capped at the step target duration |
| `skipped` | The user advances before active playback starts. | 0 seconds |

`isQualified` is a derived, analytic value, not a replacement for the literal `completed` state:

```text
isQualified = actualStepTime >= 0.50 * targetStepTime
```

If a user watches any part of a step and then selects Skip, the step keeps its elapsed active time and is recorded as `partial`; the interaction can separately retain a `skipRequested` event for product analysis. This prevents discarding genuine activity while keeping zero-time skips visible.

The completion thresholds (80%, 20%, and 50%) are versioned configuration. Each session stores `completionPolicyVersion`; past sessions retain the policy under which they were evaluated.

**Data model requirements**

`RoutineSession` stores:

- `status`: `in_progress`, `completed`, or `abandoned`
- `targetDurationSeconds` and `actualDurationSeconds`
- `totalSteps`, `stepsCompleted`, `stepsPartial`, and `stepsSkipped`
- `completionPolicyVersion`

Step records store the terminal state, target duration, active duration, and any explicit skip interaction needed for analytics. The system must define and test the inactivity/expiry rule that moves a resumable `in_progress` session to `abandoned`.

**Analytics rule**

Abandoned sessions are excluded from completion counts but included in funnel completion-rate calculations:

```text
completionRate = completedSessions / (completedSessions + abandonedSessions)
```

Non-terminal `in_progress` sessions are excluded from this rate until they are completed or abandoned.

**Review trigger:** Revisit after a meaningful beta sample, or earlier if data indicates that short routines are unfairly hard to complete or completion behavior is being distorted.

##### Identity, retention, and device policy

| Decision | Choice | Rationale | Review trigger |
|---|---|---|---|
| Unfinished check-ins | Device-only with a 24-hour expiry | Check-ins are ephemeral and have no cross-device value in MVP. | Cross-device check-in continuity becomes a requested feature. |
| Guest identity | Create a local guest UUID immediately; link it to Supabase anonymous authentication when connectivity is available. Preserve history when the guest upgrades to a registered account. | A fresh installation can complete the bundled starter routine offline; later linking avoids a data migration. | Guest-abuse controls or anonymous-auth limits become a problem. |
| Retention: unfinished check-ins | 24 hours | No product value after expiry. | — |
| Retention: abandoned sessions | Retain raw records for 90 days, then retain only approved aggregate analytics. Apply this independently to app data and analytics systems. | Supports funnel analysis while limiting long-term raw behavioral retention. | PostHog or storage cost becomes material. |
| Retention: sync diagnostics | 30 days | Their debugging value drops quickly. | — |
| Account deletion | Complete purge within 30 days of a verified request. This is a placeholder pending PDPL legal review. | Defines an operational target while legal requirements are confirmed. | **Mandatory legal review before public launch.** |
| Minimum OS versions | Android 7.0 / API 24 and iOS 15.0 | Current MVP engineering baseline. Verify all selected plugins and the pinned Flutter SDK before every beta/release. | Supported-device data or plugin requirements change. |
| Compact test devices | iPhone SE and Galaxy A-series-class devices (approximately 360 × 640 logical pixels) | Represents compact and budget-conscious launch-market devices. | Device analytics indicate a different lower-bound device profile. |

The current Flutter deployment support matrix includes Android API 24+ and iOS 15+; the project must revalidate this choice and all plugin deployment requirements before release. See [Flutter supported deployment platforms](https://docs.flutter.dev/reference/supported-platforms) and [Flutter Android deployment guidance](https://docs.flutter.dev/deployment/android).

##### Telemetry privacy and consent

**Decision owner:** Adel  
**Decision date:** 2026-08-28  
**Status:** Approved for MVP implementation. PDPL and data-residency legal review remains mandatory before public launch.

- Product analytics is optional and disabled by default. It starts only after the user explicitly opts in.
- Crash reporting is a separate optional consent and is also disabled by default. Consent to one service does not enable the other.
- Profile settings provide separate, localized controls to grant or withdraw analytics and crash-reporting consent. Withdrawing consent stops future collection for that service immediately.
- Event schemas use stable, language-neutral event names and an implementation-enforced allowlist of approved categorical properties and stable Raha identifiers needed to measure the core journey. The allowlist must exclude user-entered free text and direct identifiers.
- Analytics, diagnostic logs, and crash reports must not contain names, email addresses, phone numbers, free-text health notes, raw body-state answers, signed or private media URLs, credentials, tokens, raw provider payloads, license records, or complete internal service responses. Crash-report breadcrumbs and diagnostic logging use the same redaction rules.
- PostHog autocapture and session replay are disabled in every environment.
- Retain raw product analytics for 90 days and crash-report data for 30 days, then delete or anonymize it according to the vendor procedure. Account deletion must trigger the applicable analytics and crash-report deletion or anonymization workflow in addition to app and backend cleanup.
- Development and test builds use a debug-only telemetry sink that permits local verification of event names and properties without sending data to production datasets. Development, staging, and production telemetry configurations and credentials remain separated.
- Native crash reporting has an Android API 24–30 coverage limitation. The selected crash-reporting integration must document the affected crash classes and the release team must assess the limitation before beta and public launch.
- **Review trigger:** Complete PDPL, data-residency, vendor data-processing, retention, and deletion-workflow review before any public release or whenever telemetry vendors, processing regions, or tracked properties change.

### RAHA-002 — Approve content and safety policy

**Priority:** P0  
**Owner:** Product + Content + Legal/Safety reviewer  
**Dependencies:** None

**Acceptance criteria**

- Every publishable movement requires recorded content, translation, media, provenance, and safety-review approval.
- The policy defines language for general discomfort, sharp pain, and the post-session response `less_comfortable` without making medical claims.
- Benefit copy uses qualified wording such as “may help” or “can support” and is reviewed in both languages.
- The approved prototype media set has documented usage rights for bundling, streaming, caching, and offline playback.
- Purchased provider media and commercial records are stored outside the public repository.
- The policy names the person or role authorized to move content from `review` to `published`.

## Milestone 1 — Application Foundation

### RAHA-010 — Initialize the Flutter workspace and environments

**Priority:** P0  
**Owner:** Engineering  
**Dependencies:** RAHA-001

**Acceptance criteria**

- A pinned Flutter SDK builds the application for the supported Android and iOS targets.
- The codebase uses the feature-first layered structure defined in `project-structure.md`.
- Riverpod, GoRouter, Freezed, JSON serialization, Drift, localization, and asset generation are configured with compatible pinned versions.
- Development, staging, test, and production configuration are separated; no production secret is committed to source control.
- A sample generated provider, typed route, immutable model, Drift table, localized string, and generated asset reference compile successfully.
- The repository contains documented setup, generation, test, and run commands.

### RAHA-011 — Establish automated quality gates

**Priority:** P0  
**Owner:** Engineering  
**Dependencies:** RAHA-010

**Acceptance criteria**

- Pull requests verify formatting, regenerate code, fail on an uncommitted generated diff, run static analysis, run unit and widget tests with coverage, and build an Android debug artifact.
- Pull-request validation succeeds without production credentials or contact with the production backend.
- The Flutter version used by CI matches the version documented for local development.
- Integration tests run separately on an Android emulator on merge, release, or manual trigger.
- An iOS simulator integration job is available before public beta.
- Failed gates produce actionable output identifying the failed command or test.

### RAHA-012 — Implement theme, reusable components, and responsive shell

**Priority:** P0  
**Owner:** Design + Engineering  
**Dependencies:** RAHA-010

**Acceptance criteria**

- Semantic colors, typography, spacing, radii, and motion tokens match `design-system.md`; raw brand colors are not repeated in feature widgets.
- Reusable primary buttons, selection cards, routine cards, progress indicators, feedback options, and standard loading/error states are available.
- Text remains readable at 200% text scale without clipping critical actions.
- Interactive controls meet the agreed minimum touch target and have clear focus and semantics states.
- The application shell supports Today, Explore, Progress, and Profile while the routine player opens without bottom navigation.
- Golden tests cover representative Arabic and English states at standard and compact phone sizes.

### RAHA-013 — Implement localization and directionality

**Priority:** P0  
**Owner:** Product/Content + Engineering  
**Dependencies:** RAHA-010

**Acceptance criteria**

- All user-facing application strings come from Arabic and English localization resources.
- Selecting Arabic changes text, alignment, navigation direction, directional icons, and screen layout to RTL immediately.
- Selecting English restores the corresponding LTR behavior.
- Exercise and routine content resolves by locale and uses the approved fallback when a translation is unavailable.
- Stable IDs, analytics event names, database keys, and media filenames remain language-neutral.
- Automated tests verify both locales, retained data after language switching, and the absence of common overflow failures.

### RAHA-014 — Implement routing and startup state restoration

**Priority:** P0  
**Owner:** Engineering  
**Dependencies:** RAHA-010, RAHA-013

**Acceptance criteria**

- Routes use generated typed route objects rather than feature-owned path strings.
- Startup restores saved language, onboarding state, identity state, current content release, and any resumable routine session.
- A new user is routed to language selection; an onboarded user is routed to Today.
- Authentication and onboarding redirects are centralized and do not create redirect loops.
- Deep-linkable pages restore required identifiers without relying on transient route extras.
- Initialization failure shows a recoverable error state while the bundled starter experience remains usable when possible.

### RAHA-015 — Add analytics, crash reporting, and privacy-safe logging


**Priority:** P1  
**Owner:** Product + Engineering  
**Dependencies:** RAHA-010, RAHA-001
** Status :** Done

**Approved privacy decision:** Use the RAHA-001 telemetry privacy and consent decision dated 2026-08-28. Optional analytics and crash reporting remain disabled until their separate consents are granted.

**Acceptance criteria**

- Analytics and crash reporting are accessed through application-owned interfaces that can be disabled or replaced in tests.
- The event catalog covers onboarding completion, check-in completion, recommendation shown/accepted/rejected, routine started/completed/abandoned, feedback submitted, saved routine changes, and language changes.
- Events use stable identifiers and approved categorical properties; they do not include names, emails, free-text health notes, signed URLs, or raw provider payloads.
- Development builds allow engineers to verify event names and properties without sending them to production datasets.
- Consent and opt-out behavior matches the approved privacy decision and is enforced before optional tracking starts.
- Crash reports remove tokens, private media URLs, and sensitive user content.

## Milestone 2 — Content, Storage, and Synchronization

### RAHA-020 — Implement provider-independent content models

**Priority:** P0  
**Owner:** Engineering  
**Dependencies:** RAHA-010, RAHA-002

**Acceptance criteria**

- Domain models represent Raha exercise IDs, provider mappings, localized content, classifications, media variants, routines, ordered steps, content status, and access tier.
- A provider ID or filename is never used as the permanent exercise identity.
- One exercise can reference multiple media assets and providers while preserving saved routines and history.
- Published routines can reference only published, safety-approved exercises with at least one playable preferred media asset.
- Models validate supported durations, positive step durations or repetitions, unique step positions, and valid taxonomy keys.
- Serialization round-trip tests preserve all required fields in Arabic and English fixtures.

### RAHA-021 — Build and validate the content import pipeline

**Priority:** P0  
**Owner:** Content Engineering  
**Dependencies:** RAHA-020

**Acceptance criteria**

- The importer reads the approved source metadata and produces normalized Raha exercise, media, and routine manifests.
- Provider exercise IDs and filenames map to explicit Raha IDs; ambiguous or conflicting mappings are quarantined rather than guessed.
- Re-running an identical import is idempotent and creates no duplicate records.
- Validation reports missing translations, invalid taxonomy values, missing files, duplicate mappings, corrupt media, checksum mismatches, and missing license references.
- The Free50 subset can be used as a license-safe fixture to verify metadata and video matching, but is not automatically published as mobility content.
- Generated manifests are reproducible and are not hand-edited; source corrections are made in the authoring CSV or source system.

### RAHA-022 — Create cloud schema, migrations, and row-level security

**Priority:** P0  
**Owner:** Backend Engineering  
**Dependencies:** RAHA-001, RAHA-020

**Acceptance criteria**

- Version-controlled migrations create the identity, preference, content, check-in, recommendation, session, feedback, saved-routine, progress, and gamification structures required by the MVP.
- Foreign keys, unique constraints, check constraints, and indexes described in `database.md` are present and migration-tested.
- Anonymous or authenticated clients can read only compatible `published` content.
- A user can read and modify only their own user-owned rows; ownership checks include child records.
- Mobile clients cannot write catalog content, point ledger entries, awarded achievements, streak projections, or entitlements.
- Automated authorization tests prove that one user cannot read or change another user's records and that draft/internal provider data is not exposed.

### RAHA-023 — Implement the local Drift database

**Priority:** P0  
**Owner:** Engineering  
**Dependencies:** RAHA-020

**Acceptance criteria**

- Drift stores the content, localized taxonomy, preferences, check-ins, recommendations, sessions, feedback, saved routines, and progress projections needed for offline use.
- Locally editable rows include synchronization state and safe diagnostic metadata.
- Domain changes and their outbox operations are committed in one database transaction.
- Media bytes remain outside SQLite; the database stores only cache metadata and verified local paths.
- Forward migration tests preserve user history from every supported schema version.
- Repository tests use isolated in-memory databases and cover relationships, constraints, local-first reads, and replacement of preferred media without changing exercise identity.

### RAHA-024 — Implement atomic content releases
**Priority:** P0  
**Owner:** Backend + Mobile Engineering  
**Dependencies:** RAHA-021, RAHA-022, RAHA-023

**Acceptance criteria**

- The client requests the next content release using its current release ID and app version.
- Release IDs, checksums, relationships, tombstones, and minimum app version are validated before application.
- A release is applied in one local transaction and becomes current only after the full transaction succeeds.
- **Given** a corrupt or interrupted release, **when** application fails, **then** the previous valid catalog remains available and the failed release is not marked current.
- Retired content remains resolvable for historical sessions but is excluded from new recommendations.
- The bundled starter content is available before the first successful network synchronization.

### RAHA-025 — Implement user-data synchronization and retry

**Priority:** P0  
**Owner:** Backend + Mobile Engineering  
**Dependencies:** RAHA-022, RAHA-023

**Acceptance criteria**

- User actions are saved locally before a network request and queued using client-generated stable UUIDs.
- Queued writes are sent in dependency order and repeated identical requests are treated as success.
- Failed operations use bounded exponential backoff and expose a recoverable sync state without blocking normal local use.
- Completed sessions cannot return to `in_progress`; server-derived rewards and entitlements override local projections.
- Saved/unsaved routines use tombstones or operation timestamps so a later pull does not resurrect an unsaved routine.
- **Given** a routine completed offline, **when** connectivity returns, **then** the session, steps, feedback, and single reward result synchronize without duplication.

### RAHA-026 — Implement secure media delivery and cache management

**Priority:** P0  
**Owner:** Backend + Mobile Engineering  
**Status:** Done

**Dependencies:** RAHA-002, RAHA-020, RAHA-023

Engineering remediation is implemented and locally verified. The product owner
approved the Free50 package as a temporary, internal development and test
fixture. Purchasing the production mobility library and confirming its intended
delivery rights are deferred to the release gate in RAHA-082 and RAHA-084, so
they do not block feature development. The fixture must not be published,
included in a beta or production build, or treated as production content. See
[the RAHA-026 provider fixture decision](decisions/raha-026-provider-fixture-review.md).

**Acceptance criteria**

- The application resolves media from storage keys through a trusted service; expiring signed URLs are not persisted as exercise identity.
- The active routine is cached and the next exercise is preloaded before transition under normal network conditions.
- Cached media is validated by version and checksum; stale or corrupt files are safely replaced.
- A failed media download has retry and fallback behavior and does not corrupt an otherwise valid cached routine.
- Cache limits, eviction order, download/data preference, and available-storage failure behavior are defined and tested.
- Original purchased assets, invoices, provider license documents, and unrestricted source URLs are absent from the application repository and client logs.

## Milestone 3 — Identity, Onboarding, and Preferences

### RAHA-030 — Implement guest identity and optional account access

**Priority:** P0  
**Owner:** Engineering  
**Dependencies:** RAHA-014, RAHA-022, RAHA-023

**Acceptance criteria**

- A user can reach and use the core daily experience as a guest without providing an email address.
- Guest data uses stable local identity and remains available across normal application restarts.
- If account registration is included, upgrading a guest preserves preferences, saved routines, and completed-session history according to RAHA-001.
- Logout clears credentials and private cached state without deleting server history unless the user explicitly requests account deletion.
- Authentication loading, cancellation, invalid credentials, offline, and retry states are handled.
- User A's cached private data is not displayed after User B signs in on the same device.

### RAHA-031 — Implement language selection and onboarding

**Priority:** P0  
**Owner:** Design + Engineering  
**Dependencies:** RAHA-012, RAHA-013, RAHA-030

**Acceptance criteria**

- First launch presents Arabic and English with equal visual prominence.
- Selecting a language applies its locale and direction before the user continues.
- Onboarding contains no more than three concise pages explaining personalized choice, short routines, and comfortable habit building.
- The user can complete onboarding as a guest and is not forced to register.
- Completed onboarding is not shown again unless reset from settings or application data is cleared.
- Analytics record language selection and onboarding completion without recording sensitive data.

### RAHA-032 — Capture and persist basic preferences

**Priority:** P0  
**Owner:** Product + Engineering  
**Dependencies:** RAHA-031

**Acceptance criteria**

- The setup captures only preferences that immediately affect the experience: movement experience, permitted/preferred positions, weekly goal, reminder interest, and optional movement constraints approved for the MVP.
- Height, weight, age, diagnosis, and unrelated profile data are not required.
- Required fields are clearly identified and invalid combinations have actionable guidance.
- Preferences are available offline immediately after saving and synchronize later when an account and connectivity exist.
- Existing answers remain populated when the user goes backward or returns after an interruption.
- Preferences can later be reviewed and changed from Profile.

## Milestone 4 — Daily Check-in and Recommendations

### RAHA-040 — Build the five-step daily check-in

**Priority:** P0  
**Owner:** Design + Engineering  
**Dependencies:** RAHA-012, RAHA-023, RAHA-032

**Acceptance criteria**

- The flow asks, one question per step: body state, desired outcome, body areas, available time, and usable position.
- Supported time choices are 3, 5, 10, and 15 minutes; supported initial areas and positions match `design-and-screens.md`.
- The current step and total step count are visible without creating urgency.
- The user cannot continue without a valid answer and receives a clear, localized explanation when input is incomplete.
- Going backward preserves all prior answers; changing an earlier answer correctly affects the final recommendation request.
- Completing the final step persists one complete check-in locally and does not create duplicates if the action is retried.
- Widget tests cover each step, multi-select body areas, back navigation, restoration, Arabic RTL, English LTR, text scaling, and compact screens.

### RAHA-041 — Implement deterministic recommendation filtering and scoring

**Priority:** P0  
**Owner:** Product + Engineering  
**Dependencies:** RAHA-020, RAHA-024, RAHA-040

**Acceptance criteria**

- Incompatible position, safety, availability, access, and app-version candidates are excluded before scoring.
- Remaining candidates are scored using a versioned configuration for body area, goal, time, position, recency, preferences, and relevant prior feedback.
- The same inputs, candidate set, configuration version, and history always produce the same result and tie-break order.
- A routine does not exceed the user's selected time unless product has explicitly configured and explained a tolerance.
- A recommendation record stores the selected routine, engine/configuration version, relevant score components, and reason keys.
- Unit tests cover exact matches, partial matches, exclusions, no-candidate behavior, ties, recent-session penalty, previous discomfort, and multiple body areas.

### RAHA-042 — Present an explainable recommendation

**Priority:** P0  
**Owner:** Product/Content + Engineering  
**Dependencies:** RAHA-041, RAHA-013

**Acceptance criteria**

- The screen shows localized routine name, total duration, movement count, difficulty, position, equipment, and a prominent start action.
- “Why this routine?” is generated from localized reason keys tied to the user's actual answers and never from untranslated provider text.
- The explanation mentions only factors that influenced filtering or scoring.
- The user can open a concise movement preview without being forced to inspect every step.
- The recommendation can be started with one primary action and rejected with “Choose another.”
- Missing, expired, or unavailable content triggers a safe recomputation or clear retry state rather than a broken player.

### RAHA-043 — Support alternative and refined recommendations

**Priority:** P0  
**Owner:** Product + Engineering  
**Dependencies:** RAHA-041, RAHA-042

**Acceptance criteria**

- The user can reject a recommendation using: too easy, too difficult, cannot use this position, area feels uncomfortable, or show something else.
- A rejected routine is not immediately returned for the same check-in while another compatible candidate exists.
- Constraint-changing reasons update candidate filtering; preference reasons update scoring according to the versioned engine rules.
- If no compatible alternative exists, the user receives a calm explanation and can edit the check-in.
- Rejection reason, prior recommendation ID, new recommendation ID, and engine version are stored for analysis without recording diagnostic claims.
- Unit and controller tests prove the alternative sequence is deterministic and cannot loop indefinitely.

## Milestone 5 — Routine Playback and Completion

### RAHA-050 — Build routine preview and readiness checks

**Priority:** P0  
**Owner:** Design + Engineering  
**Dependencies:** RAHA-026, RAHA-042

**Acceptance criteria**

- Preview shows the ordered movement names and each duration or repetition count in the selected language.
- Total preview duration agrees with the routine definition and player calculation.
- The user can start without previewing, or return to the recommendation without losing the check-in.
- Unplayable or missing required media is detected before starting when possible and triggers cache repair, fallback media, or a new recommendation.
- A concise safety reminder instructs the user to move within a comfortable range and stop for sharp pain.
- If movement replacement is included in MVP, replacing one step preserves the routine's time and position constraints; otherwise the UI does not imply that replacement is supported.

### RAHA-051 — Implement the focused routine player

**Priority:** P0  
**Owner:** Engineering  
**Dependencies:** RAHA-023, RAHA-026, RAHA-050

**Acceptance criteria**

- The player loops the current demonstration and shows localized movement name, routine position, large timer or repetition count, short optional cue, and next movement.
- Pause freezes the timer and media; resume continues from the saved state without double-counting active time.
- Previous, next, and skip update the active step and persist the action according to the session model.
- The next playable media asset is preloaded while the current step is active.
- Backgrounding pauses the routine; foregrounding offers a consistent resume state.
- The screen remains awake during active playback and returns to normal device behavior after pause, completion, or exit.
- Sound and vibration transitions honor user and operating-system settings.
- Bottom navigation, advertisements, streak pressure, and unrelated actions are absent from the active player.

### RAHA-052 — Persist, abandon, and restore routine sessions

**Priority:** P0  
**Owner:** Engineering  
**Dependencies:** RAHA-025, RAHA-051

**Acceptance criteria**

- Starting a routine creates one local session with routine/content version, recommendation link when applicable, start time, and current step.
- Step transitions, pause state, active seconds, skips, and completion are saved locally as they occur.
- **Given** the app closes during a routine, **when** it starts again, **then** the user can resume from the last durable step and timer state or explicitly abandon it.
- Exiting an unfinished routine requires a clear confirmation and does not incorrectly award completion progress.
- A session is marked complete only once and only when the threshold from RAHA-001 is met.
- Duplicate finish taps, retries, restarts, and later synchronization cannot create duplicate sessions or rewards.

### RAHA-053 — Capture post-routine feedback

**Priority:** P0  
**Owner:** Product + Engineering  
**Dependencies:** RAHA-052

**Acceptance criteria**

- A completed routine asks: much better, a little better, about the same, or less comfortable.
- Feedback can be submitted once per completed session and is saved locally before synchronization.
- Selecting `less_comfortable` shows calm, safety-approved copy, suppresses an overly celebratory response, and becomes an input to later recommendations.
- The user can finish the flow according to the product decision on whether feedback is optional; the UI clearly indicates that rule.
- The completion summary displays verified active minutes and any confirmed or provisional reward state without duplicating celebrations.
- Feedback analytics contain only the categorical response and stable session/routine identifiers.

## Milestone 6 — Today, Explore, Progress, and Profile

### RAHA-060 — Build the Today screen

**Priority:** P0  
**Owner:** Design + Engineering  
**Dependencies:** RAHA-040, RAHA-052, RAHA-070

**Acceptance criteria**

- The daily check-in is the dominant action and remains easy to find at supported screen sizes and text scales.
- The screen shows a localized greeting, weekly goal progress, a recent/resumable routine when available, and one approved contextual benefit message.
- A resumable session takes precedence over starting a conflicting duplicate session.
- Progress reflects locally completed work immediately, including while offline.
- Empty/new-user, loading, offline, synchronized, and recoverable error states are designed and tested.
- Benefit messages are qualified, non-medical, and never imply that progress data is a diagnosis.

### RAHA-061 — Build Explore and routine details

**Priority:** P1  
**Owner:** Design + Engineering  
**Dependencies:** RAHA-024, RAHA-050

**Acceptance criteria**

- Explore presents guided routines rather than a raw exercise encyclopedia.
- Users can browse published routines by approved category and filter by duration, body area, position, difficulty, and equipment.
- Filters combine consistently, can be cleared, and produce an informative empty state.
- Routine details show localized purpose, duration, difficulty, position, equipment, exercise count, movement preview, save state, and start action.
- Retired, incompatible, unavailable, or unauthorized routines cannot be newly started.
- Search/filter behavior works from locally cached content while offline.

### RAHA-062 — Implement saved routines

**Priority:** P1  
**Owner:** Engineering  
**Dependencies:** RAHA-025, RAHA-061

**Acceptance criteria**

- A user can save or unsave a published routine from its details or agreed card action.
- The saved state changes immediately offline and synchronizes later.
- Repeated save actions are idempotent and do not create duplicate records.
- Saved routines are accessible from Profile or the agreed navigation location.
- If a saved routine is retired or becomes unavailable, its history remains understandable and the UI prevents invalid playback with a clear explanation.
- Save/unsave conflicts across devices follow the timestamp/tombstone rule in `database.md`.

### RAHA-063 — Build the Progress screen and history

**Priority:** P0  
**Owner:** Product + Engineering  
**Dependencies:** RAHA-052, RAHA-053, RAHA-070

**Acceptance criteria**

- Progress shows movement days, verified active minutes, completed routines, weekly goal, recent history, body areas moved, and feedback trend for the selected period.
- A movement day is counted once regardless of how many routines are completed that day.
- Date boundaries use the user's configured/local timezone for presentation and documented server rules for authoritative rewards.
- Provisional offline progress is distinguishable only when necessary and reconciles without visible double-counting after sync.
- Empty states encourage a first routine without shame, competitive comparison, or medical scoring.
- Calculations have unit tests for multiple sessions per day, week boundaries, timezone changes, skipped/abandoned sessions, and offline reconciliation.

### RAHA-064 — Build Profile, settings, and account controls

**Priority:** P1  
**Owner:** Design + Engineering  
**Dependencies:** RAHA-013, RAHA-030, RAHA-032, RAHA-062

**Acceptance criteria**

- Users can change language, weekly goal, movement preferences, sound/vibration, download preference, accessibility options, and reminder settings included in the MVP.
- Locale changes apply immediately without losing navigation state or user data.
- Profile provides access to saved routines, help/feedback, privacy terms, account state, and account deletion where applicable.
- Account deletion requires confirmation and appropriate identity verification, then initiates trusted cleanup and clears local credentials, user data, and private cache metadata.
- Settings remain available offline and synchronize when connectivity returns.
- Subscription controls are hidden or clearly marked unavailable until paid scope and entitlement behavior are implemented.

### RAHA-065 — Implement gentle reminders

**Priority:** P1  
**Owner:** Product + Engineering  
**Dependencies:** RAHA-032, RAHA-064

**Acceptance criteria**

- Reminder scheduling is opt-in and the system permission request appears only after the user expresses interest.
- Users can configure, update, pause, and disable reminders in local time.
- Copy is gentle, localized, and contains no guilt, diagnosis, or sensitive body-state information on the lock screen.
- Denied permissions produce clear instructions and do not repeatedly prompt the user.
- Timezone and daylight-saving changes preserve the intended local reminder behavior on supported platforms.
- Notification scheduling is behind a testable application interface; unit/widget tests do not require native permission dialogs.

## Milestone 7 — Gamification and Encouragement

### RAHA-070 — Implement points and weekly goals

**Priority:** P0  
**Owner:** Product + Backend + Mobile Engineering  
**Dependencies:** RAHA-001, RAHA-025, RAHA-052

**Approved policy:** [RAHA-070 points and weekly goals policy](decisions/raha-070-points-and-weekly-goals.md).

**Acceptance criteria**

- A versioned rule awards points only for behavior approved by product, such as a qualifying routine completion.
- One completion source can create at most one point-ledger award, even after retries or offline synchronization.
- Weekly goals support an approved value between one and seven movement days.
- The client may show a clearly reconcilable local projection, but the server-owned ledger is authoritative after synchronization.
- Points never reward pain tolerance, skipped safety warnings, extreme range of motion, or competition over flexibility.
- Unit and backend tests cover duplicate requests, offline completion, week boundaries, timezone handling, and rule-version changes.

### RAHA-071 — Implement streaks and recovery behavior

**Priority:** P1  
**Owner:** Product + Backend Engineering  
**Dependencies:** RAHA-070

**Acceptance criteria**

- The exact streak and optional recovery-day rules are versioned and documented in user-facing language.
- Server time and authoritative completed sessions determine awarded streak state; device clock changes cannot create rewards.
- Missing a day results in neutral, supportive copy and never describes the user as failing.
- A recovery token/day, if included, is consumed at most once for an eligible gap and remains consistent across devices.
- Streak projections reconcile after offline use without duplicate milestones.
- Boundary tests cover the first completion, consecutive days, gaps, timezone travel, delayed sync, recovery use, and rule-version migration.

### RAHA-072 — Implement achievements and a single reward summary

**Priority:** P1  
**Owner:** Product + Backend + Mobile Engineering  
**Dependencies:** RAHA-063, RAHA-070

**Acceptance criteria**

- Initial achievements have localized title, description, criteria, icon/asset, status, and versioned evaluation rule.
- Awards are server-owned, idempotent, and retain historical meaning if content is later retired.
- Completion shows at most one combined reward summary for points, weekly goal, streak, and newly earned badges.
- The `less_comfortable` feedback path uses restrained acknowledgment rather than an incongruent celebration.
- Locked badges invite exploration without showing public ranking or language that makes users feel behind.
- Tests cover simultaneous awards, already-earned badges, delayed offline sync, and localized locked/earned states.

## Milestone 8 — Hardening and Release Readiness

### RAHA-080 — Meet accessibility and bilingual visual quality gates

**Priority:** P0  
**Owner:** Design + QA + Engineering  
**Dependencies:** All P0 user-interface tasks

**Acceptance criteria**

- Every critical journey passes manual review in Arabic RTL and English LTR on at least one compact and one standard phone size.
- Primary text and controls meet WCAG AA contrast targets documented in the design system.
- Screen-reader order, names, values, and hints make the check-in, recommendation, player controls, feedback, and bottom navigation understandable without sight.
- The app remains operable at 200% text scale without hiding required actions or meaning.
- Motion respects reduced-motion settings where supported and does not rely on animation alone to communicate status.
- Color is not the sole indicator for selection, completion, error, or body-area activity.

### RAHA-081 — Verify offline, degraded-network, and recovery behavior

**Priority:** P0  
**Owner:** QA + Engineering  
**Dependencies:** RAHA-024, RAHA-025, RAHA-026, RAHA-052

**Acceptance criteria**

- A fresh installation can complete a starter routine without first downloading the full catalog.
- With cached content and no network, a user can check in, receive a compatible local recommendation, finish the routine, submit feedback, and see updated progress.
- Network loss during download, playback, completion, and synchronization does not lose locally committed progress.
- Retrying after restoration of connectivity synchronizes each logical action once.
- Low storage, corrupt cache, server timeout, expired media authorization, and incompatible content release have clear recovery behavior.
- The `offline_routine_test` integration journey passes reliably on the release-candidate build.

### RAHA-082 — Complete security and privacy review

**Priority:** P0  
**Owner:** Security/Privacy + Engineering  
**Dependencies:** RAHA-015, RAHA-022, RAHA-025, RAHA-026, RAHA-064

**Acceptance criteria**

- RLS and API authorization tests cover anonymous, authenticated owner, other user, catalog editor/service, and premium-access boundaries where applicable.
- Secrets, tokens, signed URLs, license materials, and personal data are absent from logs, analytics, crash breadcrumbs, and source control; raw provider payloads are also absent from logs and release build inputs.
- Temporary Free50 development fixtures are removed from the release branch and build inputs, or their continued private retention is covered by recorded provider permission, before beta distribution.
- Local credentials use platform-secure storage and are cleared on logout/account deletion as specified.
- Account deletion covers Supabase identity, user-owned database data, analytics deletion/anonymization, local Drift data, tokens, and private media metadata.
- Privacy and retention behavior is reviewed against the applicable Saudi and launch-market requirements before public release.
- A dependency and mobile configuration review finds no unresolved critical or high-severity issue, or each exception has an owner and approved mitigation.

### RAHA-083 — Execute end-to-end MVP acceptance

**Priority:** P0  
**Owner:** Product + QA  
**Dependencies:** All P0 tasks

**Acceptance criteria**

- Journey 1 passes: select Arabic, finish onboarding, complete a check-in, receive and understand a recommendation.
- Journey 2 passes: preview, start, pause, resume, skip/advance, complete a routine, submit feedback, and see updated progress and rewards.
- Journey 3 passes: complete the core journey offline using cached or bundled content, then synchronize once connectivity returns.
- Journey 4 passes: switch between Arabic and English and retain identity, preferences, history, and correct directionality.
- Journey 5 passes: restart during a routine, restore the session, complete or abandon it, and avoid duplicate progress.
- Product confirms that the recommendation explanation accurately reflects the check-in and that no core screen resembles an unfiltered exercise library.
- All P0 defects are closed; any accepted P1 defect has documented impact, workaround, owner, and target release.

### RAHA-084 — Prepare beta release and operational readiness

**Priority:** P1  
**Owner:** Engineering + Product  
**Dependencies:** RAHA-080, RAHA-081, RAHA-082, RAHA-083

**Acceptance criteria**

- Signed Android App Bundle and iOS archive build successfully from protected release configuration.
- Staging database migrations, content release, media authorization, analytics, and crash reporting pass smoke tests before production rollout.
- The production mobility media is purchased or otherwise licensed for the planned app, CDN, caching, and offline behavior; evidence is stored privately and only an internal reference is recorded in project data.
- Store listing, screenshots, privacy disclosures, support contact, version, release notes, and required platform declarations are complete in Arabic and English where required.
- Crash symbols and source maps are uploaded and a rollback or kill-switch plan exists for broken content releases.
- Monitoring identifies startup failures, playback failures, recommendation no-result rate, sync failures, and crash-free sessions without exposing sensitive data.
- Release approval is recorded and rollout begins through internal or staged beta distribution rather than an immediate unrestricted production launch.

## Cross-Feature Acceptance Matrix

The following matrix is a minimum regression checklist. A check mark means the concern must be explicitly verified for that feature before release.

| Feature | Arabic/RTL | Offline | Accessibility | Analytics | Security/privacy | Automated test |
|---|---:|---:|---:|---:|---:|---:|
| Language and onboarding | ✓ | ✓ | ✓ | ✓ | ✓ | Widget + integration |
| Preferences | ✓ | ✓ | ✓ | ✓ | ✓ | Unit + repository + widget |
| Daily check-in | ✓ | ✓ | ✓ | ✓ | ✓ | Unit + widget + integration |
| Recommendation | ✓ | ✓ | ✓ | ✓ | ✓ | Unit + controller + integration |
| Routine player | ✓ | ✓ | ✓ | ✓ | ✓ | Controller + widget + integration |
| Completion and feedback | ✓ | ✓ | ✓ | ✓ | ✓ | Unit + integration |
| Today | ✓ | ✓ | ✓ | ✓ | ✓ | Widget + golden |
| Explore and saved routines | ✓ | ✓ | ✓ | ✓ | ✓ | Repository + widget |
| Progress and rewards | ✓ | ✓ | ✓ | ✓ | ✓ | Unit + widget + integration |
| Profile and deletion | ✓ | Partial | ✓ | ✓ | ✓ | Repository + integration |

## Recommended Delivery Sequence

Tasks should be pulled in dependency order while design, content review, backend, and mobile work proceed in parallel where their contracts are stable.

1. **Decisions and foundations:** RAHA-001 through RAHA-015.
2. **Content and persistence:** RAHA-020 through RAHA-026.
3. **First complete prototype:** RAHA-030 through RAHA-053, then RAHA-060 and RAHA-063.
4. **MVP breadth:** RAHA-061, RAHA-062, RAHA-064, RAHA-065, and RAHA-070 through RAHA-072.
5. **Release hardening:** RAHA-080 through RAHA-084.

The first internal prototype is successful when a guest can select either language, complete the five-step check-in, understand and accept a recommendation, finish a bundled or cached routine, submit feedback, and see progress update without a network connection.

## MVP Exit Criteria

The MVP is ready for beta only when:

- All P0 tasks are `Done` and the global definition of done is satisfied.
- The five end-to-end journeys in RAHA-083 pass on the supported release configurations.
- At least one approved, license-safe routine exists for every check-in combination the product promises to support, or unsupported combinations have an intentional fallback.
- No open defect can cause data loss, cross-user disclosure, incorrect rewards, unusable RTL layout, unsafe content playback, or an unrecoverable startup/player failure.
- Recommendation, start, completion, alternative-request, feedback, repeat-use, and weekly-consistency events can be measured.
- Product, design, content/safety, privacy/security, and engineering owners have approved the release candidate.

## Post-MVP Backlog

Create separate, newly estimated tasks after MVP evidence supports them:

- Body-area journey and richer weekly recaps.
- Personalized challenges and adaptive difficulty.
- Subscription purchase, restore, and entitlement flows.
- Activity-specific gym and sports warm-ups.
- Additional providers, media variants, and premium catalog expansion.
- Optional family or social challenges.
- Broader device, operating-system, and accessibility coverage.

These items must reuse the provider-independent content model, routine player, progress model, localization system, and privacy boundaries rather than introducing parallel implementations.
