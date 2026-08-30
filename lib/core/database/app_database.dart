import 'dart:convert';

import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Synchronization state for data the user may edit while offline.
enum SyncState { synced, pendingCreate, pendingUpdate, pendingDelete, failed }

/// Allowlisted diagnostics only. Never store responses, URLs, tokens, or notes.
enum SyncDiagnosticCode {
  networkUnavailable,
  validationRejected,
  retryExhausted,
}

enum OutboxOperation { upsert, delete }

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
  TextColumn get mediaId => text().references(LocalMediaAssets, #id)();
  TextColumn get verifiedLocalPath => text()();
  TextColumn get checksumSha256 => text()();
  IntColumn get byteSize => integer()();
  TextColumn get cacheState => text()();
  DateTimeColumn get lastAccessedAt => dateTime()();
  DateTimeColumn get verifiedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {mediaId};

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
  name: 'sync_outbox_owner_next_attempt',
  columns: {#ownerUserId, #nextAttemptAt},
)
class SyncOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get ownerUserId => text().references(LocalProfiles, #userId)();
  TextColumn get operation => textEnum<OutboxOperation>()();

  /// Versioned, allowlisted JSON for the trusted sync API; no raw responses.
  TextColumn get payloadJson => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<String> get customConstraints => [
    'UNIQUE(owner_user_id, entity_type, entity_id)',
  ];
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
    SyncOutbox,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await _createV2Tables(m);
      if (from < 3) await _migrateToV3(m);
      if (from < 4) await _migrateToV4(m);
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

/// Typed, entity-specific payloads are built from durable rows, never callers.
sealed class SyncPayload {
  const SyncPayload(this.entityType, this.entityId, this.operation);
  final String entityType;
  final String entityId;
  final OutboxOperation operation;
  Map<String, Object?> toJson();
}

final class CheckInSyncPayload extends SyncPayload {
  CheckInSyncPayload(this.row, this.bodyAreaKeys)
    : super('check_in', row.id, OutboxOperation.upsert);
  final LocalCheckIn row;
  final List<String> bodyAreaKeys;
  @override
  Map<String, Object?> toJson() => {
    'v': 1,
    'id': row.id,
    'bodyState': row.bodyState,
    'goalKey': row.goalKey,
    'availableMinutes': row.availableMinutes,
    'bodyAreaKeys': bodyAreaKeys,
  };
}

final class SavedRoutineSyncPayload extends SyncPayload {
  SavedRoutineSyncPayload(this.row)
    : super(
        'saved_routine',
        row.routineId,
        row.deletedAt == null ? OutboxOperation.upsert : OutboxOperation.delete,
      );
  final LocalSavedRoutine row;
  @override
  Map<String, Object?> toJson() => {
    'v': 1,
    'routineId': row.routineId,
    'deletedAt': row.deletedAt?.toIso8601String(),
  };
}

final class SessionSyncPayload extends SyncPayload {
  SessionSyncPayload(this.row, this.steps)
    : super('routine_session', row.id, OutboxOperation.upsert);
  final LocalRoutineSession row;
  final List<LocalSessionStep> steps;
  @override
  Map<String, Object?> toJson() => {
    'v': 1,
    'id': row.id,
    'routineId': row.routineId,
    'status': row.status,
    'actualDurationSeconds': row.actualDurationSeconds,
    'steps': [
      for (final step in steps)
        {
          'routineStepId': step.routineStepId,
          'status': step.status,
          'activeDurationSeconds': step.activeDurationSeconds,
        },
    ],
  };
}

final class RowSyncPayload extends SyncPayload {
  RowSyncPayload(String entityType, String entityId, this.fields)
    : super(entityType, entityId, OutboxOperation.upsert);
  final Map<String, Object?> fields;
  @override
  Map<String, Object?> toJson() => {'v': 1, ...fields};
}

/// Local-first private writes. One instance is bound to exactly one active user.
class LocalUserDataRepository {
  LocalUserDataRepository(
    this._database, {
    required this.activeUserId,
    DateTime Function()? clock,
  }) : _clock = clock ?? _unsupportedClock;
  final AppDatabase _database;
  final String activeUserId;
  final DateTime Function() _clock;
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
    final row = await (_database.select(
      _database.localCheckIns,
    )..where((r) => r.id.equals(checkIn.id.value))).getSingle();
    await _enqueue(CheckInSyncPayload(row, bodyAreaKeys.toList()));
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
    final row =
        await (_database.select(_database.localSavedRoutines)..where(
              (r) =>
                  r.userId.equals(activeUserId) &
                  r.routineId.equals(savedRoutine.routineId.value),
            ))
            .getSingle();
    await _enqueue(SavedRoutineSyncPayload(row));
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
    final row = await (_database.select(
      _database.localRoutineSessions,
    )..where((r) => r.id.equals(session.id.value))).getSingle();
    final rows = await (_database.select(
      _database.localSessionSteps,
    )..where((r) => r.sessionId.equals(session.id.value))).get();
    await _enqueue(SessionSyncPayload(row, rows));
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
    final row = await (_database.select(
      _database.localUserPreferences,
    )..where((r) => r.userId.equals(activeUserId))).getSingle();
    await _enqueue(
      RowSyncPayload('user_preferences', row.userId, {
        'userId': row.userId,
        'experienceLevel': row.experienceLevel,
        'soundEnabled': row.soundEnabled,
        'vibrationEnabled': row.vibrationEnabled,
        'downloadOnWifiOnly': row.downloadOnWifiOnly,
      }),
    );
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
    final row = await (_database.select(
      _database.localRecommendations,
    )..where((r) => r.id.equals(recommendation.id.value))).getSingle();
    await _enqueue(
      RowSyncPayload('recommendation', row.id, {
        'id': row.id,
        'checkInId': row.checkInId,
        'routineId': row.routineId,
        'engineVersion': row.engineVersion,
        'reasonCodes': row.reasonCodesJson,
      }),
    );
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
    final row = await (_database.select(
      _database.localSessionFeedback,
    )..where((r) => r.sessionId.equals(feedback.sessionId.value))).getSingle();
    await _enqueue(
      RowSyncPayload('session_feedback', row.sessionId, {
        'sessionId': row.sessionId,
        'rating': row.rating,
        'uncomfortableExerciseId': row.uncomfortableExerciseId,
      }),
    );
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
    final row = await (_database.select(
      _database.localReminderSchedules,
    )..where((r) => r.id.equals(reminder.id.value))).getSingle();
    await _enqueue(
      RowSyncPayload('reminder_schedule', row.id, {
        'id': row.id,
        'localTime': row.localTime,
        'daysOfWeek': row.daysOfWeekJson,
        'timezone': row.timezone,
        'enabled': row.enabled,
      }),
    );
  });

  Future<List<SyncOutboxData>> dueOutbox() =>
      (_database.select(_database.syncOutbox)
            ..where(
              (r) =>
                  r.ownerUserId.equals(activeUserId) &
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
        final row = await (_database.select(
          _database.localRoutineSessions,
        )..where((r) => r.id.equals(session.id))).getSingle();
        await _enqueue(SessionSyncPayload(row, steps));
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

  Future<void> _enqueue(SyncPayload payload) async {
    final now = _now();
    await (_database.delete(_database.syncOutbox)..where(
          (r) =>
              r.ownerUserId.equals(activeUserId) &
              r.entityType.equals(payload.entityType) &
              r.entityId.equals(payload.entityId),
        ))
        .go();
    await _database
        .into(_database.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            entityType: payload.entityType,
            entityId: payload.entityId,
            ownerUserId: activeUserId,
            operation: payload.operation,
            payloadJson: jsonEncode(payload.toJson()),
            nextAttemptAt: now,
            createdAt: now,
          ),
        );
  }
}
