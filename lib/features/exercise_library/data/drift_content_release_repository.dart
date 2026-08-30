import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:raha_move/core/database/app_database.dart';

import 'content_release_contract.dart';
import 'content_release_source.dart';
import 'semantic_version.dart';

/// Applies complete, compatible catalog snapshots to the local Drift cache.
///
/// A release is validated (contract version, canonical checksum, release
/// continuity, minimum app version, IDs, relationships, tombstones, and
/// content completeness) and then applied in a single transaction. The release
/// only becomes current after the whole transaction commits, so a corrupt or
/// interrupted release leaves the previous valid catalog and current release
/// untouched.
///
/// Retired rows are preserved (status is set to `retired`, never deleted) so
/// historical sessions can still resolve them, while the existing published
/// reads (`watchPublishedRoutines`, preferred-media lookup) exclude them.
final class ContentReleaseRepository {
  ContentReleaseRepository(this._database, {DateTime Function()? clock})
    : _clock = clock ?? _systemClock;

  static final RegExp _exercisePublicId = RegExp(r'^raha_ex_[a-z0-9_]+$');
  static final RegExp _routinePublicId = RegExp(r'^raha_rt_[a-z0-9_]+$');
  static final RegExp _sha256 = RegExp(r'^[a-f0-9]{64}$');
  static final RegExp _opaqueReference = RegExp(r'^[a-zA-Z0-9_-]+$');

  final AppDatabase _database;
  final DateTime Function() _clock;

  static DateTime _systemClock() => DateTime.now();

  Future<String?> currentReleaseId() async {
    final row = await (_database.select(
      _database.localContentReleases,
    )..where((r) => r.isCurrent.equals(true))).getSingleOrNull();
    return row?.id;
  }

  Future<bool> hasCurrentRelease() async => (await currentReleaseId()) != null;

  Future<LocalContentRelease?> currentRelease() => (_database.select(
    _database.localContentReleases,
  )..where((r) => r.isCurrent.equals(true))).getSingleOrNull();

  /// Validates and atomically applies [envelope]. Throws
  /// [ContentReleaseException] and leaves the database unchanged on failure.
  Future<void> applyRelease(
    ContentReleaseEnvelope envelope, {
    required String appVersion,
  }) {
    return _database.transaction(() async {
      final currentId = await currentReleaseId();
      _validate(envelope, currentReleaseId: currentId, appVersion: appVersion);
      await _apply(envelope);
    });
  }

  void _validate(
    ContentReleaseEnvelope envelope, {
    required String? currentReleaseId,
    required String appVersion,
  }) {
    final manifest = envelope.manifest;
    if (manifest.contractVersion != contentReleaseContractVersion) {
      throw const ContentReleaseException(
        'unsupported_contract_version',
        'Manifest contract version is not supported by this client',
      );
    }

    final computed = canonicalManifestChecksum(envelope.canonicalManifestBytes);
    if (computed != envelope.manifestChecksum.toLowerCase()) {
      throw const ContentReleaseException(
        'checksum_mismatch',
        'Canonical manifest checksum does not match the release record',
      );
    }

    final newSequence = _releaseSequence(envelope.releaseId);
    if (currentReleaseId != null) {
      final currentSequence = _releaseSequence(currentReleaseId);
      if (newSequence <= currentSequence) {
        throw const ContentReleaseException(
          'release_continuity',
          'Release is not newer than the currently applied release',
        );
      }
    }

    final minimum = SemanticVersion.tryParse(envelope.minimumAppVersion);
    final running = SemanticVersion.tryParse(appVersion);
    if (running == null) {
      throw const ContentReleaseException(
        'invalid_app_version',
        'The running app version is not a valid MAJOR.MINOR.PATCH value',
      );
    }
    if (minimum != null && minimum.compareTo(running) > 0) {
      throw const ContentReleaseException(
        'incompatible_app_version',
        'Release requires a newer app version',
      );
    }

    _validateManifest(manifest);
  }

  void _validateManifest(ContentReleaseManifest manifest) {
    final exerciseIds = <String>{};
    final exercisePublicIds = <String>{};
    for (final exercise in manifest.exercises) {
      if (!_exercisePublicId.hasMatch(exercise.publicId)) {
        throw ContentReleaseException('invalid_exercise_id', exercise.publicId);
      }
      if (!exerciseIds.add(exercise.id) ||
          !exercisePublicIds.add(exercise.publicId)) {
        throw ContentReleaseException(
          'duplicate_exercise_id',
          exercise.publicId,
        );
      }
      if (exercise.status != 'published') {
        throw ContentReleaseException(
          'unpublished_exercise',
          exercise.publicId,
        );
      }
      if (!exercise.safetyApproved) {
        throw ContentReleaseException('not_safety_approved', exercise.publicId);
      }
      _validateExerciseTranslations(
        manifest.exerciseTranslations
            .where((t) => t.exerciseId == exercise.id)
            .toList(),
        subject: exercise.publicId,
      );
      final media = manifest.mediaAssets
          .where((m) => m.exerciseId == exercise.id)
          .toList();
      final preferredPlayable = media
          .where(
            (m) =>
                m.isPreferred &&
                (m.mediaType == 'video' || m.mediaType == 'animation'),
          )
          .toList();
      if (preferredPlayable.length != 1) {
        throw ContentReleaseException(
          'missing_preferred_media',
          exercise.publicId,
        );
      }
      for (final asset in media) {
        _validateMediaAsset(asset);
      }
    }
    for (final translation in manifest.exerciseTranslations) {
      if (!exerciseIds.contains(translation.exerciseId)) {
        throw ContentReleaseException(
          'unknown_exercise',
          translation.exerciseId,
        );
      }
    }
    for (final asset in manifest.mediaAssets) {
      if (!exerciseIds.contains(asset.exerciseId)) {
        throw ContentReleaseException('unknown_exercise', asset.id);
      }
    }

    final routineIds = <String>{};
    final routinePublicIds = <String>{};
    for (final routine in manifest.routines) {
      if (!_routinePublicId.hasMatch(routine.publicId)) {
        throw ContentReleaseException('invalid_routine_id', routine.publicId);
      }
      if (!routineIds.add(routine.id) ||
          !routinePublicIds.add(routine.publicId)) {
        throw ContentReleaseException('duplicate_routine_id', routine.publicId);
      }
      if (routine.status != 'published') {
        throw ContentReleaseException('unpublished_routine', routine.publicId);
      }
      if (!routine.safetyApproved) {
        throw ContentReleaseException('not_safety_approved', routine.publicId);
      }
      if (routine.version <= 0) {
        throw ContentReleaseException(
          'invalid_routine_version',
          routine.publicId,
        );
      }
      if (routine.estimatedDurationSeconds <= 0) {
        throw ContentReleaseException(
          'invalid_routine_duration',
          routine.publicId,
        );
      }
      _validateRoutineTranslations(
        manifest.routineTranslations
            .where((t) => t.routineId == routine.id)
            .toList(),
        subject: routine.publicId,
        requireSummary: true,
      );
    }
    for (final translation in manifest.routineTranslations) {
      if (!routineIds.contains(translation.routineId)) {
        throw ContentReleaseException('unknown_routine', translation.routineId);
      }
    }

    final stepIds = <String>{};
    final positionsByRoutine = <String, Set<int>>{};
    for (final step in manifest.routineSteps) {
      if (!stepIds.add(step.id)) {
        throw ContentReleaseException('duplicate_step_id', step.id);
      }
      if (!routineIds.contains(step.routineId)) {
        throw ContentReleaseException('unknown_routine', step.routineId);
      }
      if (!exerciseIds.contains(step.exerciseId)) {
        throw ContentReleaseException('unknown_exercise', step.exerciseId);
      }
      if (step.position <= 0) {
        throw ContentReleaseException('invalid_step_position', step.id);
      }
      final positions = positionsByRoutine.putIfAbsent(
        step.routineId,
        () => {},
      );
      if (!positions.add(step.position)) {
        throw ContentReleaseException('duplicate_step_position', step.id);
      }
      // MVP routine steps are timed only; repetitions are deferred.
      if (step.durationSeconds == null ||
          step.durationSeconds! <= 0 ||
          step.repetitionCount != null) {
        throw ContentReleaseException('invalid_step_measure', step.id);
      }
      if (step.restAfterSeconds < 0) {
        throw ContentReleaseException('invalid_step_rest', step.id);
      }
    }

    for (final routine in manifest.routines) {
      final total = manifest.routineSteps
          .where((s) => s.routineId == routine.id)
          .fold<int>(0, (sum, s) => sum + (s.durationSeconds ?? 0));
      if (total != routine.estimatedDurationSeconds) {
        throw ContentReleaseException(
          'invalid_routine_duration',
          routine.publicId,
        );
      }
    }

    final taxonomyKeys = <String>{};
    for (final taxonomy in manifest.taxonomies) {
      if (!contentTaxonomyKinds.contains(taxonomy.kind)) {
        throw ContentReleaseException('invalid_taxonomy_kind', taxonomy.kind);
      }
      if (!taxonomyKeys.add(taxonomy.key)) {
        throw ContentReleaseException('duplicate_taxonomy_key', taxonomy.key);
      }
      _validateTaxonomyLabels(taxonomy);
    }

    final taxonomyUuids = manifest.taxonomyKeyByUuid;
    for (final assignment in [
      ...manifest.exerciseTaxonomies,
      ...manifest.routineTaxonomies,
    ]) {
      if (!taxonomyUuids.containsKey(assignment.taxonomyId)) {
        throw ContentReleaseException(
          'unknown_taxonomy',
          assignment.taxonomyId,
        );
      }
    }
    for (final assignment in manifest.exerciseTaxonomies) {
      if (!exerciseIds.contains(assignment.entityId)) {
        throw ContentReleaseException('unknown_exercise', assignment.entityId);
      }
    }
    for (final assignment in manifest.routineTaxonomies) {
      if (!routineIds.contains(assignment.entityId)) {
        throw ContentReleaseException('unknown_routine', assignment.entityId);
      }
    }

    for (final tombstone in manifest.tombstones) {
      if (!const {
        'exercise',
        'routine',
        'media_asset',
      }.contains(tombstone.entityType)) {
        throw ContentReleaseException(
          'invalid_tombstone',
          tombstone.entityType,
        );
      }
      if (tombstone.entityType == 'media_asset') {
        if (tombstone.entityId == null || tombstone.entityId!.isEmpty) {
          throw const ContentReleaseException(
            'invalid_tombstone',
            'Media tombstone requires an entity id',
          );
        }
      } else if (tombstone.entityPublicId == null ||
          tombstone.entityPublicId!.isEmpty) {
        throw const ContentReleaseException(
          'invalid_tombstone',
          'Catalog tombstone requires an entity public id',
        );
      }
    }
  }

  void _validateTaxonomyLabels(ManifestTaxonomy taxonomy) {
    for (final locale in const {'ar', 'en'}) {
      final label = taxonomy.labels[locale];
      if (label == null || label.trim().isEmpty) {
        throw ContentReleaseException('missing_translation', taxonomy.key);
      }
    }
  }

  void _validateExerciseTranslations(
    List<ManifestExerciseTranslation> translations, {
    required String subject,
  }) {
    final locales = <String>{};
    for (final translation in translations) {
      if (!const {'ar', 'en'}.contains(translation.locale)) {
        throw ContentReleaseException('invalid_locale', translation.locale);
      }
      locales.add(translation.locale);
      if (translation.name.trim().isEmpty) {
        throw ContentReleaseException('empty_localized_field', subject);
      }
    }
    if (!locales.contains('ar') || !locales.contains('en')) {
      throw ContentReleaseException('missing_translation', subject);
    }
  }

  void _validateRoutineTranslations(
    List<ManifestRoutineTranslation> translations, {
    required String subject,
    bool requireSummary = false,
  }) {
    final locales = <String>{};
    for (final translation in translations) {
      if (!const {'ar', 'en'}.contains(translation.locale)) {
        throw ContentReleaseException('invalid_locale', translation.locale);
      }
      locales.add(translation.locale);
      if (translation.name.trim().isEmpty ||
          (requireSummary && translation.summary.trim().isEmpty)) {
        throw ContentReleaseException('empty_localized_field', subject);
      }
    }
    if (!locales.contains('ar') || !locales.contains('en')) {
      throw ContentReleaseException('missing_translation', subject);
    }
  }

  void _validateMediaAsset(ManifestMediaAsset asset) {
    if (!_opaqueReference.hasMatch(asset.deliveryReference)) {
      throw ContentReleaseException('invalid_delivery_reference', asset.id);
    }
    switch (asset.status) {
      case 'published':
        final checksum = asset.checksumSha256;
        if (checksum == null || !_sha256.hasMatch(checksum)) {
          throw ContentReleaseException('invalid_media_checksum', asset.id);
        }
      case 'pending':
        // A pending asset reserves its delivery reference but must not claim a
        // checksum before the approved media asset is provided.
        if (asset.checksumSha256 != null) {
          throw ContentReleaseException('invalid_media_checksum', asset.id);
        }
      default:
        throw ContentReleaseException('invalid_media_status', asset.id);
    }
  }

  int _releaseSequence(String id) {
    final value = int.tryParse(id);
    if (value == null || value < 0) {
      throw ContentReleaseException('invalid_release_id', id);
    }
    return value;
  }

  Future<void> _apply(ContentReleaseEnvelope envelope) async {
    final manifest = envelope.manifest;
    final appliedAt = _clock().toUtc();

    // Taxonomies and labels.
    final taxonomyRows = <LocalTaxonomiesCompanion>[];
    final taxonomyTranslationRows = <LocalTaxonomyTranslationsCompanion>[];
    for (final taxonomy in manifest.taxonomies) {
      taxonomyRows.add(
        LocalTaxonomiesCompanion.insert(
          key: taxonomy.key,
          kind: taxonomy.kind,
          sortOrder: Value(taxonomy.sortOrder),
          isActive: Value(taxonomy.active),
        ),
      );
      for (final entry in taxonomy.labels.entries) {
        taxonomyTranslationRows.add(
          LocalTaxonomyTranslationsCompanion.insert(
            taxonomyKey: taxonomy.key,
            locale: entry.key,
            label: entry.value,
          ),
        );
      }
    }
    if (taxonomyRows.isNotEmpty) {
      await _database.batch(
        (b) => b.insertAllOnConflictUpdate(
          _database.localTaxonomies,
          taxonomyRows,
        ),
      );
    }
    if (taxonomyTranslationRows.isNotEmpty) {
      await _database.batch(
        (b) => b.insertAllOnConflictUpdate(
          _database.localTaxonomyTranslations,
          taxonomyTranslationRows,
        ),
      );
    }

    // Exercises + translations.
    final exerciseRows = <LocalExercisesCompanion>[];
    final exerciseTranslationRows = <LocalExerciseTranslationsCompanion>[];
    for (final exercise in manifest.exercises) {
      exerciseRows.add(
        LocalExercisesCompanion.insert(
          id: exercise.publicId,
          status: exercise.status,
          accessTier: exercise.accessTier,
          difficulty: exercise.difficulty,
          safetyApproved: exercise.safetyApproved,
          updatedAt: exercise.updatedAt ?? appliedAt,
        ),
      );
      for (final translation in manifest.exerciseTranslations.where(
        (t) => t.exerciseId == exercise.id,
      )) {
        exerciseTranslationRows.add(
          LocalExerciseTranslationsCompanion.insert(
            exerciseId: exercise.publicId,
            locale: translation.locale,
            name: translation.name,
            description: Value(translation.description),
            shortCue: Value(translation.shortCue),
          ),
        );
      }
    }
    if (exerciseRows.isNotEmpty) {
      await _database.batch(
        (b) =>
            b.insertAllOnConflictUpdate(_database.localExercises, exerciseRows),
      );
    }
    if (exerciseTranslationRows.isNotEmpty) {
      await _database.batch(
        (b) => b.insertAllOnConflictUpdate(
          _database.localExerciseTranslations,
          exerciseTranslationRows,
        ),
      );
    }

    // Media assets.
    final mediaRows = <LocalMediaAssetsCompanion>[];
    for (final asset in manifest.mediaAssets) {
      mediaRows.add(
        LocalMediaAssetsCompanion.insert(
          id: asset.id,
          exerciseId: manifest.exercisePublicIdByUuid[asset.exerciseId]!,
          mediaType: asset.mediaType,
          deliveryReference: asset.deliveryReference,
          mimeType: asset.mimeType,
          checksumSha256: asset.checksumSha256 ?? '',
          status: asset.status,
          isPreferred: Value(asset.isPreferred),
          width: Value(asset.width),
          height: Value(asset.height),
          durationMs: Value(asset.durationMs),
          updatedAt: asset.updatedAt ?? appliedAt,
        ),
      );
    }
    if (mediaRows.isNotEmpty) {
      await _database.batch(
        (b) =>
            b.insertAllOnConflictUpdate(_database.localMediaAssets, mediaRows),
      );
    }

    // Routines + translations + steps.
    final routineRows = <LocalRoutinesCompanion>[];
    final routineTranslationRows = <LocalRoutineTranslationsCompanion>[];
    final stepRows = <LocalRoutineStepsCompanion>[];
    for (final routine in manifest.routines) {
      routineRows.add(
        LocalRoutinesCompanion.insert(
          id: routine.publicId,
          status: 'published',
          accessTier: routine.accessTier,
          difficulty: routine.difficulty,
          estimatedDurationSeconds: routine.estimatedDurationSeconds,
          version: routine.version,
          updatedAt: routine.updatedAt ?? appliedAt,
        ),
      );
      for (final translation in manifest.routineTranslations.where(
        (t) => t.routineId == routine.id,
      )) {
        routineTranslationRows.add(
          LocalRoutineTranslationsCompanion.insert(
            routineId: routine.publicId,
            locale: translation.locale,
            name: translation.name,
            summary: translation.summary,
          ),
        );
      }
    }
    for (final step in manifest.routineSteps) {
      stepRows.add(
        LocalRoutineStepsCompanion.insert(
          id: step.id,
          routineId: manifest.routinePublicIdByUuid[step.routineId]!,
          exerciseId: manifest.exercisePublicIdByUuid[step.exerciseId]!,
          position: step.position,
          durationSeconds: step.durationSeconds!,
          restAfterSeconds: Value(step.restAfterSeconds),
          isOptional: Value(step.isOptional),
          status: const Value('published'),
        ),
      );
    }
    if (routineRows.isNotEmpty) {
      await _database.batch(
        (b) =>
            b.insertAllOnConflictUpdate(_database.localRoutines, routineRows),
      );
    }
    if (routineTranslationRows.isNotEmpty) {
      await _database.batch(
        (b) => b.insertAllOnConflictUpdate(
          _database.localRoutineTranslations,
          routineTranslationRows,
        ),
      );
    }
    if (stepRows.isNotEmpty) {
      await _database.batch(
        (b) =>
            b.insertAllOnConflictUpdate(_database.localRoutineSteps, stepRows),
      );
    }

    // Taxonomy assignments (reconciled to the manifest set for manifest parents).
    await _reconcileAssignments(manifest);

    // Snapshot retirement: anything still `published` but absent from the new
    // snapshot becomes `retired` (preserved for history, excluded from reads).
    await _retireAbsentPublished(manifest);

    // Explicit tombstones (belt-and-suspenders; the snapshot diff already
    // retires absent published rows, this also retires rows resolved by their
    // stable entity public id, or media UUID).
    await _applyTombstones(manifest);

    // Populate the stable local-id → server-UUID mapping boundary from this
    // release. This is the only place routine/exercise/taxonomy remote ids are
    // learned, so user-data sync can resolve them without guessing. It runs in
    // the same transaction, so a failed release rolls these back together with
    // the catalog.
    await _storeIdMappings(manifest);

    // Flip the current-release marker atomically.
    await (_database.update(_database.localContentReleases)
          ..where((r) => r.isCurrent.equals(true)))
        .write(const LocalContentReleasesCompanion(isCurrent: Value(false)));
    await _database
        .into(_database.localContentReleases)
        .insert(
          LocalContentReleasesCompanion.insert(
            id: envelope.releaseId,
            version: envelope.version,
            contractVersion: manifest.contractVersion,
            manifestChecksum: envelope.manifestChecksum.toLowerCase(),
            minimumAppVersion: Value(envelope.minimumAppVersion),
            publishedAt: Value(envelope.publishedAt),
            appliedAt: appliedAt,
            isCurrent: const Value(true),
          ),
        );
  }

  Future<void> _reconcileAssignments(ContentReleaseManifest manifest) async {
    final exerciseTaxonomyRows = <LocalExerciseTaxonomiesCompanion>[];
    for (final assignment in manifest.exerciseTaxonomies) {
      final publicId = manifest.exercisePublicIdByUuid[assignment.entityId];
      final key = manifest.taxonomyKeyByUuid[assignment.taxonomyId];
      if (publicId == null || key == null) continue;
      exerciseTaxonomyRows.add(
        LocalExerciseTaxonomiesCompanion.insert(
          exerciseId: publicId,
          taxonomyKey: key,
          relevanceWeight: Value(assignment.relevanceWeight),
        ),
      );
    }
    final manifestExercisePublicIds = manifest.exercises
        .map((e) => e.publicId)
        .toSet();
    if (manifestExercisePublicIds.isNotEmpty) {
      await (_database.delete(
        _database.localExerciseTaxonomies,
      )..where((r) => r.exerciseId.isIn(manifestExercisePublicIds))).go();
    }
    if (exerciseTaxonomyRows.isNotEmpty) {
      await _database.batch(
        (b) => b.insertAllOnConflictUpdate(
          _database.localExerciseTaxonomies,
          exerciseTaxonomyRows,
        ),
      );
    }

    final routineTaxonomyRows = <LocalRoutineTaxonomiesCompanion>[];
    for (final assignment in manifest.routineTaxonomies) {
      final publicId = manifest.routinePublicIdByUuid[assignment.entityId];
      final key = manifest.taxonomyKeyByUuid[assignment.taxonomyId];
      if (publicId == null || key == null) continue;
      routineTaxonomyRows.add(
        LocalRoutineTaxonomiesCompanion.insert(
          routineId: publicId,
          taxonomyKey: key,
          relevanceWeight: Value(assignment.relevanceWeight),
        ),
      );
    }
    final manifestRoutinePublicIds = manifest.routines
        .map((r) => r.publicId)
        .toSet();
    if (manifestRoutinePublicIds.isNotEmpty) {
      await (_database.delete(
        _database.localRoutineTaxonomies,
      )..where((r) => r.routineId.isIn(manifestRoutinePublicIds))).go();
    }
    if (routineTaxonomyRows.isNotEmpty) {
      await _database.batch(
        (b) => b.insertAllOnConflictUpdate(
          _database.localRoutineTaxonomies,
          routineTaxonomyRows,
        ),
      );
    }
  }

  Future<void> _retireAbsentPublished(ContentReleaseManifest manifest) async {
    await _retireAbsentExercises(
      manifest.exercises.map((e) => e.publicId).toSet(),
    );
    await _retireAbsentRoutines(
      manifest.routines.map((r) => r.publicId).toSet(),
    );
    await _retireAbsentMedia(manifest.mediaAssets.map((m) => m.id).toSet());
    await _retireAbsentSteps(manifest.routineSteps.map((s) => s.id).toSet());
  }

  Future<void> _retireAbsentExercises(Set<String> manifestIds) async {
    final published = await (_database.select(
      _database.localExercises,
    )..where((r) => r.status.equals('published'))).get();
    final absent = published
        .map((r) => r.id)
        .where((id) => !manifestIds.contains(id))
        .toSet();
    if (absent.isEmpty) return;
    await (_database.update(_database.localExercises)
          ..where((r) => r.id.isIn(absent)))
        .write(const LocalExercisesCompanion(status: Value('retired')));
  }

  Future<void> _retireAbsentRoutines(Set<String> manifestIds) async {
    final published = await (_database.select(
      _database.localRoutines,
    )..where((r) => r.status.equals('published'))).get();
    final absent = published
        .map((r) => r.id)
        .where((id) => !manifestIds.contains(id))
        .toSet();
    if (absent.isEmpty) return;
    await (_database.update(_database.localRoutines)
          ..where((r) => r.id.isIn(absent)))
        .write(const LocalRoutinesCompanion(status: Value('retired')));
  }

  Future<void> _retireAbsentMedia(Set<String> manifestIds) async {
    final published = await (_database.select(
      _database.localMediaAssets,
    )..where((r) => r.status.equals('published'))).get();
    final absent = published
        .map((r) => r.id)
        .where((id) => !manifestIds.contains(id))
        .toSet();
    if (absent.isEmpty) return;
    await (_database.update(_database.localMediaAssets)
          ..where((r) => r.id.isIn(absent)))
        .write(const LocalMediaAssetsCompanion(status: Value('retired')));
  }

  Future<void> _retireAbsentSteps(Set<String> manifestIds) async {
    final published = await (_database.select(
      _database.localRoutineSteps,
    )..where((r) => r.status.equals('published'))).get();
    final absent = published
        .map((r) => r.id)
        .where((id) => !manifestIds.contains(id))
        .toSet();
    if (absent.isEmpty) return;
    await (_database.update(_database.localRoutineSteps)
          ..where((r) => r.id.isIn(absent)))
        .write(const LocalRoutineStepsCompanion(status: Value('retired')));
  }

  /// Writes the remote-id mapping boundary for every entity and taxonomy in the
  /// release: `routine.publicId → routine.id`, `exercise.publicId →
  /// exercise.id`, and `taxonomy.key → taxonomy.id`. Idempotent upserts so a
  /// re-applied or corrected release updates the authoritative UUIDs.
  Future<void> _storeIdMappings(ContentReleaseManifest manifest) async {
    final rows = <LocalIdMappingsCompanion>[
      for (final exercise in manifest.exercises)
        LocalIdMappingsCompanion.insert(
          kind: RemoteIdMappingKind.exercise,
          localId: exercise.publicId,
          remoteId: exercise.id,
        ),
      for (final routine in manifest.routines)
        LocalIdMappingsCompanion.insert(
          kind: RemoteIdMappingKind.routine,
          localId: routine.publicId,
          remoteId: routine.id,
        ),
      for (final taxonomy in manifest.taxonomies)
        LocalIdMappingsCompanion.insert(
          kind: RemoteIdMappingKind.taxonomy,
          localId: taxonomy.key,
          remoteId: taxonomy.id,
        ),
    ];
    if (rows.isEmpty) return;
    await _database.batch(
      (b) => b.insertAllOnConflictUpdate(_database.localIdMappings, rows),
    );
  }

  Future<void> _applyTombstones(ContentReleaseManifest manifest) async {
    final exercisePublicIds = <String>{};
    final routinePublicIds = <String>{};
    final mediaIds = <String>{};
    for (final tombstone in manifest.tombstones) {
      if (tombstone.entityType == 'exercise') {
        final publicId = tombstone.entityPublicId;
        if (publicId != null) exercisePublicIds.add(publicId);
      } else if (tombstone.entityType == 'routine') {
        final publicId = tombstone.entityPublicId;
        if (publicId != null) routinePublicIds.add(publicId);
      } else if (tombstone.entityType == 'media_asset') {
        final id = tombstone.entityId;
        if (id != null) mediaIds.add(id);
      }
    }
    await _retireExerciseWhere(exercisePublicIds);
    await _retireRoutineWhere(routinePublicIds);
    await _retireMediaWhere(mediaIds);
  }

  Future<void> _retireExerciseWhere(Set<String> ids) async {
    if (ids.isEmpty) return;
    await (_database.update(_database.localExercises)
          ..where((r) => r.id.isIn(ids)))
        .write(const LocalExercisesCompanion(status: Value('retired')));
  }

  Future<void> _retireRoutineWhere(Set<String> ids) async {
    if (ids.isEmpty) return;
    await (_database.update(_database.localRoutines)
          ..where((r) => r.id.isIn(ids)))
        .write(const LocalRoutinesCompanion(status: Value('retired')));
  }

  Future<void> _retireMediaWhere(Set<String> ids) async {
    if (ids.isEmpty) return;
    await (_database.update(_database.localMediaAssets)
          ..where((r) => r.id.isIn(ids)))
        .write(const LocalMediaAssetsCompanion(status: Value('retired')));
  }
}
