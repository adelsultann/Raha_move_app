// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecommendationState {

 CheckInAnswers get checkIn; RecommendationResult get result; String? get recommendationId;
/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationStateCopyWith<RecommendationState> get copyWith => _$RecommendationStateCopyWithImpl<RecommendationState>(this as RecommendationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationState&&(identical(other.checkIn, checkIn) || other.checkIn == checkIn)&&(identical(other.result, result) || other.result == result)&&(identical(other.recommendationId, recommendationId) || other.recommendationId == recommendationId));
}


@override
int get hashCode => Object.hash(runtimeType,checkIn,result,recommendationId);

@override
String toString() {
  return 'RecommendationState(checkIn: $checkIn, result: $result, recommendationId: $recommendationId)';
}


}

/// @nodoc
abstract mixin class $RecommendationStateCopyWith<$Res>  {
  factory $RecommendationStateCopyWith(RecommendationState value, $Res Function(RecommendationState) _then) = _$RecommendationStateCopyWithImpl;
@useResult
$Res call({
 CheckInAnswers checkIn, RecommendationResult result, String? recommendationId
});


$CheckInAnswersCopyWith<$Res> get checkIn;$RecommendationResultCopyWith<$Res> get result;

}
/// @nodoc
class _$RecommendationStateCopyWithImpl<$Res>
    implements $RecommendationStateCopyWith<$Res> {
  _$RecommendationStateCopyWithImpl(this._self, this._then);

  final RecommendationState _self;
  final $Res Function(RecommendationState) _then;

/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checkIn = null,Object? result = null,Object? recommendationId = freezed,}) {
  return _then(RecommendationState(
checkIn: null == checkIn ? _self.checkIn : checkIn // ignore: cast_nullable_to_non_nullable
as CheckInAnswers,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as RecommendationResult,recommendationId: freezed == recommendationId ? _self.recommendationId : recommendationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckInAnswersCopyWith<$Res> get checkIn {
  
  return $CheckInAnswersCopyWith<$Res>(_self.checkIn, (value) {
    return _then(_self.copyWith(checkIn: value));
  });
}/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecommendationResultCopyWith<$Res> get result {
  
  return $RecommendationResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecommendationState].
extension RecommendationStatePatterns on RecommendationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationState value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationState value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CheckInAnswers checkIn,  RecommendationResult result,  String? recommendationId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationState() when $default != null:
return $default(_that.checkIn,_that.result,_that.recommendationId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CheckInAnswers checkIn,  RecommendationResult result,  String? recommendationId)  $default,) {final _that = this;
switch (_that) {
case _RecommendationState():
return $default(_that.checkIn,_that.result,_that.recommendationId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CheckInAnswers checkIn,  RecommendationResult result,  String? recommendationId)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationState() when $default != null:
return $default(_that.checkIn,_that.result,_that.recommendationId);case _:
  return null;

}
}

}

/// @nodoc


class _RecommendationState extends RecommendationState {
  const _RecommendationState({required this.checkIn, required this.result, this.recommendationId}): super._();
  

@override final  CheckInAnswers checkIn;
@override final  RecommendationResult result;
@override final  String? recommendationId;

/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationStateCopyWith<_RecommendationState> get copyWith => __$RecommendationStateCopyWithImpl<_RecommendationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationState&&(identical(other.checkIn, checkIn) || other.checkIn == checkIn)&&(identical(other.result, result) || other.result == result)&&(identical(other.recommendationId, recommendationId) || other.recommendationId == recommendationId));
}


@override
int get hashCode => Object.hash(runtimeType,checkIn,result,recommendationId);

@override
String toString() {
  return 'RecommendationState(checkIn: $checkIn, result: $result, recommendationId: $recommendationId)';
}


}

/// @nodoc
abstract mixin class _$RecommendationStateCopyWith<$Res> implements $RecommendationStateCopyWith<$Res> {
  factory _$RecommendationStateCopyWith(_RecommendationState value, $Res Function(_RecommendationState) _then) = __$RecommendationStateCopyWithImpl;
@override @useResult
$Res call({
 CheckInAnswers checkIn, RecommendationResult result, String? recommendationId
});


@override $CheckInAnswersCopyWith<$Res> get checkIn;@override $RecommendationResultCopyWith<$Res> get result;

}
/// @nodoc
class __$RecommendationStateCopyWithImpl<$Res>
    implements _$RecommendationStateCopyWith<$Res> {
  __$RecommendationStateCopyWithImpl(this._self, this._then);

  final _RecommendationState _self;
  final $Res Function(_RecommendationState) _then;

/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checkIn = null,Object? result = null,Object? recommendationId = freezed,}) {
  return _then(_RecommendationState(
checkIn: null == checkIn ? _self.checkIn : checkIn // ignore: cast_nullable_to_non_nullable
as CheckInAnswers,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as RecommendationResult,recommendationId: freezed == recommendationId ? _self.recommendationId : recommendationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckInAnswersCopyWith<$Res> get checkIn {
  
  return $CheckInAnswersCopyWith<$Res>(_self.checkIn, (value) {
    return _then(_self.copyWith(checkIn: value));
  });
}/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecommendationResultCopyWith<$Res> get result {
  
  return $RecommendationResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

// dart format on
