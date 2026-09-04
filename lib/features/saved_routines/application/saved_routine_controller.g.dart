// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_routine_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SavedRoutineController)
final savedRoutineControllerProvider = SavedRoutineControllerFamily._();

final class SavedRoutineControllerProvider
    extends $AsyncNotifierProvider<SavedRoutineController, bool> {
  SavedRoutineControllerProvider._({
    required SavedRoutineControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'savedRoutineControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$savedRoutineControllerHash();

  @override
  String toString() {
    return r'savedRoutineControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SavedRoutineController create() => SavedRoutineController();

  @override
  bool operator ==(Object other) {
    return other is SavedRoutineControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savedRoutineControllerHash() =>
    r'cf408de81fdf350d513e8c8d912b55b630391676';

final class SavedRoutineControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SavedRoutineController,
          AsyncValue<bool>,
          bool,
          FutureOr<bool>,
          String
        > {
  SavedRoutineControllerFamily._()
    : super(
        retry: null,
        name: r'savedRoutineControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SavedRoutineControllerProvider call(String routineId) =>
      SavedRoutineControllerProvider._(argument: routineId, from: this);

  @override
  String toString() => r'savedRoutineControllerProvider';
}

abstract class _$SavedRoutineController extends $AsyncNotifier<bool> {
  late final _$args = ref.$arg as String;
  String get routineId => _$args;

  FutureOr<bool> build(String routineId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
