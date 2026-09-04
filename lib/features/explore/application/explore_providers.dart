import 'dart:ui' show Locale;

import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/features/onboarding/application/locale_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/drift_explore_repository.dart';
import '../domain/explore_models.dart';

part 'explore_providers.g.dart';

@Riverpod(keepAlive: true)
ExploreRepository exploreRepository(Ref ref) =>
    DriftExploreRepository(ref.watch(appDatabaseProvider));

/// An overrideable locale boundary for Explore's cached catalog reads.
@riverpod
Locale exploreLocale(Ref ref) =>
    ref.watch(localeControllerProvider).value ?? const Locale('en');

@riverpod
Future<List<ExploreCategory>> exploreCategories(Ref ref) {
  final locale = ref.watch(exploreLocaleProvider);
  return ref.read(exploreRepositoryProvider).categories(locale.languageCode);
}

@riverpod
Future<List<ExploreRoutineCard>> exploreRoutines(
  Ref ref, {
  String? context,
  required ExploreFilters filters,
}) {
  final locale = ref.watch(exploreLocaleProvider);
  return ref
      .read(exploreRepositoryProvider)
      .browse(locale: locale.languageCode, context: context, filters: filters);
}

@riverpod
Future<ExploreRoutineDetails?> exploreRoutineDetails(
  Ref ref,
  String routineId,
) {
  final locale = ref.watch(exploreLocaleProvider);
  return ref
      .read(exploreRepositoryProvider)
      .details(routineId, locale.languageCode);
}
