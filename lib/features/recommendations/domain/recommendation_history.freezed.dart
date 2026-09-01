// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecentRoutineAttempt {
  String get routineId;
  DateTime get completedAt;

  /// Create a copy of RecentRoutineAttempt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecentRoutineAttemptCopyWith<RecentRoutineAttempt> get copyWith =>
      _$RecentRoutineAttemptCopyWithImpl<RecentRoutineAttempt>(
        this as RecentRoutineAttempt,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecentRoutineAttempt &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, routineId, completedAt);

  @override
  String toString() {
    return 'RecentRoutineAttempt(routineId: $routineId, completedAt: $completedAt)';
  }
}

/// @nodoc
abstract mixin class $RecentRoutineAttemptCopyWith<$Res> {
  factory $RecentRoutineAttemptCopyWith(
    RecentRoutineAttempt value,
    $Res Function(RecentRoutineAttempt) _then,
  ) = _$RecentRoutineAttemptCopyWithImpl;
  @useResult
  $Res call({String routineId, DateTime completedAt});
}

/// @nodoc
class _$RecentRoutineAttemptCopyWithImpl<$Res>
    implements $RecentRoutineAttemptCopyWith<$Res> {
  _$RecentRoutineAttemptCopyWithImpl(this._self, this._then);

  final RecentRoutineAttempt _self;
  final $Res Function(RecentRoutineAttempt) _then;

  /// Create a copy of RecentRoutineAttempt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? routineId = null, Object? completedAt = null}) {
    return _then(
      RecentRoutineAttempt(
        routineId: null == routineId
            ? _self.routineId
            : routineId // ignore: cast_nullable_to_non_nullable
                  as String,
        completedAt: null == completedAt
            ? _self.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [RecentRoutineAttempt].
extension RecentRoutineAttemptPatterns on RecentRoutineAttempt {
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
    TResult Function(_RecentRoutineAttempt value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecentRoutineAttempt() when $default != null:
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
    TResult Function(_RecentRoutineAttempt value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecentRoutineAttempt():
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
    TResult? Function(_RecentRoutineAttempt value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecentRoutineAttempt() when $default != null:
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
    TResult Function(String routineId, DateTime completedAt)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecentRoutineAttempt() when $default != null:
        return $default(_that.routineId, _that.completedAt);
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
    TResult Function(String routineId, DateTime completedAt) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecentRoutineAttempt():
        return $default(_that.routineId, _that.completedAt);
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
    TResult? Function(String routineId, DateTime completedAt)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecentRoutineAttempt() when $default != null:
        return $default(_that.routineId, _that.completedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RecentRoutineAttempt implements RecentRoutineAttempt {
  const _RecentRoutineAttempt({
    required this.routineId,
    required this.completedAt,
  });

  @override
  final String routineId;
  @override
  final DateTime completedAt;

  /// Create a copy of RecentRoutineAttempt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecentRoutineAttemptCopyWith<_RecentRoutineAttempt> get copyWith =>
      __$RecentRoutineAttemptCopyWithImpl<_RecentRoutineAttempt>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecentRoutineAttempt &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, routineId, completedAt);

  @override
  String toString() {
    return 'RecentRoutineAttempt(routineId: $routineId, completedAt: $completedAt)';
  }
}

/// @nodoc
abstract mixin class _$RecentRoutineAttemptCopyWith<$Res>
    implements $RecentRoutineAttemptCopyWith<$Res> {
  factory _$RecentRoutineAttemptCopyWith(
    _RecentRoutineAttempt value,
    $Res Function(_RecentRoutineAttempt) _then,
  ) = __$RecentRoutineAttemptCopyWithImpl;
  @override
  @useResult
  $Res call({String routineId, DateTime completedAt});
}

/// @nodoc
class __$RecentRoutineAttemptCopyWithImpl<$Res>
    implements _$RecentRoutineAttemptCopyWith<$Res> {
  __$RecentRoutineAttemptCopyWithImpl(this._self, this._then);

  final _RecentRoutineAttempt _self;
  final $Res Function(_RecentRoutineAttempt) _then;

  /// Create a copy of RecentRoutineAttempt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? routineId = null, Object? completedAt = null}) {
    return _then(
      _RecentRoutineAttempt(
        routineId: null == routineId
            ? _self.routineId
            : routineId // ignore: cast_nullable_to_non_nullable
                  as String,
        completedAt: null == completedAt
            ? _self.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
mixin _$RecommendationHistory {
  List<RecentRoutineAttempt> get recentAttempts;
  Set<String> get uncomfortableExerciseIds;

  /// Routines whose session received a categorical `less_comfortable`
  /// response. This is the aggregate, exercise-agnostic prior-feedback signal
  /// consumed by the engine's discomfort penalty.
  Set<String> get lessComfortableRoutineIds;

  /// Create a copy of RecommendationHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecommendationHistoryCopyWith<RecommendationHistory> get copyWith =>
      _$RecommendationHistoryCopyWithImpl<RecommendationHistory>(
        this as RecommendationHistory,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecommendationHistory &&
            const DeepCollectionEquality().equals(
              other.recentAttempts,
              recentAttempts,
            ) &&
            const DeepCollectionEquality().equals(
              other.uncomfortableExerciseIds,
              uncomfortableExerciseIds,
            ) &&
            const DeepCollectionEquality().equals(
              other.lessComfortableRoutineIds,
              lessComfortableRoutineIds,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(recentAttempts),
    const DeepCollectionEquality().hash(uncomfortableExerciseIds),
    const DeepCollectionEquality().hash(lessComfortableRoutineIds),
  );

  @override
  String toString() {
    return 'RecommendationHistory(recentAttempts: $recentAttempts, uncomfortableExerciseIds: $uncomfortableExerciseIds, lessComfortableRoutineIds: $lessComfortableRoutineIds)';
  }
}

/// @nodoc
abstract mixin class $RecommendationHistoryCopyWith<$Res> {
  factory $RecommendationHistoryCopyWith(
    RecommendationHistory value,
    $Res Function(RecommendationHistory) _then,
  ) = _$RecommendationHistoryCopyWithImpl;
  @useResult
  $Res call({
    List<RecentRoutineAttempt> recentAttempts,
    Set<String> uncomfortableExerciseIds,
    Set<String> lessComfortableRoutineIds,
  });
}

/// @nodoc
class _$RecommendationHistoryCopyWithImpl<$Res>
    implements $RecommendationHistoryCopyWith<$Res> {
  _$RecommendationHistoryCopyWithImpl(this._self, this._then);

  final RecommendationHistory _self;
  final $Res Function(RecommendationHistory) _then;

  /// Create a copy of RecommendationHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recentAttempts = null,
    Object? uncomfortableExerciseIds = null,
    Object? lessComfortableRoutineIds = null,
  }) {
    return _then(
      RecommendationHistory(
        recentAttempts: null == recentAttempts
            ? _self.recentAttempts
            : recentAttempts // ignore: cast_nullable_to_non_nullable
                  as List<RecentRoutineAttempt>,
        uncomfortableExerciseIds: null == uncomfortableExerciseIds
            ? _self.uncomfortableExerciseIds
            : uncomfortableExerciseIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        lessComfortableRoutineIds: null == lessComfortableRoutineIds
            ? _self.lessComfortableRoutineIds
            : lessComfortableRoutineIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [RecommendationHistory].
extension RecommendationHistoryPatterns on RecommendationHistory {
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
    TResult Function(_RecommendationHistory value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationHistory() when $default != null:
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
    TResult Function(_RecommendationHistory value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationHistory():
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
    TResult? Function(_RecommendationHistory value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationHistory() when $default != null:
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
      List<RecentRoutineAttempt> recentAttempts,
      Set<String> uncomfortableExerciseIds,
      Set<String> lessComfortableRoutineIds,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationHistory() when $default != null:
        return $default(
          _that.recentAttempts,
          _that.uncomfortableExerciseIds,
          _that.lessComfortableRoutineIds,
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
      List<RecentRoutineAttempt> recentAttempts,
      Set<String> uncomfortableExerciseIds,
      Set<String> lessComfortableRoutineIds,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationHistory():
        return $default(
          _that.recentAttempts,
          _that.uncomfortableExerciseIds,
          _that.lessComfortableRoutineIds,
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
      List<RecentRoutineAttempt> recentAttempts,
      Set<String> uncomfortableExerciseIds,
      Set<String> lessComfortableRoutineIds,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationHistory() when $default != null:
        return $default(
          _that.recentAttempts,
          _that.uncomfortableExerciseIds,
          _that.lessComfortableRoutineIds,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RecommendationHistory extends RecommendationHistory {
  const _RecommendationHistory({
    List<RecentRoutineAttempt> recentAttempts = const <RecentRoutineAttempt>[],
    Set<String> uncomfortableExerciseIds = const <String>{},
    Set<String> lessComfortableRoutineIds = const <String>{},
  }) : _recentAttempts = recentAttempts,
       _uncomfortableExerciseIds = uncomfortableExerciseIds,
       _lessComfortableRoutineIds = lessComfortableRoutineIds,
       super._();

  final List<RecentRoutineAttempt> _recentAttempts;
  @override
  @JsonKey()
  List<RecentRoutineAttempt> get recentAttempts {
    if (_recentAttempts is EqualUnmodifiableListView) return _recentAttempts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentAttempts);
  }

  final Set<String> _uncomfortableExerciseIds;
  @override
  @JsonKey()
  Set<String> get uncomfortableExerciseIds {
    if (_uncomfortableExerciseIds is EqualUnmodifiableSetView)
      return _uncomfortableExerciseIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_uncomfortableExerciseIds);
  }

  /// Routines whose session received a categorical `less_comfortable`
  /// response. This is the aggregate, exercise-agnostic prior-feedback signal
  /// consumed by the engine's discomfort penalty.
  final Set<String> _lessComfortableRoutineIds;

  /// Routines whose session received a categorical `less_comfortable`
  /// response. This is the aggregate, exercise-agnostic prior-feedback signal
  /// consumed by the engine's discomfort penalty.
  @override
  @JsonKey()
  Set<String> get lessComfortableRoutineIds {
    if (_lessComfortableRoutineIds is EqualUnmodifiableSetView)
      return _lessComfortableRoutineIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_lessComfortableRoutineIds);
  }

  /// Create a copy of RecommendationHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecommendationHistoryCopyWith<_RecommendationHistory> get copyWith =>
      __$RecommendationHistoryCopyWithImpl<_RecommendationHistory>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecommendationHistory &&
            const DeepCollectionEquality().equals(
              other._recentAttempts,
              _recentAttempts,
            ) &&
            const DeepCollectionEquality().equals(
              other._uncomfortableExerciseIds,
              _uncomfortableExerciseIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._lessComfortableRoutineIds,
              _lessComfortableRoutineIds,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_recentAttempts),
    const DeepCollectionEquality().hash(_uncomfortableExerciseIds),
    const DeepCollectionEquality().hash(_lessComfortableRoutineIds),
  );

  @override
  String toString() {
    return 'RecommendationHistory(recentAttempts: $recentAttempts, uncomfortableExerciseIds: $uncomfortableExerciseIds, lessComfortableRoutineIds: $lessComfortableRoutineIds)';
  }
}

/// @nodoc
abstract mixin class _$RecommendationHistoryCopyWith<$Res>
    implements $RecommendationHistoryCopyWith<$Res> {
  factory _$RecommendationHistoryCopyWith(
    _RecommendationHistory value,
    $Res Function(_RecommendationHistory) _then,
  ) = __$RecommendationHistoryCopyWithImpl;
  @override
  @useResult
  $Res call({
    List<RecentRoutineAttempt> recentAttempts,
    Set<String> uncomfortableExerciseIds,
    Set<String> lessComfortableRoutineIds,
  });
}

/// @nodoc
class __$RecommendationHistoryCopyWithImpl<$Res>
    implements _$RecommendationHistoryCopyWith<$Res> {
  __$RecommendationHistoryCopyWithImpl(this._self, this._then);

  final _RecommendationHistory _self;
  final $Res Function(_RecommendationHistory) _then;

  /// Create a copy of RecommendationHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? recentAttempts = null,
    Object? uncomfortableExerciseIds = null,
    Object? lessComfortableRoutineIds = null,
  }) {
    return _then(
      _RecommendationHistory(
        recentAttempts: null == recentAttempts
            ? _self._recentAttempts
            : recentAttempts // ignore: cast_nullable_to_non_nullable
                  as List<RecentRoutineAttempt>,
        uncomfortableExerciseIds: null == uncomfortableExerciseIds
            ? _self._uncomfortableExerciseIds
            : uncomfortableExerciseIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        lessComfortableRoutineIds: null == lessComfortableRoutineIds
            ? _self._lessComfortableRoutineIds
            : lessComfortableRoutineIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
      ),
    );
  }
}
