import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/authentication/data/drift_guest_identity_store.dart';
import 'package:raha_move/features/home/home_providers.dart';
import 'package:raha_move/features/home/home_screen.dart';
import 'package:raha_move/features/home/my_library_screen.dart';
import 'package:raha_move/features/saved_routines/application/saved_routines_providers.dart';
import 'package:raha_move/features/sync/application/sync_providers.dart';

const exercise = HomeExercise(
  id: 'neck',
  name: 'Neck release',
  description: '',
  seconds: 30,
  area: 'neck',
  routineId: 'routine',
);

void main() {
  test(
    'v12 upgrade preserves data and exercise bookmarks survive restart',
    () async {
      final dir = await Directory.systemTemp.createTemp('raha_library_');
      final file = File('${dir.path}/app.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      try {
        await db
            .into(db.environmentEntries)
            .insert(
              EnvironmentEntriesCompanion.insert(
                key: 'existing',
                value: 'preserved',
              ),
            );
        await db.customStatement('DROP TABLE local_saved_exercises');
        await db.customStatement('PRAGMA user_version = 12');
        await db.close();
        db = AppDatabase(NativeDatabase(file));
        expect(
          (await db.select(db.environmentEntries).getSingle()).value,
          'preserved',
        );
        await db
            .into(db.localSavedExercises)
            .insert(
              LocalSavedExercisesCompanion.insert(
                userId: 'guest',
                exerciseId: 'neck',
                savedAt: DateTime.now(),
              ),
            );
        await db.close();
        db = AppDatabase(NativeDatabase(file));
        expect(
          (await db.select(db.localSavedExercises).getSingle()).exerciseId,
          'neck',
        );
      } finally {
        await db.close();
        await dir.delete(recursive: true);
      }
    },
  );

  test('guest exercise bookmarks follow account linking and are cleared on sign-out', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final store = DriftGuestIdentityStore(db, uuidGenerator: () => 'guest');
    await store.currentOrCreateGuestId();
    await store.ensureProfile('guest');
    await db
        .into(db.localSavedExercises)
        .insert(
          LocalSavedExercisesCompanion.insert(
            userId: 'guest',
            exerciseId: 'neck',
            savedAt: DateTime.now(),
          ),
        );
    await store.linkGuestToSupabaseUid(
      guestId: 'guest',
      supabaseUid: 'account',
    );
    expect(
      (await db.select(db.localSavedExercises).getSingle()).userId,
      'account',
    );
    await store.resetForSignOut();
    expect(await db.select(db.localSavedExercises).get(), isEmpty);
  });

  testWidgets('saving an exercise appears in My Library and can be removed', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeUserIdProvider.overrideWithValue('guest'),
          savedRoutinesProvider.overrideWith((ref) async => []),
          homeCatalogProvider.overrideWith(
            (ref) async => const HomeCatalog([exercise], {}),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: ExerciseTile(exercise: exercise),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const MyLibraryScreen(),
                      ),
                    ),
                    child: const Text('Open library'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('exercise_neck')));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save exercise'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.text('Remove from library'), findsOneWidget);
    Navigator.of(tester.element(find.byType(BottomSheet))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exercises'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('saved_exercise_neck')), findsOneWidget);
    await tester.tap(find.byTooltip('Remove from library'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('saved_exercise_neck')), findsNothing);
    expect(
      find.text('Save an exercise from Home to find it here.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
