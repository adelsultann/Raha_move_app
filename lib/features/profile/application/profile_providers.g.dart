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
    r'db1510fa24cdd6fae26a900257a2370559cc50a6';

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
    r'669868e0bc71d9b8df4fba46e9c918e40b08be6b';
