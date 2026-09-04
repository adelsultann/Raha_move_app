// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exploreRepository)
final exploreRepositoryProvider = ExploreRepositoryProvider._();

final class ExploreRepositoryProvider
    extends
        $FunctionalProvider<
          ExploreRepository,
          ExploreRepository,
          ExploreRepository
        >
    with $Provider<ExploreRepository> {
  ExploreRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExploreRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExploreRepository create(Ref ref) {
    return exploreRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExploreRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExploreRepository>(value),
    );
  }
}

String _$exploreRepositoryHash() => r'f894de623c40e6baadf290e6a7a72220f017ef7a';

/// An overrideable locale boundary for Explore's cached catalog reads.

@ProviderFor(exploreLocale)
final exploreLocaleProvider = ExploreLocaleProvider._();

/// An overrideable locale boundary for Explore's cached catalog reads.

final class ExploreLocaleProvider
    extends $FunctionalProvider<Locale, Locale, Locale>
    with $Provider<Locale> {
  /// An overrideable locale boundary for Explore's cached catalog reads.
  ExploreLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreLocaleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreLocaleHash();

  @$internal
  @override
  $ProviderElement<Locale> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Locale create(Ref ref) {
    return exploreLocale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$exploreLocaleHash() => r'ab3c9b8c03291fbe78044d4df47d0b0508a02526';

@ProviderFor(exploreCategories)
final exploreCategoriesProvider = ExploreCategoriesProvider._();

final class ExploreCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExploreCategory>>,
          List<ExploreCategory>,
          FutureOr<List<ExploreCategory>>
        >
    with
        $FutureModifier<List<ExploreCategory>>,
        $FutureProvider<List<ExploreCategory>> {
  ExploreCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<ExploreCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExploreCategory>> create(Ref ref) {
    return exploreCategories(ref);
  }
}

String _$exploreCategoriesHash() => r'e750be21b372de6465c5397478ae4b2296cc69f7';

@ProviderFor(exploreRoutines)
final exploreRoutinesProvider = ExploreRoutinesFamily._();

final class ExploreRoutinesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExploreRoutineCard>>,
          List<ExploreRoutineCard>,
          FutureOr<List<ExploreRoutineCard>>
        >
    with
        $FutureModifier<List<ExploreRoutineCard>>,
        $FutureProvider<List<ExploreRoutineCard>> {
  ExploreRoutinesProvider._({
    required ExploreRoutinesFamily super.from,
    required ({String? context, ExploreFilters filters}) super.argument,
  }) : super(
         retry: null,
         name: r'exploreRoutinesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exploreRoutinesHash();

  @override
  String toString() {
    return r'exploreRoutinesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<ExploreRoutineCard>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExploreRoutineCard>> create(Ref ref) {
    final argument =
        this.argument as ({String? context, ExploreFilters filters});
    return exploreRoutines(
      ref,
      context: argument.context,
      filters: argument.filters,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExploreRoutinesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exploreRoutinesHash() => r'476a6b17ccb75d952dff3723e5439539f8a13592';

final class ExploreRoutinesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ExploreRoutineCard>>,
          ({String? context, ExploreFilters filters})
        > {
  ExploreRoutinesFamily._()
    : super(
        retry: null,
        name: r'exploreRoutinesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExploreRoutinesProvider call({
    String? context,
    required ExploreFilters filters,
  }) => ExploreRoutinesProvider._(
    argument: (context: context, filters: filters),
    from: this,
  );

  @override
  String toString() => r'exploreRoutinesProvider';
}

@ProviderFor(exploreRoutineDetails)
final exploreRoutineDetailsProvider = ExploreRoutineDetailsFamily._();

final class ExploreRoutineDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExploreRoutineDetails?>,
          ExploreRoutineDetails?,
          FutureOr<ExploreRoutineDetails?>
        >
    with
        $FutureModifier<ExploreRoutineDetails?>,
        $FutureProvider<ExploreRoutineDetails?> {
  ExploreRoutineDetailsProvider._({
    required ExploreRoutineDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'exploreRoutineDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exploreRoutineDetailsHash();

  @override
  String toString() {
    return r'exploreRoutineDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ExploreRoutineDetails?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExploreRoutineDetails?> create(Ref ref) {
    final argument = this.argument as String;
    return exploreRoutineDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExploreRoutineDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exploreRoutineDetailsHash() =>
    r'31155e5166190c50e0feb6fa97abd1b0ac17ca51';

final class ExploreRoutineDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ExploreRoutineDetails?>, String> {
  ExploreRoutineDetailsFamily._()
    : super(
        retry: null,
        name: r'exploreRoutineDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExploreRoutineDetailsProvider call(String routineId) =>
      ExploreRoutineDetailsProvider._(argument: routineId, from: this);

  @override
  String toString() => r'exploreRoutineDetailsProvider';
}
