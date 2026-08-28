# Raha Move Project Structure

Related documents:

- [product-brief.md](product-brief.md) covers the product vision, audience, content, gamification, and roadmap.
- [design-and-screens.md](design-and-screens.md) covers the design direction, screen specifications, and essential prototype.
- [design-system.md](design-system.md) defines the color palette, typography, and visual tokens.

## Overview

Raha Move is a beginner-friendly, Arabic-first or bilingual stretching and mobility app. It recommends short routines based on how the user feels, their goal, target body areas, available time, and movement constraints.

The Flutter application will use a feature-first, layered architecture with Riverpod. The architecture should remain practical for an MVP while supporting future additions such as warm-ups, multiple footage providers, subscriptions, and more advanced personalization.

## Technology Direction

- Flutter for iOS and Android
- Flutter Riverpod for state management and dependency injection
- `riverpod_annotation` and `riverpod_generator` for generated providers and notifiers
- `riverpod_lint` for Riverpod-specific analysis, quick fixes, and refactoring assists
- `custom_lint` with `freezed_lint` for generated-model checks
- GoRouter with `go_router_builder` for generated, strongly typed routes
- Freezed for immutable models and unions
- `json_serializable` for JSON serialization
- Drift for structured local storage and offline access
- FlutterGen for type-safe assets, fonts, and colors
- Supabase for authentication, relational backend data, and synchronization
- Object storage and CDN delivery for exercise videos
- RevenueCat for subscriptions
- Firebase Cloud Messaging for push notifications
- PostHog for product analytics and primary error/crash reporting, accessed
  through application-owned interfaces that can be disabled or replaced in
  tests
- Privacy-safe application logging with allowlisted structured fields and
  centralized redaction before logs, breadcrumbs, or crash context leave the
  device
- PostHog native C/C++ crash capture on Android requires API 31 or newer; the
  release review must verify the accepted coverage for supported API 24–30
  devices before relying on PostHog as the only production crash reporter
- Flutter `gen_l10n` for Arabic and English localization

Package versions should be selected and pinned when the Flutter project is initialized.

## Architectural Direction

The application is organized by feature. Each substantial feature may contain four layers:

```text
Presentation -> Application -> Domain <- Data
```

- **Presentation:** Flutter screens, widgets, dialogs, and visual states.
- **Application:** Riverpod controllers, orchestration, and user actions.
- **Domain:** Business models, contracts, recommendation rules, and product terminology.
- **Data:** Repository implementations and connections to Drift, Supabase, media storage, analytics, and third-party services.

The domain layer must not depend on Flutter widgets, Supabase, Drift, RevenueCat, or a particular video provider.

## Proposed Directory Structure

```text
Raha_move_app/
├── assets/
│   ├── animations/
│   ├── fonts/
│   ├── icons/
│   ├── images/
│   └── starter_content/
│
├── lib/
│   ├── app/
│   │   ├── app.dart
│   │   ├── bootstrap.dart
│   │   ├── localization/
│   │   ├── router/
│   │   │   ├── app_router.dart
│   │   │   ├── app_routes.dart
│   │   │   └── app_routes.g.dart
│   │   └── theme/
│   │
│   ├── core/
│   │   ├── analytics/
│   │   ├── crash_reporting/
│   │   ├── constants/
│   │   ├── database/
│   │   ├── errors/
│   │   ├── extensions/
│   │   ├── logging/
│   │   ├── networking/
│   │   ├── storage/
│   │   ├── utilities/
│   │   └── widgets/
│   │
│   ├── features/
│   │   ├── authentication/
│   │   ├── onboarding/
│   │   ├── check_in/
│   │   ├── recommendations/
│   │   ├── exercise_library/
│   │   ├── routine_player/
│   │   ├── progress/
│   │   ├── gamification/
│   │   ├── profile/
│   │   └── subscriptions/
│   │
│   └── main.dart
│
├── test/
│   ├── core/
│   ├── features/
│   ├── fixtures/
│   └── helpers/
│
├── integration_test/
├── project-structure.md
└── pubspec.yaml
```

Only create directories when they are needed. Empty architectural folders should not be added merely to reproduce this tree.

## Feature Structure

A substantial feature follows this structure:

```text
features/
└── routine_player/
    ├── domain/
    │   ├── routine.dart
    │   ├── routine_step.dart
    │   ├── routine_session.dart
    │   └── routine_repository.dart
    │
    ├── application/
    │   ├── routine_player_controller.dart
    │   ├── routine_player_state.dart
    │   └── routine_player_providers.dart
    │
    ├── data/
    │   ├── drift_routine_repository.dart
    │   ├── routine_local_data_source.dart
    │   ├── routine_remote_data_source.dart
    │   └── routine_media_service.dart
    │
    └── presentation/
        ├── routine_player_screen.dart
        └── widgets/
            ├── exercise_video.dart
            ├── routine_timer.dart
            └── player_controls.dart
```

Small features do not need every layer. A layer or abstraction should be introduced only when it separates meaningful responsibilities.

## Initial Feature Boundaries

### Authentication

- Guest sessions
- Registered accounts
- Authentication state
- Account restoration and logout

### Onboarding

- Language selection
- Beginner experience setup
- Movement preferences
- Goals and notification preferences

### Check-in

- How the user's body feels
- Desired outcome for today
- Target body areas
- Available time
- Seated, standing, or floor preference

### Recommendations

- Candidate routine filtering
- Rules-based scoring
- Recommendation explanation
- Alternative recommendation requests

### Exercise library

- Provider-independent exercise records
- Arabic and English content
- Exercise classifications
- Multiple media providers
- Content availability and access level

### Routine player

- Looping exercise video
- Routine sequence
- Timer or repetitions
- Pause, skip, previous, and next actions
- Preloading and caching
- Session completion

### Progress

- Completed sessions
- Minutes moved
- Before-and-after feedback
- Weekly summaries
- Body-area activity history

### Gamification

- Points
- Flexible streaks
- Weekly goals
- Achievements and badges
- Encouraging benefit messages

Gamification rewards consistency and safe participation rather than extreme flexibility or pain tolerance.

### Profile

- Language
- Accessibility
- Movement preferences
- Reminder settings
- Account settings

### Subscriptions

- Entitlements
- Free and premium content
- Purchase and restore flows
- Subscription state

### Future warm-ups

Warm-ups may become a separate feature for gym sessions, football, running, padel, cycling, and other activities. It should reuse the exercise library, routine player, progress, and media architecture.

## Core Content Model

The following concepts remain separate:

```text
Exercise
  Describes one movement.

Routine
  Contains an ordered collection of routine steps.

Routine step
  Defines how an exercise is performed inside one routine.

Media asset
  Demonstrates an exercise and records the footage provider.

Routine session
  Records a user's completed or interrupted attempt.
```

An exercise must never use a provider filename as its permanent identity.

```text
Exercise: raha_ex_000051
├── Vital Animations media: 0051.mp4
└── Alternative provider media: chest_fly_104.mp4
```

This allows footage to be replaced without breaking routines, favorites, analytics, or completion history.

## Provider-Independent Exercise JSON

Provider files are imported source data. The app consumes normalized Raha Move records.

```json
{
  "id": "raha_ex_000051",
  "sourceExerciseId": "0051",
  "source": {
    "provider": "vital_animations",
    "licenseType": "commercial",
    "licenseReference": "vital_animations_complete_collection",
    "attributionRequired": false
  },
  "content": {
    "name": {
      "en": "Pec Deck Machine Fly",
      "ar": "تفتيح الصدر على الجهاز"
    },
    "description": {
      "en": "A machine-based chest exercise.",
      "ar": "تمرين للصدر باستخدام الجهاز."
    }
  },
  "classification": {
    "category": "strength",
    "bodyParts": ["chest"],
    "targetMuscles": ["chest"],
    "secondaryMuscles": ["shoulders"],
    "equipment": ["machine"],
    "difficulty": "beginner"
  },
  "media": [
    {
      "id": "media_000051_vital",
      "provider": "vital_animations",
      "type": "video",
      "file": "0051.mp4",
      "width": 1080,
      "height": 1080,
      "preferred": true
    }
  ],
  "raha": {
    "contexts": ["gym_warmup"],
    "positions": ["seated"],
    "goals": ["movement_preparation"],
    "freeAccess": false,
    "points": 5,
    "status": "draft"
  }
}
```

Provider and license metadata should also be stored in a separate provider registry. That registry can record purchase details, license documents, allowed platforms, attribution requirements, and internal notes.

## Recommendation Engine

The MVP uses a transparent rules-based recommendation engine rather than AI.

Inputs may include:

- Check-in answers
- Body areas
- Desired outcome
- Available time
- Required movement position
- User preferences
- Routine difficulty
- Recent sessions
- Previous user feedback

The engine returns both the selected routine and the reasons for its selection.

```dart
abstract interface class RoutineRecommendationEngine {
  Recommendation recommend({
    required CheckInAnswers checkIn,
    required List<Routine> candidates,
    required UserPreferences preferences,
    required List<RoutineSession> recentSessions,
  });
}
```

An initial weighted approach could include:

```text
Body-area match       +40
Desired-goal match    +25
Available-time match  +20
Position match        +15
Recently completed    -10
Incompatible option   Exclude
```

The exact weights are product configuration and should be tested rather than embedded throughout UI code.

## Repository Boundaries

The application and domain layers should depend on repository contracts rather than Supabase or Drift directly.

```dart
abstract interface class RoutineRepository {
  Future<Routine?> findById(String id);

  Future<List<Routine>> findMatching(
    RoutineCriteria criteria,
  );

  Stream<List<Routine>> watchSavedRoutines();
}
```

A repository implementation may combine local and remote sources. Avoid creating a repository for a trivial value when a simple service or provider is enough.

## Offline-First Data Flow

1. Read exercises, routines, and user progress from Drift.
2. Synchronize updated content and account data from Supabase.
3. Select a recommendation from locally available normalized data.
4. Stream or download the selected routine's media.
5. Preload the next exercise before the current step ends.
6. Save session progress locally immediately.
7. Synchronize progress when connectivity is available.

A small starter routine may be bundled so the first experience does not depend on a completed network download.

## Video Strategy

- Do not bundle the complete purchased library in the application binary.
- Preserve original purchased files separately.
- Deliver mobile-optimized versions from object storage through a CDN.
- Cache the active routine locally.
- Preload the next exercise.
- Keep media URLs separate from exercise identity.
- Support multiple media records for the same exercise.
- Use signed URLs if required by a provider's license.
- Normalize resolution and compression during the content-processing workflow.

## Riverpod Guidelines

- Use `Provider` for stable services and repositories.
- Use generated `Notifier` classes for editable synchronous state.
- Use generated `AsyncNotifier` classes for asynchronous workflows.
- Use `FutureProvider` for simple read-only asynchronous queries.
- Use `StreamProvider` for authentication or local database streams.
- Use provider families for records selected by ID.
- Keep state within its feature rather than creating one global application controller.
- Screens observe controller state and forward user actions; they do not query Supabase directly.

## Code Generation

Code generation is a core project choice. It should remove predictable infrastructure boilerplate while leaving product behavior explicit.

Use generation for:

- Strongly typed GoRouter routes
- Freezed immutable models and unions
- JSON serialization
- Riverpod providers and controllers
- Drift tables and queries
- Type-safe asset references
- Arabic and English localization accessors
- Test mocks only when useful

### Recommended package set

The project should use this generation and linting set:

| Runtime dependency | Development dependency | Purpose |
|---|---|---|
| `flutter_riverpod` | — | Riverpod integration for Flutter widgets |
| `riverpod_annotation` | `riverpod_generator` | Generated providers, families, notifiers, and async notifiers |
| — | `riverpod_lint` | Riverpod diagnostics, quick fixes, and refactoring assists |
| — | `custom_lint` | Host for compatible custom analysis plugins |
| `freezed_annotation` | `freezed` | Immutable data classes, unions, equality, and `copyWith` |
| `json_annotation` | `json_serializable` | Generated `fromJson` and `toJson` methods |
| `go_router` | `go_router_builder` | Generated strongly typed navigation |
| `drift` | `drift_dev` | Typed local database tables and queries |
| — | `flutter_gen_runner` | Type-safe references for assets, fonts, and colors |
| — | `freezed_lint` | Freezed-specific model checks through `custom_lint` |
| — | `build_runner` | Runs compatible source generators together |

Flutter's built-in `gen_l10n` remains responsible for generated Arabic and English localization accessors. It does not require replacing the localization workflow with another generator.

The following packages should not be added initially because their responsibilities overlap with the selected stack:

- `injectable` or `get_it`: Riverpod already provides dependency injection and lifecycle management.
- `auto_route`: GoRouter and `go_router_builder` already own navigation.
- `dart_mappable` or `built_value`: Freezed and `json_serializable` already own models and serialization.
- A generated REST client: Supabase is the planned backend client. Add a REST generator only if Raha Move later integrates a substantial external REST API.
- Generated mocks for every dependency: prefer lightweight fakes and provider overrides; generate mocks only where they provide real value.

### Initial dependency template

Use this as the dependency shape when the Flutter project is created. Resolve and pin mutually compatible stable versions at that time.

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod:
  riverpod_annotation:
  go_router:
  freezed_annotation:
  json_annotation:
  drift:

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  build_runner:
  riverpod_generator:
  riverpod_lint:
  custom_lint:
  freezed:
  freezed_lint:
  json_serializable:
  go_router_builder:
  drift_dev:
  flutter_gen_runner:
  mocktail:
```

`flutter_gen_runner` currently requires a sufficiently recent `build_runner`, so the package solver and Flutter SDK constraints must be checked together during initialization.

### Riverpod generation convention

Generated Riverpod syntax is the default for application state and dependencies.

Use a functional provider for a simple computed value or service:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routine_repository_provider.g.dart';

@riverpod
RoutineRepository routineRepository(Ref ref) {
  return DefaultRoutineRepository(
    local: ref.watch(routineLocalDataSourceProvider),
    remote: ref.watch(routineRemoteDataSourceProvider),
  );
}
```

Use a generated notifier for user-editable or workflow state:

```dart
part 'daily_check_in_controller.g.dart';

@riverpod
class DailyCheckInController extends _$DailyCheckInController {
  @override
  CheckInAnswers build() => const CheckInAnswers.initial();

  void selectBodyArea(BodyArea area) {
    state = state.copyWith(
      bodyAreas: {...state.bodyAreas, area},
    );
  }
}
```

Use an `AsyncNotifier`-style generated controller when `build` or an action is asynchronous. Avoid handwritten provider declarations unless generation does not support a legitimate use case or a handwritten declaration is materially clearer.

Riverpod families are generated from normal function or `build` parameters, reducing the need to declare `.family` manually.

### Analysis configuration

Modern `riverpod_lint` uses Dart's analysis-server plugin system and is not hosted by `custom_lint`. Configure it in `analysis_options.yaml` using the version resolved for the project:

```yaml
include: package:flutter_lints/flutter.yaml

plugins:
  riverpod_lint: <resolved-version>

analyzer:
  plugins:
    - custom_lint
```

`custom_lint` remains in the project for `freezed_lint` and any future compatible project-specific lint rules. Do not add `riverpod_lint` under `analyzer.plugins` when using its modern analysis-server-plugin release.

Run all standard and plugin diagnostics with:

```shell
dart analyze
```

### Boilerplate-reduction policy

Use generation when it produces code that is deterministic, repetitive, and easy to regenerate:

- Provider declarations and typed provider parameters
- Immutable state classes
- JSON conversion
- Database tables and queries
- Route paths and navigation helpers
- Asset, font, and color references
- Localization accessors

Do not stack multiple packages that generate the same responsibility. One source definition should own each concept:

```text
@riverpod definition       -> provider code
@freezed model             -> immutable model code
fromJson factory           -> JSON conversion code
GoRouteData class          -> navigation code
Drift table                -> database code
pubspec asset declaration  -> asset reference code
ARB localization entry     -> localized accessor code
```

This reduces handwritten boilerplate without hiding Raha Move's recommendation, routine, progress, or gamification behavior.

Do not generate:

- Widgets and screens
- Recommendation rules
- Gamification calculations
- Subscription decisions
- Safety behavior
- Simple abstractions that are clearer as ordinary Dart

Generated files such as `.g.dart` and `.freezed.dart` must not be edited manually.

Run all `build_runner` generators once with:

```shell
dart run build_runner build --delete-conflicting-outputs
```

Keep generation active during development with:

```shell
dart run build_runner watch --delete-conflicting-outputs
```

Flutter localization generation is managed by Flutter's localization tooling rather than `build_runner`.

Generated files should be committed so local development, builds, and code review are predictable. Continuous integration should regenerate code and fail when generated output is outdated.

## Routing Guidelines

- Define routes using `GoRouteData` and `go_router_builder`.
- Navigate with typed route objects instead of handwritten path strings.
- Put deep-linkable identifiers in path or query parameters.
- Avoid `$extra` for information that must survive deep links or application restarts.
- Keep authentication and onboarding redirection in centralized routing logic.
- Use a stateful shell route if the final navigation uses persistent bottom tabs.

Example:

```dart
const RoutineRoute(
  routineId: 'desk_neck_5',
  autoplay: true,
).push(context);
```

## Localization and RTL

- Arabic and English are first-class languages.
- All user-facing text comes from localization resources.
- UI layouts must be tested in both left-to-right and right-to-left modes.
- Do not encode direction into reusable spacing or alignment components.
- Provider text should be imported into Raha Move's localized content model rather than displayed directly.
- Exercise and routine identifiers remain language-neutral.

## Testing Strategy

Raha Move should have many fast unit and widget tests, supported by a smaller set of high-value integration tests. Tests should focus on product behavior and stable boundaries rather than implementation details.

### Testing stack

| Tool | Role |
|---|---|
| `flutter_test` | Unit tests, widget tests, matchers, and built-in golden-file support |
| `integration_test` | Full Flutter journeys on an emulator or physical device |
| `mocktail` | Lightweight mocks without additional generated mock files |
| Riverpod `ProviderContainer` and overrides | Provider, controller, repository, and state-transition tests |
| Drift in-memory database | Repository, query, migration, and offline-behavior tests |
| Free50 and authored JSON fixtures | Content import, normalization, and media-matching tests |
| Flutter coverage output | Coverage reporting and trend visibility |
| Patrol, deferred | Native permission dialogs, notifications, purchases, and platform interactions if required |

Prefer small hand-written fakes for domain repositories and clocks. Use Mocktail when interaction verification is genuinely useful. Avoid generating mocks for every class because that adds boilerplate without improving confidence.

### Test directory structure

```text
test/
├── app/
│   ├── localization/
│   ├── router/
│   └── theme/
├── core/
│   ├── database/
│   ├── storage/
│   └── utilities/
├── features/
│   ├── check_in/
│   ├── recommendations/
│   ├── exercise_library/
│   ├── routine_player/
│   ├── progress/
│   └── gamification/
├── fixtures/
│   ├── exercises/
│   ├── routines/
│   └── providers/
├── goldens/
├── helpers/
│   ├── app_test_harness.dart
│   ├── fake_clock.dart
│   ├── provider_overrides.dart
│   └── test_database.dart
└── test_bootstrap.dart

integration_test/
├── onboarding_to_recommendation_test.dart
├── routine_completion_test.dart
├── offline_routine_test.dart
└── language_direction_test.dart
```

Test files should mirror the feature structure and use the `_test.dart` suffix.

### Unit tests

Unit tests cover deterministic domain and application behavior:

- Recommendation filtering, scoring, ranking, and tie-breaking
- Recommendation explanations
- Incompatible routine exclusions
- Duration and body-area matching
- Streak rules and recovery days
- Points, weekly goals, and badge awards
- Before-and-after feedback calculations
- Exercise-provider normalization
- Multiple-media-provider selection
- Routine duration and step calculations
- Content-access and entitlement rules
- Arabic and English content fallback behavior

Time-dependent logic must receive an injectable clock. Tests should never rely on the actual current time or local timezone.

### Riverpod tests

Test generated providers and controllers through a `ProviderContainer` with overrides:

- Override repositories with small fakes.
- Observe emitted `AsyncValue` and state transitions.
- Verify loading, data, empty, retry, and error states.
- Dispose every container after a test.
- Test provider parameters using stable value objects.
- Avoid reaching into generated implementation details.

The key controller scenarios include:

- Building and editing daily check-in answers
- Requesting and rejecting a recommendation
- Starting, pausing, resuming, skipping, and completing a routine
- Saving progress offline
- Synchronizing a pending session later
- Awarding points exactly once after completion

### Data and repository tests

Use an isolated in-memory Drift database for each test group where possible.

Cover:

- Inserts, updates, reads, deletes, and relationships
- Exercise, routine, media, and provider mappings
- Local-first reads and remote synchronization decisions
- Conflict and retry behavior
- Pending upload queues
- Database migrations and preserved user history
- Replacing preferred footage without changing the Raha exercise ID

Supabase behavior should be tested behind Raha Move repository and service boundaries. Unit and widget tests must not contact the production backend.

### Content importer tests

Use a small, version-controlled subset of the Free50 metadata as test fixtures. Do not duplicate all purchased or licensed media inside the test suite.

Importer tests should confirm:

- Each provider ID maps to the intended Raha ID.
- Video filenames match source records.
- Unknown provider fields are handled safely.
- Required fields produce clear validation errors when absent.
- Multiple providers can attach media to one exercise.
- Reimporting is idempotent and does not duplicate records.
- Arabic content can be added without modifying source-provider data.
- Provider and license provenance remains attached to imported media.

The Free50 sample primarily contains gym exercises, but it is suitable for testing the importer and media pipeline until the mobility library is purchased.

### Widget tests

Widget tests should cover behavior, layout states, and localization for:

- Language selection
- Today screen
- Each check-in step
- Recommendation and alternative recommendation states
- Routine preview
- Routine-player controls and transitions
- Completion feedback
- Progress and achievements
- Empty, loading, offline, and error states

Every critical screen must be tested in both Arabic RTL and English LTR. Test text scaling and at least one compact phone size. Important controls should be located by stable keys or semantics rather than fragile text-only finders.

Plugin-dependent behavior such as video playback, notifications, analytics, purchases, and secure storage must sit behind Raha Move interfaces. Widget tests replace those interfaces with fakes to avoid platform-channel failures.

### Golden tests

Use Flutter's built-in golden testing initially instead of adding another visual-testing framework.

Golden tests are appropriate for a small set of stable, important states:

- Today screen in Arabic and English
- Check-in body-area selection
- Recommendation card
- Routine player
- Completion state
- Progress summary

Golden tests must use deterministic fonts, fixed dates, fixed locale, fixed device size, and controlled animations. Do not create a golden for every widget. Review golden changes visually before accepting them.

### Integration tests

The initial integration suite should cover complete product journeys:

1. Select Arabic, finish onboarding, complete a check-in, and receive a recommendation.
2. Start a routine, move between steps, complete it, submit feedback, and verify progress.
3. Launch with cached content while offline and complete a routine.
4. Switch between Arabic and English and verify directionality and retained data.
5. Restore an existing local session after restarting the app.

Use Flutter's SDK-provided `integration_test` package first. Add Patrol only when native UI automation becomes necessary for flows such as notification permission dialogs, system settings, deep links, or real purchase sheets.

### Coverage policy

Coverage is a signal, not the definition of quality.

- Collect coverage for unit and widget tests in CI.
- Track coverage trends and prevent large unexplained drops.
- Set thresholds only after the initial architecture stabilizes.
- Prioritize full branch coverage for recommendation, gamification, synchronization, and entitlement rules.
- Do not write meaningless tests solely to increase a percentage.

Generate coverage with:

```shell
flutter test --coverage
```

## Continuous Integration

GitHub Actions is the suggested initial CI service. The pipeline should remain portable so it can later move to Codemagic, Bitrise, or another Flutter-oriented service if release automation requires it.

### Pull-request quality pipeline

Every pull request should run these gates:

1. Check out the repository.
2. Install the pinned Flutter SDK.
3. Restore the Dart and Flutter package cache.
4. Run `flutter pub get`.
5. Verify formatting.
6. Run code generation.
7. Fail if generated committed files are outdated.
8. Run Dart and plugin analysis.
9. Run unit and widget tests with coverage.
10. Build an Android debug artifact to catch compilation and manifest issues.

Suggested commands:

```shell
dart format --output=none --set-exit-if-changed .
dart run build_runner build --delete-conflicting-outputs
git diff --exit-code
dart analyze
flutter test --coverage
flutter build apk --debug
```

The CI environment must use the same Flutter version as local development. Pin that version rather than using an unbounded latest release.

### Integration pipeline

Run emulator-based integration tests separately from the fast pull-request job because they are slower and more failure-prone.

Recommended triggers:

- On merges to the main branch
- Before a beta or production release
- Manually when changing native plugins, routing, local storage, or playback

Initially run the essential flow on one Android emulator. Add an iOS simulator job on macOS before public beta. Expand device coverage based on supported operating-system versions and actual user analytics.

### Generated-code gate

Generated code is committed. CI regenerates it and then runs:

```shell
git diff --exit-code
```

This catches stale route, provider, Freezed, JSON, Drift, and asset output. The build should fail with a clear message telling the developer to run the standard generation command locally.

### CI job structure

```text
quality
├── format
├── generate and verify clean diff
├── analyze
└── unit and widget tests with coverage

android-build
└── debug APK compilation

integration-android
└── essential journey on emulator

integration-ios
└── essential journey on simulator before beta/release
```

Formatting, generation, analysis, and fast tests may run in one job to reuse setup and caching. Android and iOS jobs remain separate because their environments differ.

### CI secrets and environments

- Pull-request tests should work without production secrets.
- Use fake services or a local/test backend for ordinary tests.
- Store signing keys, Supabase test credentials, analytics tokens, and store credentials in protected CI secrets.
- Do not expose secrets to untrusted forked pull requests.
- Keep development, staging, and production configuration separate.
- Never run destructive database tests against production.

### Release automation, later

When the MVP approaches beta, extend CI/CD with:

- Signed Android App Bundle builds
- Signed iOS archive builds
- TestFlight and Google Play internal-track uploads
- Release notes and version validation
- Database migration checks
- Crash-symbol upload
- Staged environment smoke tests

Release deployment should require protected-environment approval until the process is proven reliable.

## Engineering Principles

1. Prefer feature ownership over folders organized only by technical type.
2. Keep domain behavior independent of Flutter and infrastructure providers.
3. Treat footage-provider JSON as import data, not the app's permanent schema.
4. Keep stable Raha Move IDs independent of provider IDs and filenames.
5. Build offline-friendly routine playback and progress recording.
6. Generate repetitive infrastructure code, but handwrite important product rules.
7. Add abstractions only where they isolate real complexity.
8. Design Arabic and RTL support from the first screen.
9. Keep the MVP rules-based, explainable, and measurable.
10. Allow future warm-up and activity-preparation features to reuse existing content and playback foundations.
