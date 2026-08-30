// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthAccount {

 String get id; bool get isAnonymous; bool get emailConfirmed;
/// Create a copy of AuthAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthAccountCopyWith<AuthAccount> get copyWith => _$AuthAccountCopyWithImpl<AuthAccount>(this as AuthAccount, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.emailConfirmed, emailConfirmed) || other.emailConfirmed == emailConfirmed));
}


@override
int get hashCode => Object.hash(runtimeType,id,isAnonymous,emailConfirmed);

@override
String toString() {
  return 'AuthAccount(id: $id, isAnonymous: $isAnonymous, emailConfirmed: $emailConfirmed)';
}


}

/// @nodoc
abstract mixin class $AuthAccountCopyWith<$Res>  {
  factory $AuthAccountCopyWith(AuthAccount value, $Res Function(AuthAccount) _then) = _$AuthAccountCopyWithImpl;
@useResult
$Res call({
 String id, bool isAnonymous, bool emailConfirmed
});




}
/// @nodoc
class _$AuthAccountCopyWithImpl<$Res>
    implements $AuthAccountCopyWith<$Res> {
  _$AuthAccountCopyWithImpl(this._self, this._then);

  final AuthAccount _self;
  final $Res Function(AuthAccount) _then;

/// Create a copy of AuthAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isAnonymous = null,Object? emailConfirmed = null,}) {
  return _then(AuthAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,emailConfirmed: null == emailConfirmed ? _self.emailConfirmed : emailConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthAccount].
extension AuthAccountPatterns on AuthAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthAccount value)  $default,){
final _that = this;
switch (_that) {
case _AuthAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthAccount value)?  $default,){
final _that = this;
switch (_that) {
case _AuthAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool isAnonymous,  bool emailConfirmed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthAccount() when $default != null:
return $default(_that.id,_that.isAnonymous,_that.emailConfirmed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool isAnonymous,  bool emailConfirmed)  $default,) {final _that = this;
switch (_that) {
case _AuthAccount():
return $default(_that.id,_that.isAnonymous,_that.emailConfirmed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool isAnonymous,  bool emailConfirmed)?  $default,) {final _that = this;
switch (_that) {
case _AuthAccount() when $default != null:
return $default(_that.id,_that.isAnonymous,_that.emailConfirmed);case _:
  return null;

}
}

}

/// @nodoc


class _AuthAccount implements AuthAccount {
  const _AuthAccount({required this.id, required this.isAnonymous, required this.emailConfirmed});
  

@override final  String id;
@override final  bool isAnonymous;
@override final  bool emailConfirmed;

/// Create a copy of AuthAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthAccountCopyWith<_AuthAccount> get copyWith => __$AuthAccountCopyWithImpl<_AuthAccount>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.emailConfirmed, emailConfirmed) || other.emailConfirmed == emailConfirmed));
}


@override
int get hashCode => Object.hash(runtimeType,id,isAnonymous,emailConfirmed);

@override
String toString() {
  return 'AuthAccount(id: $id, isAnonymous: $isAnonymous, emailConfirmed: $emailConfirmed)';
}


}

/// @nodoc
abstract mixin class _$AuthAccountCopyWith<$Res> implements $AuthAccountCopyWith<$Res> {
  factory _$AuthAccountCopyWith(_AuthAccount value, $Res Function(_AuthAccount) _then) = __$AuthAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, bool isAnonymous, bool emailConfirmed
});




}
/// @nodoc
class __$AuthAccountCopyWithImpl<$Res>
    implements _$AuthAccountCopyWith<$Res> {
  __$AuthAccountCopyWithImpl(this._self, this._then);

  final _AuthAccount _self;
  final $Res Function(_AuthAccount) _then;

/// Create a copy of AuthAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isAnonymous = null,Object? emailConfirmed = null,}) {
  return _then(_AuthAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,emailConfirmed: null == emailConfirmed ? _self.emailConfirmed : emailConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
