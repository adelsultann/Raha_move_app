// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'foundation_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FoundationStatus {

 bool get isReady; String get environment;
/// Create a copy of FoundationStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoundationStatusCopyWith<FoundationStatus> get copyWith => _$FoundationStatusCopyWithImpl<FoundationStatus>(this as FoundationStatus, _$identity);

  /// Serializes this FoundationStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoundationStatus&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.environment, environment) || other.environment == environment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isReady,environment);

@override
String toString() {
  return 'FoundationStatus(isReady: $isReady, environment: $environment)';
}


}

/// @nodoc
abstract mixin class $FoundationStatusCopyWith<$Res>  {
  factory $FoundationStatusCopyWith(FoundationStatus value, $Res Function(FoundationStatus) _then) = _$FoundationStatusCopyWithImpl;
@useResult
$Res call({
 bool isReady, String environment
});




}
/// @nodoc
class _$FoundationStatusCopyWithImpl<$Res>
    implements $FoundationStatusCopyWith<$Res> {
  _$FoundationStatusCopyWithImpl(this._self, this._then);

  final FoundationStatus _self;
  final $Res Function(FoundationStatus) _then;

/// Create a copy of FoundationStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isReady = null,Object? environment = null,}) {
  return _then(FoundationStatus(
isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FoundationStatus].
extension FoundationStatusPatterns on FoundationStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoundationStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoundationStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoundationStatus value)  $default,){
final _that = this;
switch (_that) {
case _FoundationStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoundationStatus value)?  $default,){
final _that = this;
switch (_that) {
case _FoundationStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isReady,  String environment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoundationStatus() when $default != null:
return $default(_that.isReady,_that.environment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isReady,  String environment)  $default,) {final _that = this;
switch (_that) {
case _FoundationStatus():
return $default(_that.isReady,_that.environment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isReady,  String environment)?  $default,) {final _that = this;
switch (_that) {
case _FoundationStatus() when $default != null:
return $default(_that.isReady,_that.environment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoundationStatus implements FoundationStatus {
  const _FoundationStatus({required this.isReady, required this.environment});
  factory _FoundationStatus.fromJson(Map<String, dynamic> json) => _$FoundationStatusFromJson(json);

@override final  bool isReady;
@override final  String environment;

/// Create a copy of FoundationStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoundationStatusCopyWith<_FoundationStatus> get copyWith => __$FoundationStatusCopyWithImpl<_FoundationStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoundationStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoundationStatus&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.environment, environment) || other.environment == environment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isReady,environment);

@override
String toString() {
  return 'FoundationStatus(isReady: $isReady, environment: $environment)';
}


}

/// @nodoc
abstract mixin class _$FoundationStatusCopyWith<$Res> implements $FoundationStatusCopyWith<$Res> {
  factory _$FoundationStatusCopyWith(_FoundationStatus value, $Res Function(_FoundationStatus) _then) = __$FoundationStatusCopyWithImpl;
@override @useResult
$Res call({
 bool isReady, String environment
});




}
/// @nodoc
class __$FoundationStatusCopyWithImpl<$Res>
    implements _$FoundationStatusCopyWith<$Res> {
  __$FoundationStatusCopyWithImpl(this._self, this._then);

  final _FoundationStatus _self;
  final $Res Function(_FoundationStatus) _then;

/// Create a copy of FoundationStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isReady = null,Object? environment = null,}) {
  return _then(_FoundationStatus(
isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
