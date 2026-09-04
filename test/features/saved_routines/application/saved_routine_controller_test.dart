import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/core/telemetry/telemetry_providers.dart';
import 'package:raha_move/features/saved_routines/application/saved_routine_controller.dart';
import 'package:raha_move/features/saved_routines/application/saved_routines_providers.dart';
import 'package:raha_move/features/saved_routines/domain/saved_routine.dart';
import 'package:raha_move/features/saved_routines/domain/saved_routines_repository.dart';
import 'package:raha_move/features/sync/application/sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test(
    'optimistically toggles saved state and emits approved analytics',
    () async {
      final repository = _FakeSavedRoutinesRepository();
      final analytics = InMemoryAnalyticsService(enabled: true);
      final container = ProviderContainer(
        overrides: [
          activeUserIdProvider.overrideWithValue('user'),
          savedRoutinesRepositoryProvider.overrideWithValue(repository),
          analyticsServiceProvider.overrideWithValue(analytics),
        ],
      );
      addTearDown(container.dispose);

      await container.read(savedRoutineControllerProvider('routine').future);
      await container
          .read(savedRoutineControllerProvider('routine').notifier)
          .toggle();
      expect(
        container.read(savedRoutineControllerProvider('routine')).value,
        isTrue,
      );
      expect(repository.saveCalls, 1);
      expect(analytics.recordedEvents.single.properties, {
        'routine_id': 'routine',
        'saved': true,
      });

      await container
          .read(savedRoutineControllerProvider('routine').notifier)
          .toggle();
      expect(
        container.read(savedRoutineControllerProvider('routine')).value,
        isFalse,
      );
      expect(repository.unsaveCalls, 1);
    },
  );

  test(
    'serializes repeated save intent while the first mutation is pending',
    () async {
      final repository = _DelayedSavedRoutinesRepository();
      final analytics = InMemoryAnalyticsService(enabled: true);
      final container = ProviderContainer(
        overrides: [
          activeUserIdProvider.overrideWithValue('user'),
          savedRoutinesRepositoryProvider.overrideWithValue(repository),
          analyticsServiceProvider.overrideWithValue(analytics),
        ],
      );
      addTearDown(container.dispose);

      await container.read(savedRoutineControllerProvider('routine').future);
      final controller = container.read(
        savedRoutineControllerProvider('routine').notifier,
      );
      final first = controller.toggle();
      final repeated = controller.toggle();
      expect(
        container.read(savedRoutineControllerProvider('routine')).isLoading,
        isTrue,
      );
      expect(repository.saveCalls, 1);

      repository.completeSave();
      await Future.wait([first, repeated]);
      expect(
        container.read(savedRoutineControllerProvider('routine')).value,
        isTrue,
      );
      expect(repository.unsaveCalls, 0);
      expect(analytics.recordedEvents, hasLength(1));
      expect(analytics.recordedEvents.single.properties['saved'], isTrue);
    },
  );
}

class _FakeSavedRoutinesRepository implements SavedRoutinesRepository {
  bool saved = false;
  int saveCalls = 0;
  int unsaveCalls = 0;
  @override
  Future<bool> isSaved({
    required String userId,
    required String routineId,
  }) async => saved;
  @override
  Future<List<SavedRoutine>> list({
    required String userId,
    required String locale,
  }) async => const [];
  @override
  Future<void> save({required String userId, required String routineId}) async {
    saveCalls++;
    saved = true;
  }

  @override
  Future<void> unsave({
    required String userId,
    required String routineId,
  }) async {
    unsaveCalls++;
    saved = false;
  }
}

class _DelayedSavedRoutinesRepository extends _FakeSavedRoutinesRepository {
  final Completer<void> _saveCompleter = Completer<void>();

  @override
  Future<void> save({required String userId, required String routineId}) async {
    saveCalls++;
    await _saveCompleter.future;
    saved = true;
  }

  void completeSave() => _saveCompleter.complete();
}
