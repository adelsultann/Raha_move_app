// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(progressRepository)
final progressRepositoryProvider = ProgressRepositoryProvider._();

final class ProgressRepositoryProvider
    extends
        $FunctionalProvider<
          ProgressRepository,
          ProgressRepository,
          ProgressRepository
        >
    with $Provider<ProgressRepository> {
  ProgressRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProgressRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProgressRepository create(Ref ref) {
    return progressRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgressRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgressRepository>(value),
    );
  }
}

String _$progressRepositoryHash() =>
    r'3629c95daa124a569b98b79d7c1f14ad862db1ad';

@ProviderFor(progressNow)
final progressNowProvider = ProgressNowProvider._();

final class ProgressNowProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  ProgressNowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressNowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressNowHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return progressNow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$progressNowHash() => r'f253bbbc41ecf4570e00ea88a7379f4dbc10630a';

/// Re-emits when a profile timezone changes. An injected clock makes a week
/// boundary deterministic and callers can invalidate this provider on resume.

@ProviderFor(localCurrentProgressWeek)
final localCurrentProgressWeekProvider = LocalCurrentProgressWeekProvider._();

/// Re-emits when a profile timezone changes. An injected clock makes a week
/// boundary deterministic and callers can invalidate this provider on resume.

final class LocalCurrentProgressWeekProvider
    extends
        $FunctionalProvider<
          AsyncValue<MovementDate>,
          MovementDate,
          Stream<MovementDate>
        >
    with $FutureModifier<MovementDate>, $StreamProvider<MovementDate> {
  /// Re-emits when a profile timezone changes. An injected clock makes a week
  /// boundary deterministic and callers can invalidate this provider on resume.
  LocalCurrentProgressWeekProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localCurrentProgressWeekProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localCurrentProgressWeekHash();

  @$internal
  @override
  $StreamProviderElement<MovementDate> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MovementDate> create(Ref ref) {
    return localCurrentProgressWeek(ref);
  }
}

String _$localCurrentProgressWeekHash() =>
    r'e09b656031ecc62673dfe35a1cfa1b7bf355e3f9';

@ProviderFor(progressSummary)
final progressSummaryProvider = ProgressSummaryFamily._();

final class ProgressSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgressSummary>,
          ProgressSummary,
          Stream<ProgressSummary>
        >
    with $FutureModifier<ProgressSummary>, $StreamProvider<ProgressSummary> {
  ProgressSummaryProvider._({
    required ProgressSummaryFamily super.from,
    required MovementDate super.argument,
  }) : super(
         retry: null,
         name: r'progressSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$progressSummaryHash();

  @override
  String toString() {
    return r'progressSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ProgressSummary> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ProgressSummary> create(Ref ref) {
    final argument = this.argument as MovementDate;
    return progressSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgressSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$progressSummaryHash() => r'808c03fac965b5b189d2bb48dbc729b9c2f899d0';

final class ProgressSummaryFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ProgressSummary>, MovementDate> {
  ProgressSummaryFamily._()
    : super(
        retry: null,
        name: r'progressSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgressSummaryProvider call(MovementDate weekStart) =>
      ProgressSummaryProvider._(argument: weekStart, from: this);

  @override
  String toString() => r'progressSummaryProvider';
}
