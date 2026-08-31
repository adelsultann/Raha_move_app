// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_player_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoutinePlayerArgs {

 String get routineId; String? get recommendationId;
/// Create a copy of RoutinePlayerArgs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutinePlayerArgsCopyWith<RoutinePlayerArgs> get copyWith => _$RoutinePlayerArgsCopyWithImpl<RoutinePlayerArgs>(this as RoutinePlayerArgs, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutinePlayerArgs&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.recommendationId, recommendationId) || other.recommendationId == recommendationId));
}


@override
int get hashCode => Object.hash(runtimeType,routineId,recommendationId);

@override
String toString() {
  return 'RoutinePlayerArgs(routineId: $routineId, recommendationId: $recommendationId)';
}


}

/// @nodoc
abstract mixin class $RoutinePlayerArgsCopyWith<$Res>  {
  factory $RoutinePlayerArgsCopyWith(RoutinePlayerArgs value, $Res Function(RoutinePlayerArgs) _then) = _$RoutinePlayerArgsCopyWithImpl;
@useResult
$Res call({
 String routineId, String? recommendationId
});




}
/// @nodoc
class _$RoutinePlayerArgsCopyWithImpl<$Res>
    implements $RoutinePlayerArgsCopyWith<$Res> {
  _$RoutinePlayerArgsCopyWithImpl(this._self, this._then);

  final RoutinePlayerArgs _self;
  final $Res Function(RoutinePlayerArgs) _then;

/// Create a copy of RoutinePlayerArgs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routineId = null,Object? recommendationId = freezed,}) {
  return _then(RoutinePlayerArgs(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,recommendationId: freezed == recommendationId ? _self.recommendationId : recommendationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutinePlayerArgs].
extension RoutinePlayerArgsPatterns on RoutinePlayerArgs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutinePlayerArgs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutinePlayerArgs() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutinePlayerArgs value)  $default,){
final _that = this;
switch (_that) {
case _RoutinePlayerArgs():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutinePlayerArgs value)?  $default,){
final _that = this;
switch (_that) {
case _RoutinePlayerArgs() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String routineId,  String? recommendationId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutinePlayerArgs() when $default != null:
return $default(_that.routineId,_that.recommendationId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String routineId,  String? recommendationId)  $default,) {final _that = this;
switch (_that) {
case _RoutinePlayerArgs():
return $default(_that.routineId,_that.recommendationId);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String routineId,  String? recommendationId)?  $default,) {final _that = this;
switch (_that) {
case _RoutinePlayerArgs() when $default != null:
return $default(_that.routineId,_that.recommendationId);case _:
  return null;

}
}

}

/// @nodoc


class _RoutinePlayerArgs implements RoutinePlayerArgs {
  const _RoutinePlayerArgs({required this.routineId, this.recommendationId});
  

@override final  String routineId;
@override final  String? recommendationId;

/// Create a copy of RoutinePlayerArgs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutinePlayerArgsCopyWith<_RoutinePlayerArgs> get copyWith => __$RoutinePlayerArgsCopyWithImpl<_RoutinePlayerArgs>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutinePlayerArgs&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.recommendationId, recommendationId) || other.recommendationId == recommendationId));
}


@override
int get hashCode => Object.hash(runtimeType,routineId,recommendationId);

@override
String toString() {
  return 'RoutinePlayerArgs(routineId: $routineId, recommendationId: $recommendationId)';
}


}

/// @nodoc
abstract mixin class _$RoutinePlayerArgsCopyWith<$Res> implements $RoutinePlayerArgsCopyWith<$Res> {
  factory _$RoutinePlayerArgsCopyWith(_RoutinePlayerArgs value, $Res Function(_RoutinePlayerArgs) _then) = __$RoutinePlayerArgsCopyWithImpl;
@override @useResult
$Res call({
 String routineId, String? recommendationId
});




}
/// @nodoc
class __$RoutinePlayerArgsCopyWithImpl<$Res>
    implements _$RoutinePlayerArgsCopyWith<$Res> {
  __$RoutinePlayerArgsCopyWithImpl(this._self, this._then);

  final _RoutinePlayerArgs _self;
  final $Res Function(_RoutinePlayerArgs) _then;

/// Create a copy of RoutinePlayerArgs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routineId = null,Object? recommendationId = freezed,}) {
  return _then(_RoutinePlayerArgs(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,recommendationId: freezed == recommendationId ? _self.recommendationId : recommendationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
