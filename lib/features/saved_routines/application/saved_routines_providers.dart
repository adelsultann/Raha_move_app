import 'dart:ui' show Locale;

import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/features/onboarding/application/locale_controller.dart';
import 'package:raha_move/features/sync/application/sync_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/drift_saved_routines_repository.dart';
import '../domain/saved_routine.dart';
import '../domain/saved_routines_repository.dart';

part 'saved_routines_providers.g.dart';

@Riverpod(keepAlive: true)
SavedRoutinesRepository savedRoutinesRepository(Ref ref) =>
    DriftSavedRoutinesRepository(ref.watch(appDatabaseProvider));

@riverpod
Locale savedRoutinesLocale(Ref ref) =>
    ref.watch(localeControllerProvider).value ?? const Locale('en');

@riverpod
Future<List<SavedRoutine>> savedRoutines(Ref ref) {
  final userId = ref.watch(activeUserIdProvider);
  if (userId == null) return Future.error(StateError('Missing active user.'));
  return ref
      .watch(savedRoutinesRepositoryProvider)
      .list(
        userId: userId,
        locale: ref.watch(savedRoutinesLocaleProvider).languageCode,
      );
}
