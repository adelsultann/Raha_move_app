// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SignUpOutcome {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SignUpOutcome);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SignUpOutcome()';
  }
}

/// @nodoc
class $SignUpOutcomeCopyWith<$Res> {
  $SignUpOutcomeCopyWith(SignUpOutcome _, $Res Function(SignUpOutcome) __);
}

/// Adds pattern-matching-related methods to [SignUpOutcome].
extension SignUpOutcomePatterns on SignUpOutcome {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NeedsConfirmation value)? needsConfirmation,
    TResult Function(SignedIn value)? signedIn,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case NeedsConfirmation() when needsConfirmation != null:
        return needsConfirmation(_that);
      case SignedIn() when signedIn != null:
        return signedIn(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NeedsConfirmation value) needsConfirmation,
    required TResult Function(SignedIn value) signedIn,
  }) {
    final _that = this;
    switch (_that) {
      case NeedsConfirmation():
        return needsConfirmation(_that);
      case SignedIn():
        return signedIn(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NeedsConfirmation value)? needsConfirmation,
    TResult? Function(SignedIn value)? signedIn,
  }) {
    final _that = this;
    switch (_that) {
      case NeedsConfirmation() when needsConfirmation != null:
        return needsConfirmation(_that);
      case SignedIn() when signedIn != null:
        return signedIn(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String email)? needsConfirmation,
    TResult Function(AuthAccount account)? signedIn,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case NeedsConfirmation() when needsConfirmation != null:
        return needsConfirmation(_that.email);
      case SignedIn() when signedIn != null:
        return signedIn(_that.account);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String email) needsConfirmation,
    required TResult Function(AuthAccount account) signedIn,
  }) {
    final _that = this;
    switch (_that) {
      case NeedsConfirmation():
        return needsConfirmation(_that.email);
      case SignedIn():
        return signedIn(_that.account);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String email)? needsConfirmation,
    TResult? Function(AuthAccount account)? signedIn,
  }) {
    final _that = this;
    switch (_that) {
      case NeedsConfirmation() when needsConfirmation != null:
        return needsConfirmation(_that.email);
      case SignedIn() when signedIn != null:
        return signedIn(_that.account);
      case _:
        return null;
    }
  }
}

/// @nodoc

class NeedsConfirmation implements SignUpOutcome {
  const NeedsConfirmation(this.email);

  final String email;

  /// Create a copy of SignUpOutcome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NeedsConfirmationCopyWith<NeedsConfirmation> get copyWith =>
      _$NeedsConfirmationCopyWithImpl<NeedsConfirmation>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NeedsConfirmation &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email);

  @override
  String toString() {
    return 'SignUpOutcome.needsConfirmation(email: $email)';
  }
}

/// @nodoc
abstract mixin class $NeedsConfirmationCopyWith<$Res>
    implements $SignUpOutcomeCopyWith<$Res> {
  factory $NeedsConfirmationCopyWith(
    NeedsConfirmation value,
    $Res Function(NeedsConfirmation) _then,
  ) = _$NeedsConfirmationCopyWithImpl;
  @useResult
  $Res call({String email});
}

/// @nodoc
class _$NeedsConfirmationCopyWithImpl<$Res>
    implements $NeedsConfirmationCopyWith<$Res> {
  _$NeedsConfirmationCopyWithImpl(this._self, this._then);

  final NeedsConfirmation _self;
  final $Res Function(NeedsConfirmation) _then;

  /// Create a copy of SignUpOutcome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({Object? email = null}) {
    return _then(
      NeedsConfirmation(
        null == email
            ? _self.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class SignedIn implements SignUpOutcome {
  const SignedIn(this.account);

  final AuthAccount account;

  /// Create a copy of SignUpOutcome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SignedInCopyWith<SignedIn> get copyWith =>
      _$SignedInCopyWithImpl<SignedIn>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SignedIn &&
            (identical(other.account, account) || other.account == account));
  }

  @override
  int get hashCode => Object.hash(runtimeType, account);

  @override
  String toString() {
    return 'SignUpOutcome.signedIn(account: $account)';
  }
}

/// @nodoc
abstract mixin class $SignedInCopyWith<$Res>
    implements $SignUpOutcomeCopyWith<$Res> {
  factory $SignedInCopyWith(SignedIn value, $Res Function(SignedIn) _then) =
      _$SignedInCopyWithImpl;
  @useResult
  $Res call({AuthAccount account});

  $AuthAccountCopyWith<$Res> get account;
}

/// @nodoc
class _$SignedInCopyWithImpl<$Res> implements $SignedInCopyWith<$Res> {
  _$SignedInCopyWithImpl(this._self, this._then);

  final SignedIn _self;
  final $Res Function(SignedIn) _then;

  /// Create a copy of SignUpOutcome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({Object? account = null}) {
    return _then(
      SignedIn(
        null == account
            ? _self.account
            : account // ignore: cast_nullable_to_non_nullable
                  as AuthAccount,
      ),
    );
  }

  /// Create a copy of SignUpOutcome
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthAccountCopyWith<$Res> get account {
    return $AuthAccountCopyWith<$Res>(_self.account, (value) {
      return _then(_self.copyWith(account: value));
    });
  }
}
