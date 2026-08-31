import 'dart:ui' show Locale;

import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../onboarding/application/locale_controller.dart';
import '../data/drift_recommendation_catalog.dart';
import '../data/drift_recommendation_history.dart';
import '../data/drift_recommendation_repository.dart';
import '../data/drift_routine_presentation_repository.dart';
import '../domain/recommendation_engine.dart';
import '../domain/recommendation_repository.dart';
import '../domain/routine_presentation.dart';
import '../domain/rules_recommendation_engine.dart';
import 'recommendation_controller.dart';

part 'recommendation_providers.g.dart';

/// The deterministic, on-device recommendation engine. Tests override this with
/// a fake when they want to isolate orchestration from scoring.
@Riverpod(keepAlive: true)
RoutineRecommendationEngine recommendationEngine(Ref ref) =>
    const RulesRecommendationEngine();

/// Local candidate catalog read from the Drift content cache.
@Riverpod(keepAlive: true)
DriftRecommendationCatalog recommendationCatalog(Ref ref) =>
    DriftRecommendationCatalog(ref.watch(appDatabaseProvider));

/// Local recommendation-history inputs (recent completions and discomfort).
@Riverpod(keepAlive: true)
DriftRecommendationHistory recommendationHistory(Ref ref) =>
    DriftRecommendationHistory(ref.watch(appDatabaseProvider));

/// Injectable recommendation persistence boundary, backed by the local Drift
/// database. Tests override this with an in-memory fake.
@Riverpod(keepAlive: true)
RecommendationRepository recommendationRepository(Ref ref) =>
    DriftRecommendationRepository(ref.watch(appDatabaseProvider));

/// Localized routine display data read from the Drift content cache.
@Riverpod(keepAlive: true)
DriftRoutinePresentationRepository routinePresentationRepository(Ref ref) =>
    DriftRoutinePresentationRepository(ref.watch(appDatabaseProvider));

/// The localized presentation of one recommended routine, re-resolved whenever
/// the active locale changes.
@riverpod
Future<RoutinePresentation> routinePresentation(
  Ref ref,
  String routineId,
) async {
  final locale =
      ref.watch(localeControllerProvider).value ?? const Locale('en');
  final presentation = await ref
      .read(routinePresentationRepositoryProvider)
      .load(routineId, locale.languageCode);
  if (presentation == null) {
    throw const RecommendationUnavailableException();
  }
  return presentation;
}
