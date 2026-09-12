// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data_sync_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-owned, active-user sync trigger.
///
/// This is the single entry point callers use to run user-data synchronization
/// for the currently authenticated user. It is safe to call from authenticated
/// startup, connectivity recovery, and an explicit manual retry, because it
/// guards logout and account switch: when no user is signed in, or when the
/// live Supabase session no longer matches the active user, it returns `null`
/// without touching the backend or the outbox.

@ProviderFor(ActiveUserSyncCoordinator)
final activeUserSyncCoordinatorProvider = ActiveUserSyncCoordinatorProvider._();

/// App-owned, active-user sync trigger.
///
/// This is the single entry point callers use to run user-data synchronization
/// for the currently authenticated user. It is safe to call from authenticated
/// startup, connectivity recovery, and an explicit manual retry, because it
/// guards logout and account switch: when no user is signed in, or when the
/// live Supabase session no longer matches the active user, it returns `null`
/// without touching the backend or the outbox.
final class ActiveUserSyncCoordinatorProvider
    extends $NotifierProvider<ActiveUserSyncCoordinator, SyncCoordinatorState> {
  /// App-owned, active-user sync trigger.
  ///
  /// This is the single entry point callers use to run user-data synchronization
  /// for the currently authenticated user. It is safe to call from authenticated
  /// startup, connectivity recovery, and an explicit manual retry, because it
  /// guards logout and account switch: when no user is signed in, or when the
  /// live Supabase session no longer matches the active user, it returns `null`
  /// without touching the backend or the outbox.
  ActiveUserSyncCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeUserSyncCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeUserSyncCoordinatorHash();

  @$internal
  @override
  ActiveUserSyncCoordinator create() => ActiveUserSyncCoordinator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncCoordinatorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncCoordinatorState>(value),
    );
  }
}

String _$activeUserSyncCoordinatorHash() =>
    r'56b36c97344ff080111b28b98649ae31d959ab19';

/// App-owned, active-user sync trigger.
///
/// This is the single entry point callers use to run user-data synchronization
/// for the currently authenticated user. It is safe to call from authenticated
/// startup, connectivity recovery, and an explicit manual retry, because it
/// guards logout and account switch: when no user is signed in, or when the
/// live Supabase session no longer matches the active user, it returns `null`
/// without touching the backend or the outbox.

abstract class _$ActiveUserSyncCoordinator
    extends $Notifier<SyncCoordinatorState> {
  SyncCoordinatorState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SyncCoordinatorState, SyncCoordinatorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncCoordinatorState, SyncCoordinatorState>,
              SyncCoordinatorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
