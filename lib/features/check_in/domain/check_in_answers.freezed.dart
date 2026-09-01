// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_answers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckInAnswers {
  BodyState get bodyState;
  String get goalKey;
  Set<String> get bodyAreaKeys;
  int get availableMinutes;
  String? get positionKey;

  /// Create a copy of CheckInAnswers
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CheckInAnswersCopyWith<CheckInAnswers> get copyWith =>
      _$CheckInAnswersCopyWithImpl<CheckInAnswers>(
        this as CheckInAnswers,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CheckInAnswers &&
            (identical(other.bodyState, bodyState) ||
                other.bodyState == bodyState) &&
            (identical(other.goalKey, goalKey) || other.goalKey == goalKey) &&
            const DeepCollectionEquality().equals(
              other.bodyAreaKeys,
              bodyAreaKeys,
            ) &&
            (identical(other.availableMinutes, availableMinutes) ||
                other.availableMinutes == availableMinutes) &&
            (identical(other.positionKey, positionKey) ||
                other.positionKey == positionKey));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    bodyState,
    goalKey,
    const DeepCollectionEquality().hash(bodyAreaKeys),
    availableMinutes,
    positionKey,
  );

  @override
  String toString() {
    return 'CheckInAnswers(bodyState: $bodyState, goalKey: $goalKey, bodyAreaKeys: $bodyAreaKeys, availableMinutes: $availableMinutes, positionKey: $positionKey)';
  }
}

/// @nodoc
abstract mixin class $CheckInAnswersCopyWith<$Res> {
  factory $CheckInAnswersCopyWith(
    CheckInAnswers value,
    $Res Function(CheckInAnswers) _then,
  ) = _$CheckInAnswersCopyWithImpl;
  @useResult
  $Res call({
    BodyState bodyState,
    String goalKey,
    Set<String> bodyAreaKeys,
    int availableMinutes,
    String? positionKey,
  });
}

/// @nodoc
class _$CheckInAnswersCopyWithImpl<$Res>
    implements $CheckInAnswersCopyWith<$Res> {
  _$CheckInAnswersCopyWithImpl(this._self, this._then);

  final CheckInAnswers _self;
  final $Res Function(CheckInAnswers) _then;

  /// Create a copy of CheckInAnswers
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bodyState = null,
    Object? goalKey = null,
    Object? bodyAreaKeys = null,
    Object? availableMinutes = null,
    Object? positionKey = freezed,
  }) {
    return _then(
      CheckInAnswers(
        bodyState: null == bodyState
            ? _self.bodyState
            : bodyState // ignore: cast_nullable_to_non_nullable
                  as BodyState,
        goalKey: null == goalKey
            ? _self.goalKey
            : goalKey // ignore: cast_nullable_to_non_nullable
                  as String,
        bodyAreaKeys: null == bodyAreaKeys
            ? _self.bodyAreaKeys
            : bodyAreaKeys // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        availableMinutes: null == availableMinutes
            ? _self.availableMinutes
            : availableMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        positionKey: freezed == positionKey
            ? _self.positionKey
            : positionKey // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [CheckInAnswers].
extension CheckInAnswersPatterns on CheckInAnswers {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_CheckInAnswers value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckInAnswers() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_CheckInAnswers value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInAnswers():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_CheckInAnswers value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInAnswers() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      BodyState bodyState,
      String goalKey,
      Set<String> bodyAreaKeys,
      int availableMinutes,
      String? positionKey,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckInAnswers() when $default != null:
        return $default(
          _that.bodyState,
          _that.goalKey,
          _that.bodyAreaKeys,
          _that.availableMinutes,
          _that.positionKey,
        );
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
  TResult when<TResult extends Object?>(
    TResult Function(
      BodyState bodyState,
      String goalKey,
      Set<String> bodyAreaKeys,
      int availableMinutes,
      String? positionKey,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInAnswers():
        return $default(
          _that.bodyState,
          _that.goalKey,
          _that.bodyAreaKeys,
          _that.availableMinutes,
          _that.positionKey,
        );
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      BodyState bodyState,
      String goalKey,
      Set<String> bodyAreaKeys,
      int availableMinutes,
      String? positionKey,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInAnswers() when $default != null:
        return $default(
          _that.bodyState,
          _that.goalKey,
          _that.bodyAreaKeys,
          _that.availableMinutes,
          _that.positionKey,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CheckInAnswers extends CheckInAnswers {
  const _CheckInAnswers({
    required this.bodyState,
    required this.goalKey,
    required Set<String> bodyAreaKeys,
    required this.availableMinutes,
    this.positionKey,
  }) : _bodyAreaKeys = bodyAreaKeys,
       super._();

  @override
  final BodyState bodyState;
  @override
  final String goalKey;
  final Set<String> _bodyAreaKeys;
  @override
  Set<String> get bodyAreaKeys {
    if (_bodyAreaKeys is EqualUnmodifiableSetView) return _bodyAreaKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_bodyAreaKeys);
  }

  @override
  final int availableMinutes;
  @override
  final String? positionKey;

  /// Create a copy of CheckInAnswers
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CheckInAnswersCopyWith<_CheckInAnswers> get copyWith =>
      __$CheckInAnswersCopyWithImpl<_CheckInAnswers>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CheckInAnswers &&
            (identical(other.bodyState, bodyState) ||
                other.bodyState == bodyState) &&
            (identical(other.goalKey, goalKey) || other.goalKey == goalKey) &&
            const DeepCollectionEquality().equals(
              other._bodyAreaKeys,
              _bodyAreaKeys,
            ) &&
            (identical(other.availableMinutes, availableMinutes) ||
                other.availableMinutes == availableMinutes) &&
            (identical(other.positionKey, positionKey) ||
                other.positionKey == positionKey));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    bodyState,
    goalKey,
    const DeepCollectionEquality().hash(_bodyAreaKeys),
    availableMinutes,
    positionKey,
  );

  @override
  String toString() {
    return 'CheckInAnswers(bodyState: $bodyState, goalKey: $goalKey, bodyAreaKeys: $bodyAreaKeys, availableMinutes: $availableMinutes, positionKey: $positionKey)';
  }
}

/// @nodoc
abstract mixin class _$CheckInAnswersCopyWith<$Res>
    implements $CheckInAnswersCopyWith<$Res> {
  factory _$CheckInAnswersCopyWith(
    _CheckInAnswers value,
    $Res Function(_CheckInAnswers) _then,
  ) = __$CheckInAnswersCopyWithImpl;
  @override
  @useResult
  $Res call({
    BodyState bodyState,
    String goalKey,
    Set<String> bodyAreaKeys,
    int availableMinutes,
    String? positionKey,
  });
}

/// @nodoc
class __$CheckInAnswersCopyWithImpl<$Res>
    implements _$CheckInAnswersCopyWith<$Res> {
  __$CheckInAnswersCopyWithImpl(this._self, this._then);

  final _CheckInAnswers _self;
  final $Res Function(_CheckInAnswers) _then;

  /// Create a copy of CheckInAnswers
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? bodyState = null,
    Object? goalKey = null,
    Object? bodyAreaKeys = null,
    Object? availableMinutes = null,
    Object? positionKey = freezed,
  }) {
    return _then(
      _CheckInAnswers(
        bodyState: null == bodyState
            ? _self.bodyState
            : bodyState // ignore: cast_nullable_to_non_nullable
                  as BodyState,
        goalKey: null == goalKey
            ? _self.goalKey
            : goalKey // ignore: cast_nullable_to_non_nullable
                  as String,
        bodyAreaKeys: null == bodyAreaKeys
            ? _self._bodyAreaKeys
            : bodyAreaKeys // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        availableMinutes: null == availableMinutes
            ? _self.availableMinutes
            : availableMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        positionKey: freezed == positionKey
            ? _self.positionKey
            : positionKey // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}
