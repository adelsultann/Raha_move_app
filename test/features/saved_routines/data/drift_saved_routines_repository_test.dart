import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/saved_routines/data/drift_saved_routines_repository.dart';

void main() {
  late AppDatabase database;
  late DriftSavedRoutinesRepository repository;
  final now = DateTime.utc(2026, 9, 4, 10);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftSavedRoutinesRepository(database, clock: () => now);
    await _seed(database, now);
  });
  tearDown(() => database.close());

  test('save is immediate, atomic, and idempotent', () async {
    await repository.save(userId: 'user', routineId: 'available');
    await repository.save(userId: 'user', routineId: 'available');

    expect(
      await repository.isSaved(userId: 'user', routineId: 'available'),
      isTrue,
    );
    expect(
      await (database.select(
        database.localSavedRoutines,
      )..where((row) => row.routineId.equals('available'))).get(),
      hasLength(1),
    );
    expect(
      await (database.select(
        database.syncOutbox,
      )..where((row) => row.entityType.equals('saved_routine'))).get(),
      hasLength(1),
    );
  });

  test('unsave writes a tombstone and is idempotent', () async {
    await repository.save(userId: 'user', routineId: 'available');
    await repository.unsave(userId: 'user', routineId: 'available');
    await repository.unsave(userId: 'user', routineId: 'available');

    expect(
      await repository.isSaved(userId: 'user', routineId: 'available'),
      isFalse,
    );
    final row = await (database.select(
      database.localSavedRoutines,
    )..where((row) => row.routineId.equals('available'))).getSingle();
    expect(row.deletedAt!.toUtc(), now);
  });

  test('re-save clears its tombstone and queues saved true', () async {
    await repository.save(userId: 'user', routineId: 'available');
    await repository.unsave(userId: 'user', routineId: 'available');
    await repository.save(userId: 'user', routineId: 'available');

    final saved = await (database.select(
      database.localSavedRoutines,
    )..where((row) => row.routineId.equals('available'))).getSingle();
    expect(saved.deletedAt, isNull);
    expect(
      await repository.isSaved(userId: 'user', routineId: 'available'),
      isTrue,
    );
    final outbox = await (database.select(
      database.syncOutbox,
    )..where((row) => row.entityType.equals('saved_routine'))).getSingle();
    expect(jsonDecode(outbox.payloadJson), containsPair('saved', true));
  });

  test(
    'keeps retired saved routine visible but unavailable with localized title',
    () async {
      await repository.save(userId: 'user', routineId: 'available');
      await database
          .into(database.localSavedRoutines)
          .insert(
            LocalSavedRoutinesCompanion.insert(
              userId: 'user',
              routineId: 'retired',
              savedAt: now.add(const Duration(minutes: 1)),
              localUpdatedAt: now,
            ),
          );

      final items = await repository.list(userId: 'user', locale: 'ar');
      expect(items.first.title, 'روتين متوقف');
      expect(items.first.isPlayable, isFalse);
      expect(items.last.isPlayable, isTrue);
    },
  );
}

Future<void> _seed(AppDatabase database, DateTime now) async {
  await database
      .into(database.localProfiles)
      .insert(
        LocalProfilesCompanion.insert(
          userId: 'user',
          preferredLocale: 'en',
          timezone: 'Asia/Riyadh',
          weeklyGoalDays: 3,
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localIdMappings)
      .insert(
        LocalIdMappingsCompanion.insert(
          kind: RemoteIdMappingKind.routine,
          localId: 'available',
          remoteId: '00000000-0000-4000-8000-000000000001',
        ),
      );
  await database
      .into(database.localExercises)
      .insert(
        LocalExercisesCompanion.insert(
          id: 'exercise',
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          safetyApproved: true,
          updatedAt: now,
        ),
      );
  await database
      .into(database.localExerciseTranslations)
      .insert(
        LocalExerciseTranslationsCompanion.insert(
          exerciseId: 'exercise',
          locale: 'en',
          name: 'Reach',
        ),
      );
  await database
      .into(database.localMediaAssets)
      .insert(
        LocalMediaAssetsCompanion.insert(
          id: 'media',
          exerciseId: 'exercise',
          mediaType: 'video',
          deliveryReference: 'media_ref',
          mimeType: 'video/mp4',
          checksumSha256: 'a' * 64,
          status: 'published',
          updatedAt: now,
        ),
      );
  for (final (id, status) in const [
    ('available', 'published'),
    ('retired', 'retired'),
  ]) {
    await database
        .into(database.localRoutines)
        .insert(
          LocalRoutinesCompanion.insert(
            id: id,
            status: status,
            accessTier: 'free',
            difficulty: 'beginner',
            estimatedDurationSeconds: 60,
            version: 1,
            updatedAt: now,
          ),
        );
    await database.batch(
      (batch) => batch.insertAll(database.localRoutineTranslations, [
        LocalRoutineTranslationsCompanion.insert(
          routineId: id,
          locale: 'en',
          name: id == 'retired' ? 'Retired routine' : 'Available routine',
          summary: 'Summary',
        ),
        LocalRoutineTranslationsCompanion.insert(
          routineId: id,
          locale: 'ar',
          name: id == 'retired' ? 'روتين متوقف' : 'روتين متاح',
          summary: 'ملخص',
        ),
      ]),
    );
  }
  await database
      .into(database.localRoutineSteps)
      .insert(
        LocalRoutineStepsCompanion.insert(
          id: 'step',
          routineId: 'available',
          exerciseId: 'exercise',
          position: 1,
          durationSeconds: 60,
          status: const Value('published'),
        ),
      );
}
