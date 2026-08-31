// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoutinePlayerState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutinePlayerState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoutinePlayerState()';
}


}

/// @nodoc
class $RoutinePlayerStateCopyWith<$Res>  {
$RoutinePlayerStateCopyWith(RoutinePlayerState _, $Res Function(RoutinePlayerState) __);
}


/// Adds pattern-matching-related methods to [RoutinePlayerState].
extension RoutinePlayerStatePatterns on RoutinePlayerState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RoutinePlayerLoading value)?  loading,TResult Function( RoutinePlayerFailed value)?  failed,TResult Function( RoutinePlayerReady value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RoutinePlayerLoading() when loading != null:
return loading(_that);case RoutinePlayerFailed() when failed != null:
return failed(_that);case RoutinePlayerReady() when ready != null:
return ready(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RoutinePlayerLoading value)  loading,required TResult Function( RoutinePlayerFailed value)  failed,required TResult Function( RoutinePlayerReady value)  ready,}){
final _that = this;
switch (_that) {
case RoutinePlayerLoading():
return loading(_that);case RoutinePlayerFailed():
return failed(_that);case RoutinePlayerReady():
return ready(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RoutinePlayerLoading value)?  loading,TResult? Function( RoutinePlayerFailed value)?  failed,TResult? Function( RoutinePlayerReady value)?  ready,}){
final _that = this;
switch (_that) {
case RoutinePlayerLoading() when loading != null:
return loading(_that);case RoutinePlayerFailed() when failed != null:
return failed(_that);case RoutinePlayerReady() when ready != null:
return ready(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function()?  failed,TResult Function( RoutinePlaybackSession session)?  ready,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RoutinePlayerLoading() when loading != null:
return loading();case RoutinePlayerFailed() when failed != null:
return failed();case RoutinePlayerReady() when ready != null:
return ready(_that.session);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function()  failed,required TResult Function( RoutinePlaybackSession session)  ready,}) {final _that = this;
switch (_that) {
case RoutinePlayerLoading():
return loading();case RoutinePlayerFailed():
return failed();case RoutinePlayerReady():
return ready(_that.session);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function()?  failed,TResult? Function( RoutinePlaybackSession session)?  ready,}) {final _that = this;
switch (_that) {
case RoutinePlayerLoading() when loading != null:
return loading();case RoutinePlayerFailed() when failed != null:
return failed();case RoutinePlayerReady() when ready != null:
return ready(_that.session);case _:
  return null;

}
}

}

/// @nodoc


class RoutinePlayerLoading implements RoutinePlayerState {
  const RoutinePlayerLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutinePlayerLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoutinePlayerState.loading()';
}


}




/// @nodoc


class RoutinePlayerFailed implements RoutinePlayerState {
  const RoutinePlayerFailed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutinePlayerFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoutinePlayerState.failed()';
}


}




/// @nodoc


class RoutinePlayerReady implements RoutinePlayerState {
  const RoutinePlayerReady({required this.session});
  

 final  RoutinePlaybackSession session;

/// Create a copy of RoutinePlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutinePlayerReadyCopyWith<RoutinePlayerReady> get copyWith => _$RoutinePlayerReadyCopyWithImpl<RoutinePlayerReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutinePlayerReady&&(identical(other.session, session) || other.session == session));
}


@override
int get hashCode => Object.hash(runtimeType,session);

@override
String toString() {
  return 'RoutinePlayerState.ready(session: $session)';
}


}

/// @nodoc
abstract mixin class $RoutinePlayerReadyCopyWith<$Res> implements $RoutinePlayerStateCopyWith<$Res> {
  factory $RoutinePlayerReadyCopyWith(RoutinePlayerReady value, $Res Function(RoutinePlayerReady) _then) = _$RoutinePlayerReadyCopyWithImpl;
@useResult
$Res call({
 RoutinePlaybackSession session
});


$RoutinePlaybackSessionCopyWith<$Res> get session;

}
/// @nodoc
class _$RoutinePlayerReadyCopyWithImpl<$Res>
    implements $RoutinePlayerReadyCopyWith<$Res> {
  _$RoutinePlayerReadyCopyWithImpl(this._self, this._then);

  final RoutinePlayerReady _self;
  final $Res Function(RoutinePlayerReady) _then;

/// Create a copy of RoutinePlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? session = null,}) {
  return _then(RoutinePlayerReady(
session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as RoutinePlaybackSession,
  ));
}

/// Create a copy of RoutinePlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutinePlaybackSessionCopyWith<$Res> get session {
  
  return $RoutinePlaybackSessionCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

// dart format on
