// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preferences_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PreferencesFormState {
  ExperienceLevel? get experienceLevel;
  Set<MovementPosition> get preferredPositions;
  int get weeklyGoalDays;
  bool get reminderInterest;

  /// Create a copy of PreferencesFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PreferencesFormStateCopyWith<PreferencesFormState> get copyWith =>
      _$PreferencesFormStateCopyWithImpl<PreferencesFormState>(
        this as PreferencesFormState,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PreferencesFormState &&
            (identical(other.experienceLevel, experienceLevel) ||
                other.experienceLevel == experienceLevel) &&
            const DeepCollectionEquality().equals(
              other.preferredPositions,
              preferredPositions,
            ) &&
            (identical(other.weeklyGoalDays, weeklyGoalDays) ||
                other.weeklyGoalDays == weeklyGoalDays) &&
            (identical(other.reminderInterest, reminderInterest) ||
                other.reminderInterest == reminderInterest));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    experienceLevel,
    const DeepCollectionEquality().hash(preferredPositions),
    weeklyGoalDays,
    reminderInterest,
  );

  @override
  String toString() {
    return 'PreferencesFormState(experienceLevel: $experienceLevel, preferredPositions: $preferredPositions, weeklyGoalDays: $weeklyGoalDays, reminderInterest: $reminderInterest)';
  }
}

/// @nodoc
abstract mixin class $PreferencesFormStateCopyWith<$Res> {
  factory $PreferencesFormStateCopyWith(
    PreferencesFormState value,
    $Res Function(PreferencesFormState) _then,
  ) = _$PreferencesFormStateCopyWithImpl;
  @useResult
  $Res call({
    ExperienceLevel? experienceLevel,
    Set<MovementPosition> preferredPositions,
    int weeklyGoalDays,
    bool reminderInterest,
  });
}

/// @nodoc
class _$PreferencesFormStateCopyWithImpl<$Res>
    implements $PreferencesFormStateCopyWith<$Res> {
  _$PreferencesFormStateCopyWithImpl(this._self, this._then);

  final PreferencesFormState _self;
  final $Res Function(PreferencesFormState) _then;

  /// Create a copy of PreferencesFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? experienceLevel = freezed,
    Object? preferredPositions = null,
    Object? weeklyGoalDays = null,
    Object? reminderInterest = null,
  }) {
    return _then(
      PreferencesFormState(
        experienceLevel: freezed == experienceLevel
            ? _self.experienceLevel
            : experienceLevel // ignore: cast_nullable_to_non_nullable
                  as ExperienceLevel?,
        preferredPositions: null == preferredPositions
            ? _self.preferredPositions
            : preferredPositions // ignore: cast_nullable_to_non_nullable
                  as Set<MovementPosition>,
        weeklyGoalDays: null == weeklyGoalDays
            ? _self.weeklyGoalDays
            : weeklyGoalDays // ignore: cast_nullable_to_non_nullable
                  as int,
        reminderInterest: null == reminderInterest
            ? _self.reminderInterest
            : reminderInterest // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [PreferencesFormState].
extension PreferencesFormStatePatterns on PreferencesFormState {
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
    TResult Function(_PreferencesFormState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PreferencesFormState() when $default != null:
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
    TResult Function(_PreferencesFormState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PreferencesFormState():
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
    TResult? Function(_PreferencesFormState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PreferencesFormState() when $default != null:
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
      ExperienceLevel? experienceLevel,
      Set<MovementPosition> preferredPositions,
      int weeklyGoalDays,
      bool reminderInterest,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PreferencesFormState() when $default != null:
        return $default(
          _that.experienceLevel,
          _that.preferredPositions,
          _that.weeklyGoalDays,
          _that.reminderInterest,
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
      ExperienceLevel? experienceLevel,
      Set<MovementPosition> preferredPositions,
      int weeklyGoalDays,
      bool reminderInterest,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PreferencesFormState():
        return $default(
          _that.experienceLevel,
          _that.preferredPositions,
          _that.weeklyGoalDays,
          _that.reminderInterest,
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
      ExperienceLevel? experienceLevel,
      Set<MovementPosition> preferredPositions,
      int weeklyGoalDays,
      bool reminderInterest,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PreferencesFormState() when $default != null:
        return $default(
          _that.experienceLevel,
          _that.preferredPositions,
          _that.weeklyGoalDays,
          _that.reminderInterest,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PreferencesFormState extends PreferencesFormState {
  const _PreferencesFormState({
    this.experienceLevel,
    Set<MovementPosition> preferredPositions = const <MovementPosition>{},
    this.weeklyGoalDays = 3,
    this.reminderInterest = false,
  }) : _preferredPositions = preferredPositions,
       super._();

  @override
  final ExperienceLevel? experienceLevel;
  final Set<MovementPosition> _preferredPositions;
  @override
  @JsonKey()
  Set<MovementPosition> get preferredPositions {
    if (_preferredPositions is EqualUnmodifiableSetView)
      return _preferredPositions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_preferredPositions);
  }

  @override
  @JsonKey()
  final int weeklyGoalDays;
  @override
  @JsonKey()
  final bool reminderInterest;

  /// Create a copy of PreferencesFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PreferencesFormStateCopyWith<_PreferencesFormState> get copyWith =>
      __$PreferencesFormStateCopyWithImpl<_PreferencesFormState>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PreferencesFormState &&
            (identical(other.experienceLevel, experienceLevel) ||
                other.experienceLevel == experienceLevel) &&
            const DeepCollectionEquality().equals(
              other._preferredPositions,
              _preferredPositions,
            ) &&
            (identical(other.weeklyGoalDays, weeklyGoalDays) ||
                other.weeklyGoalDays == weeklyGoalDays) &&
            (identical(other.reminderInterest, reminderInterest) ||
                other.reminderInterest == reminderInterest));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    experienceLevel,
    const DeepCollectionEquality().hash(_preferredPositions),
    weeklyGoalDays,
    reminderInterest,
  );

  @override
  String toString() {
    return 'PreferencesFormState(experienceLevel: $experienceLevel, preferredPositions: $preferredPositions, weeklyGoalDays: $weeklyGoalDays, reminderInterest: $reminderInterest)';
  }
}

/// @nodoc
abstract mixin class _$PreferencesFormStateCopyWith<$Res>
    implements $PreferencesFormStateCopyWith<$Res> {
  factory _$PreferencesFormStateCopyWith(
    _PreferencesFormState value,
    $Res Function(_PreferencesFormState) _then,
  ) = __$PreferencesFormStateCopyWithImpl;
  @override
  @useResult
  $Res call({
    ExperienceLevel? experienceLevel,
    Set<MovementPosition> preferredPositions,
    int weeklyGoalDays,
    bool reminderInterest,
  });
}

/// @nodoc
class __$PreferencesFormStateCopyWithImpl<$Res>
    implements _$PreferencesFormStateCopyWith<$Res> {
  __$PreferencesFormStateCopyWithImpl(this._self, this._then);

  final _PreferencesFormState _self;
  final $Res Function(_PreferencesFormState) _then;

  /// Create a copy of PreferencesFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? experienceLevel = freezed,
    Object? preferredPositions = null,
    Object? weeklyGoalDays = null,
    Object? reminderInterest = null,
  }) {
    return _then(
      _PreferencesFormState(
        experienceLevel: freezed == experienceLevel
            ? _self.experienceLevel
            : experienceLevel // ignore: cast_nullable_to_non_nullable
                  as ExperienceLevel?,
        preferredPositions: null == preferredPositions
            ? _self._preferredPositions
            : preferredPositions // ignore: cast_nullable_to_non_nullable
                  as Set<MovementPosition>,
        weeklyGoalDays: null == weeklyGoalDays
            ? _self.weeklyGoalDays
            : weeklyGoalDays // ignore: cast_nullable_to_non_nullable
                  as int,
        reminderInterest: null == reminderInterest
            ? _self.reminderInterest
            : reminderInterest // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}
