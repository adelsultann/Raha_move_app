import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_event.dart';
import 'package:raha_move/core/telemetry/telemetry_providers.dart';
import 'package:raha_move/features/sync/application/sync_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'saved_routines_providers.dart';

part 'saved_routine_controller.g.dart';

@riverpod
class SavedRoutineController extends _$SavedRoutineController {
  bool _isMutating = false;

  @override
  Future<bool> build(String routineId) async {
    final userId = ref.watch(activeUserIdProvider);
    if (userId == null) throw StateError('Missing active user.');
    return ref
        .watch(savedRoutinesRepositoryProvider)
        .isSaved(userId: userId, routineId: routineId);
  }

  Future<void> toggle() async {
    // A save intent is serialized per routine. In particular, two rapid taps
    // must not reinterpret the optimistic first save as an unsave.
    if (_isMutating) return;
    final userId = ref.read(activeUserIdProvider);
    if (userId == null) {
      state = AsyncError(
        StateError('Missing active user.'),
        StackTrace.current,
      );
      return;
    }
    final wasSaved = state.value ?? false;
    _isMutating = true;
    state = const AsyncLoading<bool>();
    try {
      final repository = ref.read(savedRoutinesRepositoryProvider);
      if (wasSaved) {
        await repository.unsave(userId: userId, routineId: routineId);
      } else {
        await repository.save(userId: userId, routineId: routineId);
      }
      ref.invalidate(savedRoutinesProvider);
      final analytics = ref.read(analyticsServiceProvider);
      if (analytics.isEnabled) {
        analytics.track(
          AnalyticsEvent(
            name: AnalyticsEventName.savedRoutineChanged,
            properties: {
              AnalyticsPropertyKey.routineId: routineId,
              AnalyticsPropertyKey.saved: !wasSaved,
            },
          ),
        );
      }
      state = AsyncData(!wasSaved);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _isMutating = false;
    }
  }
}
