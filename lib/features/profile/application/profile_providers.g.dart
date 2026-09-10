// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'9f979afb3a9ca342b2a8f56235f5efc5fab09483';

@ProviderFor(accountDeletionAction)
final accountDeletionActionProvider = AccountDeletionActionProvider._();

final class AccountDeletionActionProvider
    extends
        $FunctionalProvider<
          AccountDeletionAction,
          AccountDeletionAction,
          AccountDeletionAction
        >
    with $Provider<AccountDeletionAction> {
  AccountDeletionActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountDeletionActionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountDeletionActionHash();

  @$internal
  @override
  $ProviderElement<AccountDeletionAction> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountDeletionAction create(Ref ref) {
    return accountDeletionAction(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountDeletionAction value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountDeletionAction>(value),
    );
  }
}

String _$accountDeletionActionHash() =>
    r'c86483b8c94a4a3713f9ea77545ae87f6f015069';

@ProviderFor(accountDeletionRecovery)
final accountDeletionRecoveryProvider = AccountDeletionRecoveryProvider._();

final class AccountDeletionRecoveryProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccountDeletionCleanupResult>,
          AccountDeletionCleanupResult,
          FutureOr<AccountDeletionCleanupResult>
        >
    with
        $FutureModifier<AccountDeletionCleanupResult>,
        $FutureProvider<AccountDeletionCleanupResult> {
  AccountDeletionRecoveryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountDeletionRecoveryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountDeletionRecoveryHash();

  @$internal
  @override
  $FutureProviderElement<AccountDeletionCleanupResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AccountDeletionCleanupResult> create(Ref ref) {
    return accountDeletionRecovery(ref);
  }
}

String _$accountDeletionRecoveryHash() =>
    r'304524864efc944fb5bcd7eb07878f495da0ac1e';
