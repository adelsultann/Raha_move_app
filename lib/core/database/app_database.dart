import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Synchronization state for data the user may edit while offline.
enum SyncState { synced, pendingCreate, pendingUpdate, pendingDelete, failed }

/// Allowlisted diagnostics only. Never store responses, URLs, tokens, or notes.
enum SyncDiagnosticCode {
  networkUnavailable,
  validationRejected,
  retryExhausted,
  unmappedId,
  unsupportedOperation,
}

/// Lifecycle of a durable outbox row. `pending` rows are eligible for an
/// automatic push; `rejected` rows are parked for explicit, recoverable retry
/// and are never deleted automatically.
enum OutboxStatus { pending, rejected }

/// Remote-identity mapping kinds resolved from the content-release manifest.
/// `routine`/`exercise` map a stable Raha public id to its server UUID;
/// `taxonomy` maps a stable taxonomy key (goal/position/…) to its server UUID.
abstract final class RemoteIdMappingKind {
  static const routine = 'routine';
  static const exercise = 'exercise';
  static const taxonomy = 'taxonomy';
}

/// The wire operation kinds accepted by `sync_push_user_data`. These are the
/// authoritative RAHA-025 field lists; no other kind is sent to the backend.
abstract final class WireOperationKind {
  static const checkInUpsert = 'check_in_upsert';
  static const recommendationUpsert = 'recommendation_upsert';
  static const sessionStart = 'session_start';
  static const sessionStepUpsert = 'session_step_upsert';
  static const sessionFinalize = 'session_finalize';
  static const feedbackUpsert = 'feedback_upsert';
  static const savedRoutineSet = 'saved_routine_set';
}

/// A stable UUIDv4 generator used for client-generated operation ids.
final _secureRandom = Random.secure();

/// Generates a random RFC 4122 version-4 UUID string. Used for durable,
/// client-generated operation ids that must survive retries.
String generateUuidV4() {
  final bytes = List<int>.generate(16, (_) => _secureRandom.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10xx
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}

/// Whether [value] is already a well-formed UUID. Locally client-generated ids
/// (check-in, recommendation, session) and server-issued `routine_step_id`
/// values are UUIDs; a value passing this check is sent to the backend as-is
/// rather than being treated as a taxonomy key or public id to resolve.
final RegExp _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

/// Common, privacy-safe metadata for locally editable records.
mixin SyncColumns on Table {
  TextColumn get syncState =>
      textEnum<SyncState>().withDefault(const Constant('pendingCreate'))();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();

  /// A stable error code only; never persist raw server responses.
  TextColumn get lastSyncError => textEnum<SyncDiagnosticCode>().nullable()();
}

/// Schema v1. Retained permanently because early app installations used it.
class EnvironmentEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class LocalTaxonomies extends Table {
  TextColumn get key => text()();
  TextColumn get kind => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class LocalTaxonomyTranslations extends Table {
  TextColumn get taxonomyKey => text().references(LocalTaxonomies, #key)();
  TextColumn get locale => text()();
  TextColumn get label => text()();

  @override
  Set<Column<Object>> get primaryKey => {taxonomyKey, locale};

  @override
  List<String> get customConstraints => ["CHECK (locale IN ('ar', 'en'))"];
}

class LocalExercises extends Table {
  TextColumn get id => text()();
  TextColumn get status => text()();
  TextColumn get accessTier => text()();
  TextColumn get difficulty => text()();
  BoolColumn get safetyApproved => boolean()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalExerciseTranslations extends Table {
  TextColumn get exerciseId => text().references(LocalExercises, #id)();
  TextColumn get locale => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get shortCue => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {exerciseId, locale};

  @override
  List<String> get customConstraints => ["CHECK (locale IN ('ar', 'en'))"];
}

class LocalMediaAssets extends Table {
  TextColumn get id => text()();
  TextColumn get exerciseId => text().references(LocalExercises, #id)();
  TextColumn get mediaType => text()();

  /// A stable, opaque, provider-neutral delivery reference from the RAHA-024
  /// content-release contract (a server-issued UUID). It is never an expiring
  /// or signed URL and never a local path; the trusted media service resolves
  /// it to a downloadable asset. The column was named `storage_key` before
  /// schema v4.
  TextColumn get deliveryReference => text()();
  TextColumn get mimeType => text()();
  TextColumn get checksumSha256 => text()();
  TextColumn get status => text()();
  BoolColumn get isPreferred => boolean().withDefault(const Constant(false))();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get durationMs => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (delivery_reference NOT LIKE '%://%' AND delivery_reference NOT LIKE '/%' AND delivery_reference NOT LIKE '%?%' AND delivery_reference NOT LIKE '%#%')",
  ];
}

/// File index only. Media bytes are always managed by the device cache.
class LocalMediaCacheEntries extends Table {
  /// Supabase authenticated or anonymous user id that authorized these bytes.
  /// Cache metadata is never shared across accounts.
  TextColumn get ownerId => text()();
  TextColumn get mediaId => text().references(LocalMediaAssets, #id)();
  TextColumn get verifiedLocalPath => text()();

  /// Content-release version recorded when this file was verified. An empty
  /// legacy value is deliberately treated as stale rather than playable.
  TextColumn get mediaVersion => text()();
  TextColumn get checksumSha256 => text()();
  TextColumn get requiredEntitlement => text().nullable()();
  IntColumn get byteSize => integer()();
  TextColumn get cacheState => text()();
  DateTimeColumn get lastAccessedAt => dateTime()();
  DateTimeColumn get verifiedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, mediaId};

  @override
  List<String> get customConstraints => ['CHECK (byte_size >= 0)'];
}

class LocalExerciseTaxonomies extends Table {
  TextColumn get exerciseId => text().references(LocalExercises, #id)();
  TextColumn get taxonomyKey => text().references(LocalTaxonomies, #key)();
  RealColumn get relevanceWeight => real().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {exerciseId, taxonomyKey};
}

class LocalRoutines extends Table {
  TextColumn get id => text()();
  TextColumn get status => text()();
  TextColumn get accessTier => text()();
  TextColumn get difficulty => text()();
  IntColumn get estimatedDurationSeconds => integer()();
  IntColumn get version => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (estimated_duration_seconds > 0)',
    'CHECK (version > 0)',
  ];
}

class LocalRoutineTranslations extends Table {
  TextColumn get routineId => text().references(LocalRoutines, #id)();
  TextColumn get locale => text()();
  TextColumn get name => text()();
  TextColumn get summary => text()();

  @override
  Set<Column<Object>> get primaryKey => {routineId, locale};

  @override
  List<String> get customConstraints => ["CHECK (locale IN ('ar', 'en'))"];
}

class LocalRoutineSteps extends Table {
  TextColumn get id => text()();
  TextColumn get routineId => text().references(LocalRoutines, #id)();
  TextColumn get exerciseId => text().references(LocalExercises, #id)();
  IntColumn get position => integer()();
  IntColumn get durationSeconds => integer()();
  IntColumn get restAfterSeconds => integer().withDefault(const Constant(0))();
  BoolColumn get isOptional => boolean().withDefault(const Constant(false))();

  /// `published` or `retired`. Retired steps are preserved for historical
  /// sessions but excluded from the current routine definition.
  TextColumn get status => text().withDefault(const Constant('published'))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {routineId, position},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (position > 0)',
    'CHECK (duration_seconds > 0)',
    'CHECK (rest_after_seconds >= 0)',
    "CHECK (status IN ('published', 'retired'))",
  ];
}

class LocalRoutineTaxonomies extends Table {
  TextColumn get routineId => text().references(LocalRoutines, #id)();
  TextColumn get taxonomyKey => text().references(LocalTaxonomies, #key)();
  RealColumn get relevanceWeight => real().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {routineId, taxonomyKey};
}

class LocalContentReleases extends Table {
  /// Monotonic release cursor. Server releases use their bigint id as text;
  /// the bundled starter bootstrap uses `'0'` so any server release is "after" it.
  TextColumn get id => text()();

  /// Human-readable release label supplied by the server (`version`).
  TextColumn get version => text()();

  /// The manifest contract version that was applied (`contract_version`).
  TextColumn get contractVersion => text()();
  TextColumn get manifestChecksum => text()();
  TextColumn get minimumAppVersion => text().nullable()();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  DateTimeColumn get appliedAt => dateTime()();
  BoolColumn get isCurrent => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalProfiles extends Table with SyncColumns {
  TextColumn get userId => text()();
  TextColumn get preferredLocale => text()();
  TextColumn get timezone => text()();
  IntColumn get weeklyGoalDays => integer()();
  DateTimeColumn get onboardingCompletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {userId};

  @override
  List<String> get customConstraints => [
    "CHECK (preferred_locale IN ('ar', 'en'))",
    'CHECK (weekly_goal_days BETWEEN 1 AND 7)',
  ];
}

class LocalUserPreferences extends Table with SyncColumns {
  TextColumn get userId => text().references(LocalProfiles, #userId)();
  TextColumn get experienceLevel => text()();
  BoolColumn get soundEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get vibrationEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get downloadOnWifiOnly =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

class LocalReminderSchedules extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get userId => text().references(LocalProfiles, #userId)();
  TextColumn get localTime => text()();
  TextColumn get daysOfWeekJson => text()();
  TextColumn get timezone => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalPreferredPositions extends Table with SyncColumns {
  TextColumn get userId => text().references(LocalProfiles, #userId)();
  TextColumn get positionKey => text().references(LocalTaxonomies, #key)();
  BoolColumn get isPermitted => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {userId, positionKey};
}

class LocalCheckIns extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get userId => text().references(LocalProfiles, #userId)();
  TextColumn get bodyState => text()();
  @ReferenceName('checkInGoalReferences')
  TextColumn get goalKey => text().references(LocalTaxonomies, #key)();
  IntColumn get availableMinutes => integer()();
  @ReferenceName('checkInPositionReferences')
  TextColumn get positionKey =>
      text().nullable().references(LocalTaxonomies, #key)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (available_minutes IN (3, 5, 10, 15))',
  ];
}

class LocalCheckInBodyAreas extends Table {
  TextColumn get checkInId => text().references(LocalCheckIns, #id)();
  TextColumn get bodyAreaKey => text().references(LocalTaxonomies, #key)();

  @override
  Set<Column<Object>> get primaryKey => {checkInId, bodyAreaKey};
}

class LocalRecommendations extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get userId => text().references(LocalProfiles, #userId)();
  TextColumn get checkInId => text().references(LocalCheckIns, #id)();
  TextColumn get routineId => text().references(LocalRoutines, #id)();
  TextColumn get engineVersion => text()();
  IntColumn get rank => integer()();
  IntColumn get score => integer()();
  TextColumn get reasonCodesJson => text()();
  DateTimeColumn get shownAt => dateTime()();
  DateTimeColumn get acceptedAt => dateTime().nullable()();
  DateTimeColumn get rejectedAt => dateTime().nullable()();
  TextColumn get rejectionReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (rank >= 0)'];
}

class LocalRoutineSessions extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get userId => text().references(LocalProfiles, #userId)();
  TextColumn get routineId => text().references(LocalRoutines, #id)();
  IntColumn get routineVersion => integer()();
  TextColumn get recommendationId =>
      text().nullable().references(LocalRecommendations, #id)();
  TextColumn get status => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get targetDurationSeconds => integer()();
  IntColumn get actualDurationSeconds => integer()();
  IntColumn get totalSteps => integer()();
  IntColumn get stepsCompleted => integer().withDefault(const Constant(0))();
  IntColumn get stepsPartial => integer().withDefault(const Constant(0))();
  IntColumn get stepsSkipped => integer().withDefault(const Constant(0))();
  TextColumn get completionPolicyVersion => text()();
  TextColumn get source => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (routine_version > 0)',
    "CHECK (status IN ('in_progress', 'completed', 'abandoned'))",
    'CHECK (target_duration_seconds > 0 AND actual_duration_seconds >= 0 AND total_steps > 0)',
    'CHECK (actual_duration_seconds <= target_duration_seconds)',
    "CHECK ((status = 'in_progress' AND completed_at IS NULL) OR "
        "(status != 'in_progress' AND completed_at IS NOT NULL AND completed_at >= started_at))",
    'CHECK (steps_completed >= 0 AND steps_partial >= 0 AND steps_skipped >= 0)',
  ];
}

class LocalSessionSteps extends Table with SyncColumns {
  TextColumn get sessionId => text().references(LocalRoutineSessions, #id)();
  TextColumn get routineStepId => text().references(LocalRoutineSteps, #id)();
  TextColumn get exerciseIdSnapshot => text()();
  IntColumn get positionSnapshot => integer()();
  TextColumn get status => text()();
  IntColumn get targetDurationSeconds => integer()();
  IntColumn get activeDurationSeconds =>
      integer().withDefault(const Constant(0))();
  BoolColumn get skipRequested =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, routineStepId};

  @override
  List<String> get customConstraints => [
    'CHECK (position_snapshot > 0 AND target_duration_seconds > 0 AND active_duration_seconds >= 0)',
    "CHECK (status IN ('pending', 'completed', 'partial', 'skipped'))",
    'CHECK (active_duration_seconds <= target_duration_seconds)',
  ];
}

class LocalSessionFeedback extends Table with SyncColumns {
  TextColumn get sessionId => text().references(LocalRoutineSessions, #id)();
  TextColumn get userId => text().references(LocalProfiles, #userId)();
  TextColumn get rating => text()();
  TextColumn get uncomfortableExerciseId =>
      text().nullable().references(LocalExercises, #id)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId};

  @override
  List<String> get customConstraints => [
    "CHECK (rating IN ('much_better', 'little_better', 'same', 'less_comfortable'))",
  ];
}

class LocalSavedRoutines extends Table with SyncColumns {
  TextColumn get userId => text().references(LocalProfiles, #userId)();
  TextColumn get routineId => text().references(LocalRoutines, #id)();
  DateTimeColumn get savedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {userId, routineId};
}

/// Cached server projections: client code must never treat these as authority.
class LocalProgressProjections extends Table {
  TextColumn get userId => text().references(LocalProfiles, #userId)();
  TextColumn get projectionType => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get serverUpdatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {userId, projectionType};
}

@TableIndex(
  name: 'sync_outbox_owner_due',
  columns: {#ownerUserId, #status, #nextAttemptAt},
)
class SyncOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Client-generated stable UUID that identifies the wire operation across
  /// retries and drives server-side idempotency. Persisted so a retry reuses
  /// the exact same id rather than minting a new one.
  TextColumn get operationId => text()();

  /// The RAHA-025 wire operation kind (`session_start`, `check_in_upsert`, …).
  TextColumn get kind => text()();

  /// The locally editable domain entity this operation belongs to
  /// (`check_in`, `routine_session`, `saved_routine`, …).
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get ownerUserId => text().references(LocalProfiles, #userId)();

  /// Allowlisted, snake_case wire payload for the trusted sync API; no raw
  /// responses. The `operation_id` and `kind` live in dedicated columns.
  TextColumn get payloadJson => text()();

  /// Dependency sub-ordering within a single entity (a session step's
  /// `position_snapshot`), so steps flush in positional order.
  IntColumn get sequence => integer().withDefault(const Constant(0))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime()();
  TextColumn get status =>
      textEnum<OutboxStatus>().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<String> get customConstraints => ['UNIQUE(owner_user_id, operation_id)'];
}

/// Resolves stable local public ids and taxonomy keys to their authoritative
/// server UUIDs, populated from the content-release manifest. This is the
/// explicit mapping boundary: the client never guesses that a taxonomy key is a
/// backend UUID.
class LocalIdMappings extends Table {
  TextColumn get kind => text()();
  TextColumn get localId => text()();
  TextColumn get remoteId => text()();

  @override
  Set<Column<Object>> get primaryKey => {kind, localId};
}

/// Per-user server-issued pull cursor for `sync_pull_user_data`.
class LocalSyncState extends Table {
  TextColumn get userId => text().references(LocalProfiles, #userId)();
  IntColumn get pullCursor => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

@DriftDatabase(
  tables: [
    EnvironmentEntries,
    LocalTaxonomies,
    LocalTaxonomyTranslations,
    LocalExercises,
    LocalExerciseTranslations,
    LocalMediaAssets,
    LocalMediaCacheEntries,
    LocalExerciseTaxonomies,
    LocalRoutines,
    LocalRoutineTranslations,
    LocalRoutineSteps,
    LocalRoutineTaxonomies,
    LocalContentReleases,
    LocalProfiles,
    LocalUserPreferences,
    LocalReminderSchedules,
    LocalPreferredPositions,
    LocalCheckIns,
    LocalCheckInBodyAreas,
    LocalRecommendations,
    LocalRoutineSessions,
    LocalSessionSteps,
    LocalSessionFeedback,
    LocalSavedRoutines,
    LocalProgressProjections,
    LocalIdMappings,
    LocalSyncState,
    SyncOutbox,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await _createV2Tables(m);
      if (from < 3) await _migrateToV3(m);
      if (from < 4) await _migrateToV4(m);
      if (from < 5) await _migrateToV5(m);
      if (from < 6) await _migrateToV6(m);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _createV3Indexes();
    },
  );

  Future<void> _createV2Tables(Migrator m) async {
    await m.createTable(localTaxonomies);
    await m.createTable(localTaxonomyTranslations);
    await m.createTable(localExercises);
    await m.createTable(localExerciseTranslations);
    await m.createTable(localMediaAssets);
    await m.createTable(localMediaCacheEntries);
    await m.createTable(localExerciseTaxonomies);
    await m.createTable(localRoutines);
    await m.createTable(localRoutineTranslations);
    await m.createTable(localRoutineSteps);
    await m.createTable(localRoutineTaxonomies);
    await m.createTable(localContentReleases);
    await m.createTable(localProfiles);
    await m.createTable(localUserPreferences);
    await m.createTable(localReminderSchedules);
    await m.createTable(localPreferredPositions);
    await m.createTable(localCheckIns);
    await m.createTable(localCheckInBodyAreas);
    await m.createTable(localRecommendations);
    await m.createTable(localRoutineSessions);
    await m.createTable(localSessionSteps);
    await m.createTable(localSessionFeedback);
    await m.createTable(localSavedRoutines);
    await m.createTable(localProgressProjections);
    await m.createTable(syncOutbox);
  }

  /// SQLite partial unique indexes protect both INSERT and UPDATE paths.
  Future<void> _createV3Indexes() => customStatement(
    'CREATE UNIQUE INDEX IF NOT EXISTS '
    'local_media_assets_one_preferred_published_per_type '
    'ON local_media_assets (exercise_id, media_type) '
    'WHERE is_preferred = 1 AND status = \'published\'',
  );

  Future<void> _migrateToV3(Migrator m) async {
    // v2 allowed zero snapshots. Recover them from their still-retained
    // canonical routine so the forward migration preserves usable history.
    await customStatement(
      'UPDATE local_routine_sessions SET '
      'target_duration_seconds = (SELECT estimated_duration_seconds FROM local_routines WHERE local_routines.id = local_routine_sessions.routine_id) '
      'WHERE target_duration_seconds <= 0',
    );
    await customStatement(
      'UPDATE local_routine_sessions SET '
      'total_steps = (SELECT COUNT(*) FROM local_routine_steps WHERE local_routine_steps.routine_id = local_routine_sessions.routine_id) '
      'WHERE total_steps <= 0',
    );
    await m.alterTable(TableMigration(localRoutineSessions));
    await _createV3Indexes();
  }

  /// Renames the legacy `storage_key` delivery column to `delivery_reference`
  /// and adds release-contract columns to `local_content_releases`. Both are
  /// guarded so a v1 install (whose tables are created at the current schema
  /// by [MigrationStrategy.onCreate] / `_createV2Tables`) is left untouched.
  Future<void> _migrateToV4(Migrator m) async {
    final mediaColumns = await _tableColumnNames('local_media_assets');
    if (mediaColumns.contains('storage_key') &&
        !mediaColumns.contains('delivery_reference')) {
      await customStatement(
        'ALTER TABLE local_media_assets RENAME TO local_media_assets_pre_v4',
      );
      await customStatement(
        'CREATE TABLE local_media_assets ('
        'id TEXT NOT NULL PRIMARY KEY, '
        'exercise_id TEXT NOT NULL REFERENCES local_exercises (id), '
        'media_type TEXT NOT NULL, '
        'delivery_reference TEXT NOT NULL, '
        'mime_type TEXT NOT NULL, '
        'checksum_sha256 TEXT NOT NULL, '
        'status TEXT NOT NULL, '
        'is_preferred INTEGER NOT NULL DEFAULT 0, '
        'width INTEGER NULL, '
        'height INTEGER NULL, '
        'duration_ms INTEGER NULL, '
        'updated_at INTEGER NOT NULL, '
        "CHECK (delivery_reference NOT LIKE '%://%' AND delivery_reference NOT LIKE '/%' AND delivery_reference NOT LIKE '%?%' AND delivery_reference NOT LIKE '%#%'))",
      );
      await customStatement(
        'INSERT INTO local_media_assets '
        '(id, exercise_id, media_type, delivery_reference, mime_type, '
        'checksum_sha256, status, is_preferred, width, height, duration_ms, updated_at) '
        'SELECT id, exercise_id, media_type, storage_key, mime_type, '
        'checksum_sha256, status, is_preferred, width, height, duration_ms, updated_at '
        'FROM local_media_assets_pre_v4',
      );
      await customStatement('DROP TABLE local_media_assets_pre_v4');
    }
    await _createV3Indexes();

    final releaseColumns = await _tableColumnNames('local_content_releases');
    if (!releaseColumns.contains('version')) {
      await customStatement(
        "ALTER TABLE local_content_releases ADD COLUMN version TEXT NOT NULL DEFAULT ''",
      );
    }
    if (!releaseColumns.contains('contract_version')) {
      await customStatement(
        "ALTER TABLE local_content_releases ADD COLUMN contract_version TEXT NOT NULL DEFAULT 'raha-content-release-v1'",
      );
    }
    if (!releaseColumns.contains('published_at')) {
      await customStatement(
        'ALTER TABLE local_content_releases ADD COLUMN published_at INTEGER NULL',
      );
    }

    final stepColumns = await _tableColumnNames('local_routine_steps');
    if (!stepColumns.contains('status')) {
      await customStatement(
        "ALTER TABLE local_routine_steps ADD COLUMN status TEXT NOT NULL DEFAULT 'published'",
      );
    }
  }

  /// v5: durable stable operation ids + wire kinds on the outbox, plus the
  /// remote-id mapping and per-user pull cursor tables. Legacy outbox rows keep
  /// their domain payload but are parked (`rejected`) because their v1 payload
  /// shape is not a valid RAHA-025 wire operation; they are preserved, never
  /// deleted, and can be rebuilt on an explicit manual retry.
  Future<void> _migrateToV5(Migrator m) async {
    final hasOutbox = await _tableExists('sync_outbox');
    if (!hasOutbox) {
      await m.createTable(syncOutbox);
    } else {
      final outboxColumns = await _tableColumnNames('sync_outbox');
      if (!outboxColumns.contains('operation_id')) {
        await customStatement(
          'ALTER TABLE sync_outbox RENAME TO sync_outbox_pre_v5',
        );
        await m.createTable(syncOutbox);
        await customStatement(
          "INSERT INTO sync_outbox (id, operation_id, kind, entity_type, entity_id, "
          "owner_user_id, payload_json, sequence, attempt_count, next_attempt_at, status, created_at) "
          "SELECT id, "
          "printf('00000000-0000-4000-8000-%012d', id), "
          "CASE entity_type "
          "WHEN 'check_in' THEN 'check_in_upsert' "
          "WHEN 'recommendation' THEN 'recommendation_upsert' "
          "WHEN 'routine_session' THEN 'session_start' "
          "WHEN 'session_feedback' THEN 'feedback_upsert' "
          "WHEN 'saved_routine' THEN 'saved_routine_set' "
          "ELSE 'unsupported_' || entity_type END, "
          "entity_type, entity_id, owner_user_id, payload_json, 0, "
          "attempt_count, next_attempt_at, 'rejected', created_at "
          "FROM sync_outbox_pre_v5",
        );
        await customStatement('DROP TABLE sync_outbox_pre_v5');
      }
    }
    if (!await _tableExists('local_id_mappings')) {
      await m.createTable(localIdMappings);
    }
    if (!await _tableExists('local_sync_state')) {
      await m.createTable(localSyncState);
    }
  }

  /// v6 binds every verified file to the account and entitlement that
  /// authorized it and records its content-release version. Legacy cache rows
  /// are deliberately discarded because they cannot be assigned safely to an
  /// owner. Media bytes live in a disposable cache and are cleaned separately.
  Future<void> _migrateToV6(Migrator m) async {
    if (!await _tableExists('local_media_cache_entries')) {
      await m.createTable(localMediaCacheEntries);
      return;
    }
    final cacheColumns = await _tableColumnNames('local_media_cache_entries');
    if (cacheColumns.contains('owner_id') &&
        cacheColumns.contains('media_version') &&
        cacheColumns.contains('required_entitlement')) {
      return;
    }
    await customStatement(
      'ALTER TABLE local_media_cache_entries RENAME TO local_media_cache_entries_pre_v6',
    );
    await m.createTable(localMediaCacheEntries);
    await customStatement('DROP TABLE local_media_cache_entries_pre_v6');
  }

  Future<bool> _tableExists(String name) async {
    final rows = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = '$name'",
    ).get();
    return rows.isNotEmpty;
  }

  Future<List<String>> _tableColumnNames(String table) async {
    final rows = await customSelect("PRAGMA table_info('$table')").get();
    return rows.map((row) => row.data['name'] as String).toList();
  }
}

/// Local catalog reads. Remote clients are deliberately absent from this layer.
class LocalContentRepository {
  LocalContentRepository(this._database);
  final AppDatabase _database;

  Stream<List<LocalRoutine>> watchPublishedRoutines() => (_database.select(
    _database.localRoutines,
  )..where((r) => r.status.equals('published'))).watch();

  Future<LocalMediaAsset?> findPreferredPlayableMedia(String exerciseId) =>
      (_database.select(_database.localMediaAssets)..where(
            (m) =>
                m.exerciseId.equals(exerciseId) &
                m.isPreferred.equals(true) &
                m.status.equals('published'),
          ))
          .getSingleOrNull();

  /// Replacing footage changes only the preferred media reference, never exercise ID.
  Future<void> replacePreferredMedia({
    required String exerciseId,
    required String replacementMediaId,
  }) => _database.transaction(() async {
    final replacement =
        await (_database.select(_database.localMediaAssets)..where(
              (m) =>
                  m.id.equals(replacementMediaId) &
                  m.exerciseId.equals(exerciseId) &
                  m.status.equals('published'),
            ))
            .getSingle();
    await (_database.update(_database.localMediaAssets)
          ..where((m) => m.exerciseId.equals(exerciseId)))
        .write(const LocalMediaAssetsCompanion(isPreferred: Value(false)));
    await (_database.update(_database.localMediaAssets)
          ..where((m) => m.id.equals(replacement.id)))
        .write(const LocalMediaAssetsCompanion(isPreferred: Value(true)));
  });
}

/// An immutable, ready-to-enqueue wire operation: its `kind`, the domain entity
/// it mutates, and the already-resolved allowlisted snake_case payload.
final class OutboxEnvelope {
  const OutboxEnvelope({
    required this.kind,
    required this.entityType,
    required this.entityId,
    required this.sequence,
    required this.payload,
  });

  final String kind;
  final String entityType;
  final String entityId;
  final int sequence;
  final Map<String, Object?> payload;
}

/// Thrown internally when a required local id/key cannot be resolved to a
/// backend UUID. The local write is retained and the operation is parked for
/// explicit, recoverable retry — never silently dropped or guessed.
final class UnmappedRemoteIdException implements Exception {
  const UnmappedRemoteIdException(this.kind, this.localId);

  final String kind;
  final String localId;

  @override
  String toString() => 'UnmappedRemoteIdException($kind: $localId)';
}

/// Writes and resolves the remote (server UUID) identity map populated from the
/// content-release manifest. This is the explicit mapping boundary between
/// stable local public ids / taxonomy keys and authoritative backend UUIDs.
final class LocalIdMappingStore {
  LocalIdMappingStore(this._database);

  final AppDatabase _database;

  Future<void> store({
    required String kind,
    required String localId,
    required String remoteId,
  }) {
    return _database
        .into(_database.localIdMappings)
        .insertOnConflictUpdate(
          LocalIdMappingsCompanion.insert(
            kind: kind,
            localId: localId,
            remoteId: remoteId,
          ),
        );
  }

  Future<String?> resolve({
    required String kind,
    required String localId,
  }) async {
    final row =
        await (_database.select(_database.localIdMappings)
              ..where((r) => r.kind.equals(kind) & r.localId.equals(localId)))
            .getSingleOrNull();
    return row?.remoteId;
  }
}

/// Builds RAHA-025 wire operations from durable local rows. Every payload is
/// snake_case and strictly allowlisted to the backend field lists; unknown or
/// local-only fields are never emitted. Required ids that are not already a
/// UUID are resolved through [LocalIdMappingStore] and, when unresolvable,
/// raise [UnmappedRemoteIdException] so the caller can park the write.
final class WireOperationBuilder {
  WireOperationBuilder(
    this._database, {
    required this.activeUserId,
    required this.appVersion,
  });

  final AppDatabase _database;
  final String activeUserId;
  final String appVersion;

  LocalIdMappingStore get _mappings => LocalIdMappingStore(_database);

  /// Builds all wire operations for one locally editable entity, in dependency
  /// order. A terminal session yields `session_start` + ordered
  /// `session_step_upsert`(s) + `session_finalize`.
  Future<List<OutboxEnvelope>> buildFor(String entityType, String entityId) {
    return switch (entityType) {
      'check_in' => _buildCheckIn(entityId),
      'recommendation' => _buildRecommendation(entityId),
      'routine_session' => _buildSession(entityId),
      'session_feedback' => _buildFeedback(entityId),
      'saved_routine' => _buildSavedRoutine(entityId),
      _ => throw UnsupportedError('Unsupported sync entity type: $entityType'),
    };
  }

  /// Resolves [localId] to a backend UUID. A value that is already a valid UUID
  /// (client-generated id or server-issued `routine_step_id`) is used directly;
  /// anything else is treated as a local public id / taxonomy key and resolved
  /// through the mapping boundary. Returns null only when unmapped.
  Future<String?> resolveRemoteUuid(String kind, String localId) async {
    if (localId.isEmpty) return null;
    if (_uuidPattern.hasMatch(localId)) return localId;
    return _mappings.resolve(kind: kind, localId: localId);
  }

  Future<String> _requireRemoteUuid(String kind, String localId) async {
    final resolved = await resolveRemoteUuid(kind, localId);
    if (resolved == null) throw UnmappedRemoteIdException(kind, localId);
    return resolved;
  }

  Future<List<OutboxEnvelope>> _buildCheckIn(String id) async {
    final row =
        await (_database.select(_database.localCheckIns)
              ..where((r) => r.id.equals(id) & r.userId.equals(activeUserId)))
            .getSingle();
    final goalId = await _requireRemoteUuid(
      RemoteIdMappingKind.taxonomy,
      row.goalKey,
    );
    final positionId = row.positionKey == null
        ? null
        : await _requireRemoteUuid(
            RemoteIdMappingKind.taxonomy,
            row.positionKey!,
          );

    // Selected body areas are stored per check-in; each local taxonomy key is
    // resolved to its authoritative server UUID and emitted as a strict,
    // deterministic `body_area_ids` array (ordered by key so retries are
    // byte-identical). An unmapped key parks the write rather than guessing.
    final bodyAreaRows =
        await (_database.select(_database.localCheckInBodyAreas)
              ..where((r) => r.checkInId.equals(id))
              ..orderBy([(r) => OrderingTerm.asc(r.bodyAreaKey)]))
            .get();
    final bodyAreaIds = <String>[
      for (final area in bodyAreaRows)
        await _requireRemoteUuid(
          RemoteIdMappingKind.taxonomy,
          area.bodyAreaKey,
        ),
    ];

    return [
      OutboxEnvelope(
        kind: WireOperationKind.checkInUpsert,
        entityType: 'check_in',
        entityId: id,
        sequence: 0,
        payload: <String, Object?>{
          'id': row.id,
          'body_state': row.bodyState,
          'goal_id': goalId,
          'available_minutes': row.availableMinutes,
          'position_id': ?positionId,
          'started_at': _iso(row.startedAt),
          if (row.completedAt != null) 'completed_at': _iso(row.completedAt!),
          'body_area_ids': bodyAreaIds,
        },
      ),
    ];
  }

  Future<List<OutboxEnvelope>> _buildRecommendation(String id) async {
    final row =
        await (_database.select(_database.localRecommendations)
              ..where((r) => r.id.equals(id) & r.userId.equals(activeUserId)))
            .getSingle();
    final routineId = await _requireRemoteUuid(
      RemoteIdMappingKind.routine,
      row.routineId,
    );
    return [
      OutboxEnvelope(
        kind: WireOperationKind.recommendationUpsert,
        entityType: 'recommendation',
        entityId: id,
        sequence: 0,
        payload: <String, Object?>{
          'id': row.id,
          'check_in_id': row.checkInId,
          'routine_id': routineId,
          'engine_version': row.engineVersion,
          // Local rank is 0-based (0 = top candidate); the backend contract is
          // 1..100, so the wire value is shifted by one.
          'rank': row.rank + 1,
          'score': row.score,
          'reason_codes': _decodeStringList(row.reasonCodesJson),
          'shown_at': _iso(row.shownAt),
          if (row.acceptedAt != null) 'accepted_at': _iso(row.acceptedAt!),
          if (row.rejectedAt != null) 'rejected_at': _iso(row.rejectedAt!),
          if (row.rejectionReason != null)
            'rejection_reason': row.rejectionReason,
        },
      ),
    ];
  }

  Future<List<OutboxEnvelope>> _buildSession(String id) async {
    final row =
        await (_database.select(_database.localRoutineSessions)
              ..where((r) => r.id.equals(id) & r.userId.equals(activeUserId)))
            .getSingle();
    final steps = await (_database.select(
      _database.localSessionSteps,
    )..where((r) => r.sessionId.equals(id))).get();
    steps.sort((a, b) => a.positionSnapshot.compareTo(b.positionSnapshot));
    final routineId = await _requireRemoteUuid(
      RemoteIdMappingKind.routine,
      row.routineId,
    );

    final envelopes = <OutboxEnvelope>[
      OutboxEnvelope(
        kind: WireOperationKind.sessionStart,
        entityType: 'routine_session',
        entityId: id,
        sequence: 0,
        payload: <String, Object?>{
          'id': row.id,
          'routine_id': routineId,
          'routine_version': row.routineVersion,
          if (row.recommendationId != null)
            'recommendation_id': row.recommendationId,
          'source': row.source,
          'app_version': appVersion,
        },
      ),
    ];

    for (final step in steps) {
      final exerciseId = await _requireRemoteUuid(
        RemoteIdMappingKind.exercise,
        step.exerciseIdSnapshot,
      );
      envelopes.add(
        OutboxEnvelope(
          kind: WireOperationKind.sessionStepUpsert,
          entityType: 'routine_session',
          entityId: id,
          sequence: step.positionSnapshot,
          payload: <String, Object?>{
            'session_id': id,
            'routine_step_id': step.routineStepId,
            'exercise_id_snapshot': exerciseId,
            'position_snapshot': step.positionSnapshot,
            'status': step.status,
            'target_duration_seconds': step.targetDurationSeconds,
            'active_duration_seconds': step.activeDurationSeconds,
            'skip_requested': step.skipRequested,
            if (step.startedAt != null) 'started_at': _iso(step.startedAt!),
            if (step.finishedAt != null) 'finished_at': _iso(step.finishedAt!),
          },
        ),
      );
    }

    if (row.status != 'in_progress') {
      envelopes.add(
        OutboxEnvelope(
          kind: WireOperationKind.sessionFinalize,
          entityType: 'routine_session',
          entityId: id,
          sequence: steps.length + 1,
          payload: <String, Object?>{
            'session_id': id,
            'completion_policy_version': row.completionPolicyVersion,
          },
        ),
      );
    }

    return envelopes;
  }

  Future<List<OutboxEnvelope>> _buildFeedback(String id) async {
    final row =
        await (_database.select(_database.localSessionFeedback)..where(
              (r) => r.sessionId.equals(id) & r.userId.equals(activeUserId),
            ))
            .getSingle();
    final uncomfortable = row.uncomfortableExerciseId == null
        ? null
        : await _requireRemoteUuid(
            RemoteIdMappingKind.exercise,
            row.uncomfortableExerciseId!,
          );
    return [
      OutboxEnvelope(
        kind: WireOperationKind.feedbackUpsert,
        entityType: 'session_feedback',
        entityId: id,
        sequence: 0,
        payload: <String, Object?>{
          'session_id': id,
          'rating': row.rating,
          'uncomfortable_exercise_id': ?uncomfortable,
          'created_at': _iso(row.createdAt),
        },
      ),
    ];
  }

  Future<List<OutboxEnvelope>> _buildSavedRoutine(String routineId) async {
    final row =
        await (_database.select(_database.localSavedRoutines)..where(
              (r) =>
                  r.userId.equals(activeUserId) & r.routineId.equals(routineId),
            ))
            .getSingle();
    final remoteRoutineId = await _requireRemoteUuid(
      RemoteIdMappingKind.routine,
      routineId,
    );
    return [
      OutboxEnvelope(
        kind: WireOperationKind.savedRoutineSet,
        entityType: 'saved_routine',
        entityId: routineId,
        sequence: 0,
        payload: <String, Object?>{
          'routine_id': remoteRoutineId,
          'saved': row.deletedAt == null,
          'operation_at': _iso(row.localUpdatedAt),
        },
      ),
    ];
  }

  static String _iso(DateTime value) => value.toUtc().toIso8601String();

  static List<String> _decodeStringList(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! List) return const [];
    return decoded.whereType<String>().toList();
  }
}

/// Local-first private writes. One instance is bound to exactly one active user.
class LocalUserDataRepository {
  LocalUserDataRepository(
    this._database, {
    required this.activeUserId,
    DateTime Function()? clock,
    String Function()? operationIdGenerator,
    this.appVersion = '1.0.0',
  }) : _clock = clock ?? _unsupportedClock,
       _operationIdGenerator = operationIdGenerator ?? generateUuidV4,
       _builder = WireOperationBuilder(
         _database,
         activeUserId: activeUserId,
         appVersion: appVersion,
       );

  final AppDatabase _database;
  final String activeUserId;
  final DateTime Function() _clock;
  final String Function() _operationIdGenerator;
  final String appVersion;
  final WireOperationBuilder _builder;

  static DateTime _unsupportedClock() => throw StateError('Inject a UTC clock');

  Future<void> saveCheckIn({
    required LocalCheckInsCompanion checkIn,
    required Iterable<String> bodyAreaKeys,
  }) => _database.transaction(() async {
    _requireOwner(checkIn.userId.value);
    final old = await (_database.select(
      _database.localCheckIns,
    )..where((r) => r.id.equals(checkIn.id.value))).getSingleOrNull();
    if (old != null && old.userId != activeUserId) {
      throw StateError('Cross-account check-in collision');
    }
    final now = _now();
    final prepared = checkIn.copyWith(
      syncState: Value(
        old == null ? SyncState.pendingCreate : SyncState.pendingUpdate,
      ),
      localUpdatedAt: Value(now),
      lastSyncError: const Value(null),
    );
    await _database
        .into(_database.localCheckIns)
        .insertOnConflictUpdate(prepared);
    await (_database.delete(
      _database.localCheckInBodyAreas,
    )..where((r) => r.checkInId.equals(checkIn.id.value))).go();
    await _database.batch(
      (b) => b.insertAll(_database.localCheckInBodyAreas, [
        for (final key in bodyAreaKeys)
          LocalCheckInBodyAreasCompanion.insert(
            checkInId: checkIn.id.value,
            bodyAreaKey: key,
          ),
      ]),
    );
    await _enqueueBuilt('check_in', checkIn.id.value);
  });

  Future<void> saveSavedRoutine({
    required LocalSavedRoutinesCompanion savedRoutine,
  }) => _database.transaction(() async {
    _requireOwner(savedRoutine.userId.value);
    final old =
        await (_database.select(_database.localSavedRoutines)..where(
              (r) =>
                  r.userId.equals(activeUserId) &
                  r.routineId.equals(savedRoutine.routineId.value),
            ))
            .getSingleOrNull();
    final now = _now();
    final prepared = savedRoutine.copyWith(
      syncState: Value(
        old == null
            ? SyncState.pendingCreate
            : (savedRoutine.deletedAt.present &&
                      savedRoutine.deletedAt.value != null
                  ? SyncState.pendingDelete
                  : SyncState.pendingUpdate),
      ),
      localUpdatedAt: Value(now),
      lastSyncError: const Value(null),
    );
    await _database
        .into(_database.localSavedRoutines)
        .insertOnConflictUpdate(prepared);
    await _enqueueBuilt('saved_routine', savedRoutine.routineId.value);
  });

  Future<void> saveSessionWithSteps({
    required LocalRoutineSessionsCompanion session,
    required Iterable<LocalSessionStepsCompanion> steps,
  }) => _database.transaction(() async {
    _requireOwner(session.userId.value);
    final old = await (_database.select(
      _database.localRoutineSessions,
    )..where((r) => r.id.equals(session.id.value))).getSingleOrNull();
    if (old != null && old.userId != activeUserId) {
      throw StateError('Cross-account session collision');
    }
    final stepList = steps.map(_canonicalizeStepState).toList();
    final routine =
        await (_database.select(_database.localRoutines)..where(
              (r) =>
                  r.id.equals(session.routineId.value) &
                  r.version.equals(session.routineVersion.value),
            ))
            .getSingleOrNull();
    if (routine == null ||
        routine.estimatedDurationSeconds <= 0 ||
        session.targetDurationSeconds.value !=
            routine.estimatedDurationSeconds ||
        session.totalSteps.value <= 0) {
      throw ArgumentError('Session does not match its canonical routine');
    }
    final canonical =
        await (_database.select(_database.localRoutineSteps)..where(
              (r) =>
                  r.routineId.equals(session.routineId.value) &
                  r.status.equals('published'),
            ))
            .get();
    final canonicalById = {for (final step in canonical) step.id: step};
    if (stepList.length != canonicalById.length ||
        canonicalById.isEmpty ||
        canonical.any((step) => step.durationSeconds <= 0) ||
        canonical.fold<int>(0, (sum, step) => sum + step.durationSeconds) !=
            routine.estimatedDurationSeconds ||
        stepList.map((s) => s.routineStepId.value).toSet().length !=
            stepList.length) {
      throw ArgumentError('Missing or duplicate routine steps');
    }
    for (final step in stepList) {
      final expected = canonicalById[step.routineStepId.value];
      if (step.sessionId.value != session.id.value ||
          expected == null ||
          step.exerciseIdSnapshot.value != expected.exerciseId ||
          step.positionSnapshot.value != expected.position ||
          step.targetDurationSeconds.value != expected.durationSeconds ||
          step.activeDurationSeconds.value > expected.durationSeconds) {
        throw ArgumentError('Invalid routine step snapshot');
      }
    }
    final actual = stepList.fold(
      0,
      (sum, step) => sum + step.activeDurationSeconds.value,
    );
    final completed = stepList
        .where((step) => step.status.value == 'completed')
        .length;
    final partial = stepList
        .where((step) => step.status.value == 'partial')
        .length;
    final skipped = stepList
        .where((step) => step.status.value == 'skipped')
        .length;
    if (actual > session.targetDurationSeconds.value ||
        stepList.length != session.totalSteps.value) {
      throw ArgumentError('Invalid session aggregates');
    }
    final terminal = stepList.every((step) => step.status.value != 'pending');
    final isCompleted =
        actual * 100 >= session.targetDurationSeconds.value * 80 &&
        skipped <= session.totalSteps.value ~/ 5;
    final status = terminal
        ? (isCompleted ? 'completed' : 'abandoned')
        : 'in_progress';
    if (old != null && old.status != 'in_progress') {
      final persistedSteps = await (_database.select(
        _database.localSessionSteps,
      )..where((step) => step.sessionId.equals(session.id.value))).get();
      final persistedByRoutineStep = {
        for (final step in persistedSteps) step.routineStepId: step,
      };
      final isExactRetry =
          persistedByRoutineStep.length == stepList.length &&
          stepList.every((step) {
            final persisted = persistedByRoutineStep[step.routineStepId.value];
            return persisted != null &&
                persisted.exerciseIdSnapshot == step.exerciseIdSnapshot.value &&
                persisted.positionSnapshot == step.positionSnapshot.value &&
                persisted.status == step.status.value &&
                persisted.targetDurationSeconds ==
                    step.targetDurationSeconds.value &&
                persisted.activeDurationSeconds ==
                    step.activeDurationSeconds.value &&
                persisted.skipRequested ==
                    (step.skipRequested.present
                        ? step.skipRequested.value
                        : false);
          });
      if (old.status == status &&
          old.actualDurationSeconds == actual &&
          old.stepsCompleted == completed &&
          old.stepsPartial == partial &&
          old.stepsSkipped == skipped &&
          isExactRetry) {
        return;
      }
      throw StateError('Terminal session cannot change');
    }
    final now = _now();
    final prepared = session.copyWith(
      status: Value(status),
      actualDurationSeconds: Value(actual),
      stepsCompleted: Value(completed),
      stepsPartial: Value(partial),
      stepsSkipped: Value(skipped),
      completedAt: terminal ? Value(now) : const Value(null),
      syncState: Value(
        old == null ? SyncState.pendingCreate : SyncState.pendingUpdate,
      ),
      localUpdatedAt: Value(now),
      lastSyncError: const Value(null),
    );
    await _database
        .into(_database.localRoutineSessions)
        .insertOnConflictUpdate(prepared);
    await _database.batch(
      (b) => b.insertAllOnConflictUpdate(
        _database.localSessionSteps,
        stepList
            .map(
              (step) => step.copyWith(
                syncState: Value(
                  old == null
                      ? SyncState.pendingCreate
                      : SyncState.pendingUpdate,
                ),
                localUpdatedAt: Value(now),
                lastSyncError: const Value(null),
              ),
            )
            .toList(),
      ),
    );
    await _enqueueBuilt('routine_session', session.id.value);
  });

  Future<void> savePreferences({
    required LocalUserPreferencesCompanion preferences,
  }) => _database.transaction(() async {
    _requireOwner(preferences.userId.value);
    final now = _now();
    await _database
        .into(_database.localUserPreferences)
        .insertOnConflictUpdate(
          preferences.copyWith(
            syncState: const Value(SyncState.pendingUpdate),
            localUpdatedAt: Value(now),
            lastSyncError: const Value(null),
          ),
        );
    // Preferences have no RAHA-025 wire contract yet; they remain local-first
    // until their owning task defines the push/pull shape.
  });

  Future<void> saveRecommendation({
    required LocalRecommendationsCompanion recommendation,
  }) => _database.transaction(() async {
    _requireOwner(recommendation.userId.value);
    final now = _now();
    final checkIn =
        await (_database.select(_database.localCheckIns)..where(
              (r) =>
                  r.id.equals(recommendation.checkInId.value) &
                  r.userId.equals(activeUserId),
            ))
            .getSingleOrNull();
    if (checkIn == null) {
      throw StateError('Recommendation check-in is not owned');
    }
    final old = await (_database.select(
      _database.localRecommendations,
    )..where((r) => r.id.equals(recommendation.id.value))).getSingleOrNull();
    if (old != null && old.userId != activeUserId) {
      throw StateError('Cross-account recommendation collision');
    }
    await _database
        .into(_database.localRecommendations)
        .insertOnConflictUpdate(
          recommendation.copyWith(
            syncState: Value(
              old == null ? SyncState.pendingCreate : SyncState.pendingUpdate,
            ),
            localUpdatedAt: Value(now),
            lastSyncError: const Value(null),
          ),
        );
    await _enqueueBuilt('recommendation', recommendation.id.value);
  });

  Future<void> saveFeedback({
    required LocalSessionFeedbackCompanion feedback,
  }) => _database.transaction(() async {
    _requireOwner(feedback.userId.value);
    final now = _now();
    final session =
        await (_database.select(_database.localRoutineSessions)..where(
              (r) =>
                  r.id.equals(feedback.sessionId.value) &
                  r.userId.equals(activeUserId),
            ))
            .getSingleOrNull();
    if (session == null || session.status != 'completed') {
      throw StateError('Feedback requires owned completed session');
    }
    await _database
        .into(_database.localSessionFeedback)
        .insertOnConflictUpdate(
          feedback.copyWith(
            syncState: const Value(SyncState.pendingUpdate),
            localUpdatedAt: Value(now),
            lastSyncError: const Value(null),
          ),
        );
    await _enqueueBuilt('session_feedback', feedback.sessionId.value);
  });

  Future<void> saveReminder({
    required LocalReminderSchedulesCompanion reminder,
  }) => _database.transaction(() async {
    _requireOwner(reminder.userId.value);
    final now = _now();
    final old = await (_database.select(
      _database.localReminderSchedules,
    )..where((r) => r.id.equals(reminder.id.value))).getSingleOrNull();
    if (old != null && old.userId != activeUserId) {
      throw StateError('Cross-account reminder collision');
    }
    await _database
        .into(_database.localReminderSchedules)
        .insertOnConflictUpdate(
          reminder.copyWith(
            syncState: Value(
              old == null ? SyncState.pendingCreate : SyncState.pendingUpdate,
            ),
            localUpdatedAt: Value(now),
            lastSyncError: const Value(null),
          ),
        );
    // Reminders have no RAHA-025 wire contract yet; they remain local-first
    // until their owning task defines the push/pull shape.
  });

  Future<List<SyncOutboxData>> dueOutbox() =>
      (_database.select(_database.syncOutbox)
            ..where(
              (r) =>
                  r.ownerUserId.equals(activeUserId) &
                  r.status.equalsValue(OutboxStatus.pending) &
                  r.nextAttemptAt.isSmallerOrEqualValue(_now()),
            )
            ..orderBy([(r) => OrderingTerm.asc(r.nextAttemptAt)]))
          .get();

  Future<void> purgeActiveUser() => _database.transaction(() async {
    await (_database.delete(
      _database.syncOutbox,
    )..where((r) => r.ownerUserId.equals(activeUserId))).go();
    await (_database.delete(
      _database.localSessionFeedback,
    )..where((r) => r.userId.equals(activeUserId))).go();
    await _database.customStatement(
      'DELETE FROM local_session_steps WHERE session_id IN (SELECT id FROM local_routine_sessions WHERE user_id = ?)',
      [activeUserId],
    );
    await (_database.delete(
      _database.localRoutineSessions,
    )..where((r) => r.userId.equals(activeUserId))).go();
    await (_database.delete(
      _database.localRecommendations,
    )..where((r) => r.userId.equals(activeUserId))).go();
    await _database.customStatement(
      'DELETE FROM local_check_in_body_areas WHERE check_in_id IN (SELECT id FROM local_check_ins WHERE user_id = ?)',
      [activeUserId],
    );
    await (_database.delete(
      _database.localCheckIns,
    )..where((r) => r.userId.equals(activeUserId))).go();
    await (_database.delete(
      _database.localSavedRoutines,
    )..where((r) => r.userId.equals(activeUserId))).go();
    await (_database.delete(
      _database.localUserPreferences,
    )..where((r) => r.userId.equals(activeUserId))).go();
    await (_database.delete(
      _database.localReminderSchedules,
    )..where((r) => r.userId.equals(activeUserId))).go();
    await (_database.delete(
      _database.localPreferredPositions,
    )..where((r) => r.userId.equals(activeUserId))).go();
    await (_database.delete(
      _database.localProgressProjections,
    )..where((r) => r.userId.equals(activeUserId))).go();
    await (_database.delete(
      _database.localSyncState,
    )..where((r) => r.userId.equals(activeUserId))).go();
    await (_database.delete(
      _database.localProfiles,
    )..where((r) => r.userId.equals(activeUserId))).go();
    await _database.delete(_database.localMediaCacheEntries).go();
  });

  Future<void> expireLocalData() => _database.transaction(() async {
    final cutoff = _now().subtract(const Duration(hours: 24));
    final expired =
        await (_database.select(_database.localCheckIns)..where(
              (r) =>
                  r.userId.equals(activeUserId) &
                  r.completedAt.isNull() &
                  r.startedAt.isSmallerThanValue(cutoff),
            ))
            .get();
    for (final row in expired) {
      await (_database.delete(
        _database.localCheckInBodyAreas,
      )..where((r) => r.checkInId.equals(row.id))).go();
      await (_database.delete(
        _database.localCheckIns,
      )..where((r) => r.id.equals(row.id))).go();
      await (_database.delete(_database.syncOutbox)..where(
            (r) =>
                r.ownerUserId.equals(activeUserId) &
                r.entityType.equals('check_in') &
                r.entityId.equals(row.id),
          ))
          .go();
    }
  });

  /// Idempotently abandons sessions with no credited activity for 24 hours.
  Future<void> expireInactiveSessions() => _database.transaction(() async {
    final cutoff = _now().subtract(const Duration(hours: 24));
    final sessions =
        await (_database.select(_database.localRoutineSessions)..where(
              (r) =>
                  r.userId.equals(activeUserId) &
                  r.status.equals('in_progress'),
            ))
            .get();
    for (final session in sessions) {
      final steps = await (_database.select(
        _database.localSessionSteps,
      )..where((r) => r.sessionId.equals(session.id))).get();
      final creditedActivity = steps
          .where((step) => step.activeDurationSeconds > 0)
          .map(
            (step) => step.finishedAt ?? step.startedAt ?? session.startedAt,
          );
      final activity = creditedActivity.fold<DateTime>(
        session.startedAt,
        (latest, timestamp) => timestamp.isAfter(latest) ? timestamp : latest,
      );
      if (!activity.isAfter(cutoff)) {
        final now = _now();
        await (_database.update(
          _database.localRoutineSessions,
        )..where((r) => r.id.equals(session.id))).write(
          LocalRoutineSessionsCompanion(
            status: const Value('abandoned'),
            completedAt: Value(now),
            syncState: const Value(SyncState.pendingUpdate),
            localUpdatedAt: Value(now),
            lastSyncError: const Value(null),
          ),
        );
        await _enqueueBuilt('routine_session', session.id);
      }
    }
  });

  DateTime _now() => _clock().toUtc();

  /// Preserves credited playback: a Skip after playback began is a partial
  /// step, never a zero-credit skipped step.
  LocalSessionStepsCompanion _canonicalizeStepState(
    LocalSessionStepsCompanion step,
  ) {
    final status = step.status.value;
    final active = step.activeDurationSeconds.value;
    final target = step.targetDurationSeconds.value;
    final skipRequested = step.skipRequested.present
        ? step.skipRequested.value
        : false;

    if (active < 0 || target <= 0 || active > target) {
      throw ArgumentError('Invalid step credited duration');
    }
    switch (status) {
      case 'completed':
        if (active != target || skipRequested) {
          throw ArgumentError('Completed steps require full credited playback');
        }
        return step;
      case 'partial':
        if (active <= 0 || active >= target) {
          throw ArgumentError(
            'Partial steps require credited playback below target',
          );
        }
        return step;
      case 'skipped':
        if (active == 0) {
          if (step.startedAt.present && step.startedAt.value != null) {
            throw ArgumentError('Skipped steps cannot have started playback');
          }
          return step.copyWith(skipRequested: const Value(true));
        }
        if (active < target) {
          return step.copyWith(
            status: const Value('partial'),
            skipRequested: const Value(true),
          );
        }
        return step.copyWith(
          status: const Value('completed'),
          skipRequested: const Value(false),
        );
      case 'pending':
        if (active != 0 ||
            skipRequested ||
            (step.finishedAt.present && step.finishedAt.value != null)) {
          throw ArgumentError('Pending steps cannot be terminal or credited');
        }
        return step;
      default:
        throw ArgumentError('Unknown session step state');
    }
  }

  void _requireOwner(String owner) {
    if (owner != activeUserId) throw StateError('Cross-account write rejected');
  }

  /// Builds the wire operations for one locally editable entity and replaces
  /// its pending outbox rows. When a required remote id cannot be resolved the
  /// write is parked (retained, never deleted) for explicit manual retry.
  Future<void> _enqueueBuilt(String entityType, String entityId) async {
    final List<OutboxEnvelope> envelopes;
    try {
      envelopes = await _builder.buildFor(entityType, entityId);
    } on UnmappedRemoteIdException {
      await _parkUnmapped(entityType, entityId);
      return;
    }
    await _replaceOutbox(envelopes);
  }

  Future<void> _replaceOutbox(List<OutboxEnvelope> envelopes) async {
    final now = _now();
    final keys = envelopes
        .map((envelope) => (envelope.entityType, envelope.entityId))
        .toSet();
    for (final (entityType, entityId) in keys) {
      await (_database.delete(_database.syncOutbox)..where(
            (r) =>
                r.ownerUserId.equals(activeUserId) &
                r.entityType.equals(entityType) &
                r.entityId.equals(entityId),
          ))
          .go();
    }
    await _database.batch(
      (b) => b.insertAll(_database.syncOutbox, [
        for (final envelope in envelopes)
          SyncOutboxCompanion.insert(
            operationId: _operationIdGenerator(),
            kind: envelope.kind,
            entityType: envelope.entityType,
            entityId: envelope.entityId,
            ownerUserId: activeUserId,
            payloadJson: jsonEncode(envelope.payload),
            sequence: Value(envelope.sequence),
            nextAttemptAt: now,
            status: const Value(OutboxStatus.pending),
            createdAt: now,
          ),
      ]),
    );
  }

  Future<void> _parkUnmapped(String entityType, String entityId) async {
    final now = _now();
    await (_database.delete(_database.syncOutbox)..where(
          (r) =>
              r.ownerUserId.equals(activeUserId) &
              r.entityType.equals(entityType) &
              r.entityId.equals(entityId),
        ))
        .go();
    await _database
        .into(_database.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            operationId: _operationIdGenerator(),
            kind: _defaultKindFor(entityType),
            entityType: entityType,
            entityId: entityId,
            ownerUserId: activeUserId,
            payloadJson: '{}',
            sequence: const Value(0),
            nextAttemptAt: now,
            status: const Value(OutboxStatus.rejected),
            createdAt: now,
          ),
        );
    await _markDomainFailed(
      entityType,
      entityId,
      SyncDiagnosticCode.unmappedId,
    );
  }

  static String _defaultKindFor(String entityType) => switch (entityType) {
    'check_in' => WireOperationKind.checkInUpsert,
    'recommendation' => WireOperationKind.recommendationUpsert,
    'routine_session' => WireOperationKind.sessionStart,
    'session_feedback' => WireOperationKind.feedbackUpsert,
    'saved_routine' => WireOperationKind.savedRoutineSet,
    _ => 'unsupported_$entityType',
  };

  /// Rebuilds a parked operation from its durable domain rows (re-resolving
  /// remote ids now that the mapping may have arrived) and re-enqueues it as
  /// `pending`. Keeps its `operation_id` stable. Returns false (and keeps the
  /// operation parked) when the payload is still impossible.
  Future<bool> rebuildOutboxOperation(
    String entityType,
    String entityId,
  ) async {
    return _database.transaction(() async {
      final parked =
          await (_database.select(_database.syncOutbox)..where(
                (r) =>
                    r.ownerUserId.equals(activeUserId) &
                    r.status.equalsValue(OutboxStatus.rejected) &
                    r.entityType.equals(entityType) &
                    r.entityId.equals(entityId),
              ))
              .get();
      if (parked.isEmpty) return false;
      final operationIds = parked.map((row) => row.operationId).toList();
      final List<OutboxEnvelope> envelopes;
      try {
        envelopes = await _builder.buildFor(entityType, entityId);
      } on UnmappedRemoteIdException {
        return false; // still impossible; remain parked for a later retry.
      }
      final now = _now();
      await (_database.delete(_database.syncOutbox)..where(
            (r) =>
                r.ownerUserId.equals(activeUserId) &
                r.entityType.equals(entityType) &
                r.entityId.equals(entityId),
          ))
          .go();
      await _database.batch(
        (b) => b.insertAll(_database.syncOutbox, [
          for (var i = 0; i < envelopes.length; i++)
            SyncOutboxCompanion.insert(
              // Reuse a stable existing id when present so a partial server
              // application is never double-counted.
              operationId: i < operationIds.length
                  ? operationIds[i]
                  : _operationIdGenerator(),
              kind: envelopes[i].kind,
              entityType: envelopes[i].entityType,
              entityId: envelopes[i].entityId,
              ownerUserId: activeUserId,
              payloadJson: jsonEncode(envelopes[i].payload),
              sequence: Value(envelopes[i].sequence),
              nextAttemptAt: now,
              status: const Value(OutboxStatus.pending),
              createdAt: now,
            ),
        ]),
      );
      return true;
    });
  }

  Future<List<SyncOutboxData>> parkedOutbox() =>
      (_database.select(_database.syncOutbox)
            ..where(
              (r) =>
                  r.ownerUserId.equals(activeUserId) &
                  r.status.equalsValue(OutboxStatus.rejected),
            )
            ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]))
          .get();

  Future<int> pullCursor() async {
    final row = await (_database.select(
      _database.localSyncState,
    )..where((r) => r.userId.equals(activeUserId))).getSingleOrNull();
    return row?.pullCursor ?? 0;
  }

  Future<void> storePullCursor(int cursor) {
    return _database
        .into(_database.localSyncState)
        .insertOnConflictUpdate(
          LocalSyncStateCompanion.insert(
            userId: activeUserId,
            pullCursor: Value(cursor),
          ),
        );
  }

  /// Reverse-resolves a backend UUID to the stable local public id/key, if one
  /// is known. Used when reconciling server-authored pull changes.
  Future<String?> localIdForRemote(String kind, String remoteId) async {
    final row =
        await (_database.select(_database.localIdMappings)
              ..where((r) => r.kind.equals(kind) & r.remoteId.equals(remoteId)))
            .getSingleOrNull();
    return row?.localId;
  }

  Future<void> _markDomainFailed(
    String entityType,
    String entityId,
    SyncDiagnosticCode code,
  ) async {
    final error = Value<SyncDiagnosticCode?>(code);
    switch (entityType) {
      case 'check_in':
        await (_database.update(
          _database.localCheckIns,
        )..where((r) => r.id.equals(entityId))).write(
          LocalCheckInsCompanion(
            syncState: const Value(SyncState.failed),
            lastSyncError: error,
          ),
        );
      case 'recommendation':
        await (_database.update(
          _database.localRecommendations,
        )..where((r) => r.id.equals(entityId))).write(
          LocalRecommendationsCompanion(
            syncState: const Value(SyncState.failed),
            lastSyncError: error,
          ),
        );
      case 'routine_session':
        await (_database.update(
          _database.localRoutineSessions,
        )..where((r) => r.id.equals(entityId))).write(
          LocalRoutineSessionsCompanion(
            syncState: const Value(SyncState.failed),
            lastSyncError: error,
          ),
        );
        await (_database.update(
          _database.localSessionSteps,
        )..where((r) => r.sessionId.equals(entityId))).write(
          LocalSessionStepsCompanion(
            syncState: const Value(SyncState.failed),
            lastSyncError: error,
          ),
        );
      case 'session_feedback':
        await (_database.update(
          _database.localSessionFeedback,
        )..where((r) => r.sessionId.equals(entityId))).write(
          LocalSessionFeedbackCompanion(
            syncState: const Value(SyncState.failed),
            lastSyncError: error,
          ),
        );
      case 'saved_routine':
        await (_database.update(_database.localSavedRoutines)..where(
              (r) =>
                  r.userId.equals(activeUserId) & r.routineId.equals(entityId),
            ))
            .write(
              LocalSavedRoutinesCompanion(
                syncState: const Value(SyncState.failed),
                lastSyncError: error,
              ),
            );
      default:
        break;
    }
  }
}
