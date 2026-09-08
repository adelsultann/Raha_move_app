// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileController)
final profileControllerProvider = ProfileControllerProvider._();

final class ProfileControllerProvider
    extends $AsyncNotifierProvider<ProfileController, ProfileSettings> {
  ProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @$internal
  @override
  ProfileController create() => ProfileController();
}

String _$profileControllerHash() => r'0574a36cf36b332ddce5a3d8825c2831fef3e159';

abstract class _$ProfileController extends $AsyncNotifier<ProfileSettings> {
  FutureOr<ProfileSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ProfileSettings>, ProfileSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ProfileSettings>, ProfileSettings>,
              AsyncValue<ProfileSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
