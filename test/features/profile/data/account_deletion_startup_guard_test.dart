import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/bootstrap/supabase_bootstrap.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/profile/data/account_deletion_startup_guard.dart';

void main() {
  test('permits normal startup without a deletion marker', () async {
    var cleared = false;
    final guard = AccountDeletionStartupGuard(
      hasPendingCleanup: () async => false,
      clearPersistedSession: () async => cleared = true,
    );

    expect(await guard.permitsSupabaseInitialization(), isTrue);
    expect(cleared, isFalse);
  });

  test(
    'fails closed and clears credentials before SDK initialization',
    () async {
      final events = <String>[];
      final guard = AccountDeletionStartupGuard(
        hasPendingCleanup: () async {
          events.add('marker_checked');
          return true;
        },
        clearPersistedSession: () async => events.add('session_cleared'),
      );

      final mayInitialize = await guard.permitsSupabaseInitialization();

      expect(mayInitialize, isFalse);
      expect(events, ['marker_checked', 'session_cleared']);
    },
  );

  test(
    'never invokes Supabase initialization when cleanup is pending',
    () async {
      final events = <String>[];
      await initializeSupabaseAfterDeletionPreflight(
        deletionGuard: AccountDeletionStartupGuard(
          hasPendingCleanup: () async {
            events.add('marker_checked');
            return true;
          },
          clearPersistedSession: () async => events.add('session_cleared'),
        ),
        initialize: () async => events.add('supabase_initialized'),
      );

      expect(events, ['marker_checked', 'session_cleared']);
    },
  );

  test('initializes Supabase after a clean marker preflight', () async {
    final events = <String>[];
    await initializeSupabaseAfterDeletionPreflight(
      deletionGuard: AccountDeletionStartupGuard(
        hasPendingCleanup: () async {
          events.add('marker_checked');
          return false;
        },
        clearPersistedSession: () async => events.add('session_cleared'),
      ),
      initialize: () async => events.add('supabase_initialized'),
    );

    expect(events, ['marker_checked', 'supabase_initialized']);
  });

  test('fails closed when durable marker inspection cannot complete', () async {
    var clearCalled = false;
    final guard = AccountDeletionStartupGuard(
      hasPendingCleanup: () => throw StateError('database unavailable'),
      clearPersistedSession: () async => clearCalled = true,
    );

    expect(await guard.permitsSupabaseInitialization(), isFalse);
    expect(clearCalled, isFalse);
  });

  test('recognizes only durable accepted-deletion markers', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.environmentEntries)
        .insert(
          EnvironmentEntriesCompanion.insert(
            key: 'account_deletion_cleanup_user',
            value: 'pending',
          ),
        );

    expect(await hasPendingAccountDeletionCleanup(database), isTrue);
  });
}
