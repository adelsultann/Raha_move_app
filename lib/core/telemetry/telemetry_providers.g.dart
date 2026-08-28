// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The shared consent store. It starts disabled; the Profile settings flow
/// (RAHA-064) will replace the in-memory implementation with durable storage.

@ProviderFor(telemetryConsentStore)
final telemetryConsentStoreProvider = TelemetryConsentStoreProvider._();

/// The shared consent store. It starts disabled; the Profile settings flow
/// (RAHA-064) will replace the in-memory implementation with durable storage.

final class TelemetryConsentStoreProvider
    extends $FunctionalProvider<ConsentStore, ConsentStore, ConsentStore>
    with $Provider<ConsentStore> {
  /// The shared consent store. It starts disabled; the Profile settings flow
  /// (RAHA-064) will replace the in-memory implementation with durable storage.
  TelemetryConsentStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'telemetryConsentStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$telemetryConsentStoreHash();

  @$internal
  @override
  $ProviderElement<ConsentStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConsentStore create(Ref ref) {
    return telemetryConsentStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConsentStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConsentStore>(value),
    );
  }
}

String _$telemetryConsentStoreHash() =>
    r'cb067fab88e69e290870390a10143400a9a8c1cb';

/// The analytics service used by feature code. Enabled state is initialized
/// from consent and written back whenever the service is toggled, keeping
/// consent authoritative.

@ProviderFor(analyticsService)
final analyticsServiceProvider = AnalyticsServiceProvider._();

/// The analytics service used by feature code. Enabled state is initialized
/// from consent and written back whenever the service is toggled, keeping
/// consent authoritative.

final class AnalyticsServiceProvider
    extends
        $FunctionalProvider<
          AnalyticsService,
          AnalyticsService,
          AnalyticsService
        >
    with $Provider<AnalyticsService> {
  /// The analytics service used by feature code. Enabled state is initialized
  /// from consent and written back whenever the service is toggled, keeping
  /// consent authoritative.
  AnalyticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsServiceHash();

  @$internal
  @override
  $ProviderElement<AnalyticsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsService create(Ref ref) {
    return analyticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsService>(value),
    );
  }
}

String _$analyticsServiceHash() => r'ba554dfcd46b81488b61cf4ccfad165b39b1fa91';

/// The crash reporter used by feature code, gated by the separate
/// crash-reporting consent.

@ProviderFor(crashReporter)
final crashReporterProvider = CrashReporterProvider._();

/// The crash reporter used by feature code, gated by the separate
/// crash-reporting consent.

final class CrashReporterProvider
    extends $FunctionalProvider<CrashReporter, CrashReporter, CrashReporter>
    with $Provider<CrashReporter> {
  /// The crash reporter used by feature code, gated by the separate
  /// crash-reporting consent.
  CrashReporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crashReporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crashReporterHash();

  @$internal
  @override
  $ProviderElement<CrashReporter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CrashReporter create(Ref ref) {
    return crashReporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrashReporter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrashReporter>(value),
    );
  }
}

String _$crashReporterHash() => r'b7b263bdc1dd81e2dd6cc954aa73bbbefc6df7ea';

/// The privacy-safe logger. It defaults to a no-op sink so no diagnostic data
/// is retained or transmitted until a transport is approved.

@ProviderFor(appLogger)
final appLoggerProvider = AppLoggerProvider._();

/// The privacy-safe logger. It defaults to a no-op sink so no diagnostic data
/// is retained or transmitted until a transport is approved.

final class AppLoggerProvider
    extends $FunctionalProvider<AppLogger, AppLogger, AppLogger>
    with $Provider<AppLogger> {
  /// The privacy-safe logger. It defaults to a no-op sink so no diagnostic data
  /// is retained or transmitted until a transport is approved.
  AppLoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLoggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLoggerHash();

  @$internal
  @override
  $ProviderElement<AppLogger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLogger create(Ref ref) {
    return appLogger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLogger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLogger>(value),
    );
  }
}

String _$appLoggerHash() => r'18dbc5016c674485274ca511073c1b1d15457c11';
