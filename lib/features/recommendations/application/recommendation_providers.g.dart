// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The deterministic, on-device recommendation engine. Tests override this with
/// a fake when they want to isolate orchestration from scoring.

@ProviderFor(recommendationEngine)
final recommendationEngineProvider = RecommendationEngineProvider._();

/// The deterministic, on-device recommendation engine. Tests override this with
/// a fake when they want to isolate orchestration from scoring.

final class RecommendationEngineProvider
    extends
        $FunctionalProvider<
          RoutineRecommendationEngine,
          RoutineRecommendationEngine,
          RoutineRecommendationEngine
        >
    with $Provider<RoutineRecommendationEngine> {
  /// The deterministic, on-device recommendation engine. Tests override this with
  /// a fake when they want to isolate orchestration from scoring.
  RecommendationEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendationEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendationEngineHash();

  @$internal
  @override
  $ProviderElement<RoutineRecommendationEngine> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RoutineRecommendationEngine create(Ref ref) {
    return recommendationEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutineRecommendationEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutineRecommendationEngine>(value),
    );
  }
}

String _$recommendationEngineHash() =>
    r'1937bf3d7878547397722df018ad89308e3e30b3';

/// Local candidate catalog read from the Drift content cache.

@ProviderFor(recommendationCatalog)
final recommendationCatalogProvider = RecommendationCatalogProvider._();

/// Local candidate catalog read from the Drift content cache.

final class RecommendationCatalogProvider
    extends
        $FunctionalProvider<
          DriftRecommendationCatalog,
          DriftRecommendationCatalog,
          DriftRecommendationCatalog
        >
    with $Provider<DriftRecommendationCatalog> {
  /// Local candidate catalog read from the Drift content cache.
  RecommendationCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendationCatalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendationCatalogHash();

  @$internal
  @override
  $ProviderElement<DriftRecommendationCatalog> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriftRecommendationCatalog create(Ref ref) {
    return recommendationCatalog(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriftRecommendationCatalog value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriftRecommendationCatalog>(value),
    );
  }
}

String _$recommendationCatalogHash() =>
    r'2379b782d39b8bc8db2ba06be00b071b8a7f62f9';

/// Local recommendation-history inputs (recent completions and discomfort).

@ProviderFor(recommendationHistory)
final recommendationHistoryProvider = RecommendationHistoryProvider._();

/// Local recommendation-history inputs (recent completions and discomfort).

final class RecommendationHistoryProvider
    extends
        $FunctionalProvider<
          DriftRecommendationHistory,
          DriftRecommendationHistory,
          DriftRecommendationHistory
        >
    with $Provider<DriftRecommendationHistory> {
  /// Local recommendation-history inputs (recent completions and discomfort).
  RecommendationHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendationHistoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendationHistoryHash();

  @$internal
  @override
  $ProviderElement<DriftRecommendationHistory> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriftRecommendationHistory create(Ref ref) {
    return recommendationHistory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriftRecommendationHistory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriftRecommendationHistory>(value),
    );
  }
}

String _$recommendationHistoryHash() =>
    r'f6406fc23f1d9b7528075c610b07a66e579ac962';

/// Injectable recommendation persistence boundary, backed by the local Drift
/// database. Tests override this with an in-memory fake.

@ProviderFor(recommendationRepository)
final recommendationRepositoryProvider = RecommendationRepositoryProvider._();

/// Injectable recommendation persistence boundary, backed by the local Drift
/// database. Tests override this with an in-memory fake.

final class RecommendationRepositoryProvider
    extends
        $FunctionalProvider<
          RecommendationRepository,
          RecommendationRepository,
          RecommendationRepository
        >
    with $Provider<RecommendationRepository> {
  /// Injectable recommendation persistence boundary, backed by the local Drift
  /// database. Tests override this with an in-memory fake.
  RecommendationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendationRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecommendationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecommendationRepository create(Ref ref) {
    return recommendationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecommendationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecommendationRepository>(value),
    );
  }
}

String _$recommendationRepositoryHash() =>
    r'6216371105a2e49d8a077bb161a6da7f8f7defeb';

/// Localized routine display data read from the Drift content cache.

@ProviderFor(routinePresentationRepository)
final routinePresentationRepositoryProvider =
    RoutinePresentationRepositoryProvider._();

/// Localized routine display data read from the Drift content cache.

final class RoutinePresentationRepositoryProvider
    extends
        $FunctionalProvider<
          DriftRoutinePresentationRepository,
          DriftRoutinePresentationRepository,
          DriftRoutinePresentationRepository
        >
    with $Provider<DriftRoutinePresentationRepository> {
  /// Localized routine display data read from the Drift content cache.
  RoutinePresentationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routinePresentationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routinePresentationRepositoryHash();

  @$internal
  @override
  $ProviderElement<DriftRoutinePresentationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriftRoutinePresentationRepository create(Ref ref) {
    return routinePresentationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriftRoutinePresentationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriftRoutinePresentationRepository>(
        value,
      ),
    );
  }
}

String _$routinePresentationRepositoryHash() =>
    r'4b5075724393c16645cc7b69452dbcb1df6a87cc';

/// The localized presentation of one recommended routine, re-resolved whenever
/// the active locale changes.

@ProviderFor(routinePresentation)
final routinePresentationProvider = RoutinePresentationFamily._();

/// The localized presentation of one recommended routine, re-resolved whenever
/// the active locale changes.

final class RoutinePresentationProvider
    extends
        $FunctionalProvider<
          AsyncValue<RoutinePresentation>,
          RoutinePresentation,
          FutureOr<RoutinePresentation>
        >
    with
        $FutureModifier<RoutinePresentation>,
        $FutureProvider<RoutinePresentation> {
  /// The localized presentation of one recommended routine, re-resolved whenever
  /// the active locale changes.
  RoutinePresentationProvider._({
    required RoutinePresentationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'routinePresentationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$routinePresentationHash();

  @override
  String toString() {
    return r'routinePresentationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RoutinePresentation> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RoutinePresentation> create(Ref ref) {
    final argument = this.argument as String;
    return routinePresentation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RoutinePresentationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$routinePresentationHash() =>
    r'233dde7791ba56b1d90d9142468f50f186d890ce';

/// The localized presentation of one recommended routine, re-resolved whenever
/// the active locale changes.

final class RoutinePresentationFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RoutinePresentation>, String> {
  RoutinePresentationFamily._()
    : super(
        retry: null,
        name: r'routinePresentationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The localized presentation of one recommended routine, re-resolved whenever
  /// the active locale changes.

  RoutinePresentationProvider call(String routineId) =>
      RoutinePresentationProvider._(argument: routineId, from: this);

  @override
  String toString() => r'routinePresentationProvider';
}
