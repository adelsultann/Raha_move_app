// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckInFormState {

 BodyState? get bodyState; CheckInGoal? get goal; Set<BodyArea> get bodyAreas; int? get availableMinutes; CheckInPosition? get position;
/// Create a copy of CheckInFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInFormStateCopyWith<CheckInFormState> get copyWith => _$CheckInFormStateCopyWithImpl<CheckInFormState>(this as CheckInFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInFormState&&(identical(other.bodyState, bodyState) || other.bodyState == bodyState)&&(identical(other.goal, goal) || other.goal == goal)&&const DeepCollectionEquality().equals(other.bodyAreas, bodyAreas)&&(identical(other.availableMinutes, availableMinutes) || other.availableMinutes == availableMinutes)&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode => Object.hash(runtimeType,bodyState,goal,const DeepCollectionEquality().hash(bodyAreas),availableMinutes,position);

@override
String toString() {
  return 'CheckInFormState(bodyState: $bodyState, goal: $goal, bodyAreas: $bodyAreas, availableMinutes: $availableMinutes, position: $position)';
}


}

/// @nodoc
abstract mixin class $CheckInFormStateCopyWith<$Res>  {
  factory $CheckInFormStateCopyWith(CheckInFormState value, $Res Function(CheckInFormState) _then) = _$CheckInFormStateCopyWithImpl;
@useResult
$Res call({
 BodyState? bodyState, CheckInGoal? goal, Set<BodyArea> bodyAreas, int? availableMinutes, CheckInPosition? position
});




}
/// @nodoc
class _$CheckInFormStateCopyWithImpl<$Res>
    implements $CheckInFormStateCopyWith<$Res> {
  _$CheckInFormStateCopyWithImpl(this._self, this._then);

  final CheckInFormState _self;
  final $Res Function(CheckInFormState) _then;

/// Create a copy of CheckInFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bodyState = freezed,Object? goal = freezed,Object? bodyAreas = null,Object? availableMinutes = freezed,Object? position = freezed,}) {
  return _then(CheckInFormState(
bodyState: freezed == bodyState ? _self.bodyState : bodyState // ignore: cast_nullable_to_non_nullable
as BodyState?,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as CheckInGoal?,bodyAreas: null == bodyAreas ? _self.bodyAreas : bodyAreas // ignore: cast_nullable_to_non_nullable
as Set<BodyArea>,availableMinutes: freezed == availableMinutes ? _self.availableMinutes : availableMinutes // ignore: cast_nullable_to_non_nullable
as int?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as CheckInPosition?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckInFormState].
extension CheckInFormStatePatterns on CheckInFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckInFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckInFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckInFormState value)  $default,){
final _that = this;
switch (_that) {
case _CheckInFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckInFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CheckInFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BodyState? bodyState,  CheckInGoal? goal,  Set<BodyArea> bodyAreas,  int? availableMinutes,  CheckInPosition? position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckInFormState() when $default != null:
return $default(_that.bodyState,_that.goal,_that.bodyAreas,_that.availableMinutes,_that.position);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BodyState? bodyState,  CheckInGoal? goal,  Set<BodyArea> bodyAreas,  int? availableMinutes,  CheckInPosition? position)  $default,) {final _that = this;
switch (_that) {
case _CheckInFormState():
return $default(_that.bodyState,_that.goal,_that.bodyAreas,_that.availableMinutes,_that.position);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BodyState? bodyState,  CheckInGoal? goal,  Set<BodyArea> bodyAreas,  int? availableMinutes,  CheckInPosition? position)?  $default,) {final _that = this;
switch (_that) {
case _CheckInFormState() when $default != null:
return $default(_that.bodyState,_that.goal,_that.bodyAreas,_that.availableMinutes,_that.position);case _:
  return null;

}
}

}

/// @nodoc


class _CheckInFormState extends CheckInFormState {
  const _CheckInFormState({this.bodyState, this.goal,  Set<BodyArea> bodyAreas = const <BodyArea>{}, this.availableMinutes, this.position}): _bodyAreas = bodyAreas,super._();
  

@override final  BodyState? bodyState;
@override final  CheckInGoal? goal;
 final  Set<BodyArea> _bodyAreas;
@override@JsonKey() Set<BodyArea> get bodyAreas {
  if (_bodyAreas is EqualUnmodifiableSetView) return _bodyAreas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_bodyAreas);
}

@override final  int? availableMinutes;
@override final  CheckInPosition? position;

/// Create a copy of CheckInFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInFormStateCopyWith<_CheckInFormState> get copyWith => __$CheckInFormStateCopyWithImpl<_CheckInFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckInFormState&&(identical(other.bodyState, bodyState) || other.bodyState == bodyState)&&(identical(other.goal, goal) || other.goal == goal)&&const DeepCollectionEquality().equals(other._bodyAreas, _bodyAreas)&&(identical(other.availableMinutes, availableMinutes) || other.availableMinutes == availableMinutes)&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode => Object.hash(runtimeType,bodyState,goal,const DeepCollectionEquality().hash(_bodyAreas),availableMinutes,position);

@override
String toString() {
  return 'CheckInFormState(bodyState: $bodyState, goal: $goal, bodyAreas: $bodyAreas, availableMinutes: $availableMinutes, position: $position)';
}


}

/// @nodoc
abstract mixin class _$CheckInFormStateCopyWith<$Res> implements $CheckInFormStateCopyWith<$Res> {
  factory _$CheckInFormStateCopyWith(_CheckInFormState value, $Res Function(_CheckInFormState) _then) = __$CheckInFormStateCopyWithImpl;
@override @useResult
$Res call({
 BodyState? bodyState, CheckInGoal? goal, Set<BodyArea> bodyAreas, int? availableMinutes, CheckInPosition? position
});




}
/// @nodoc
class __$CheckInFormStateCopyWithImpl<$Res>
    implements _$CheckInFormStateCopyWith<$Res> {
  __$CheckInFormStateCopyWithImpl(this._self, this._then);

  final _CheckInFormState _self;
  final $Res Function(_CheckInFormState) _then;

/// Create a copy of CheckInFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bodyState = freezed,Object? goal = freezed,Object? bodyAreas = null,Object? availableMinutes = freezed,Object? position = freezed,}) {
  return _then(_CheckInFormState(
bodyState: freezed == bodyState ? _self.bodyState : bodyState // ignore: cast_nullable_to_non_nullable
as BodyState?,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as CheckInGoal?,bodyAreas: null == bodyAreas ? _self._bodyAreas : bodyAreas // ignore: cast_nullable_to_non_nullable
as Set<BodyArea>,availableMinutes: freezed == availableMinutes ? _self.availableMinutes : availableMinutes // ignore: cast_nullable_to_non_nullable
as int?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as CheckInPosition?,
  ));
}


}

// dart format on
