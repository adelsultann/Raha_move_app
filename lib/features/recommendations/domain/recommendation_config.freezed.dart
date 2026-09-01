// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecommendationConfig {
  /// Stable engine version recorded with every recommendation.
  String get version;

  /// Points added per selected body area the routine addresses.
  int get bodyAreaMatchWeight;

  /// Points added when the routine serves the selected goal.
  int get goalMatchWeight;

  /// Maximum time-fit points, scaled by how fully the routine fills the
  /// selected duration.
  int get timeMatchWeight;

  /// Points added when the routine can be performed in a preferred position.
  int get positionPreferenceWeight;

  /// Points added when the routine difficulty matches the experience level.
  int get difficultyMatchWeight;

  /// Points subtracted when the routine was recently completed.
  int get recencyPenaltyWeight;

  /// Points subtracted when the routine contains a previously uncomfortable
  /// exercise.
  int get discomfortPenaltyWeight;

  /// Allowed overshoot beyond the selected time in seconds. The MVP default
  /// is zero: a routine never exceeds the selected time unless a later
  /// product decision configures and explains a tolerance.
  int get maxDurationOvershootSeconds;

  /// How many days a prior completion remains "recent".
  int get recencyWindowDays;

  /// Create a copy of RecommendationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecommendationConfigCopyWith<RecommendationConfig> get copyWith =>
      _$RecommendationConfigCopyWithImpl<RecommendationConfig>(
        this as RecommendationConfig,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecommendationConfig &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.bodyAreaMatchWeight, bodyAreaMatchWeight) ||
                other.bodyAreaMatchWeight == bodyAreaMatchWeight) &&
            (identical(other.goalMatchWeight, goalMatchWeight) ||
                other.goalMatchWeight == goalMatchWeight) &&
            (identical(other.timeMatchWeight, timeMatchWeight) ||
                other.timeMatchWeight == timeMatchWeight) &&
            (identical(
                  other.positionPreferenceWeight,
                  positionPreferenceWeight,
                ) ||
                other.positionPreferenceWeight == positionPreferenceWeight) &&
            (identical(other.difficultyMatchWeight, difficultyMatchWeight) ||
                other.difficultyMatchWeight == difficultyMatchWeight) &&
            (identical(other.recencyPenaltyWeight, recencyPenaltyWeight) ||
                other.recencyPenaltyWeight == recencyPenaltyWeight) &&
            (identical(
                  other.discomfortPenaltyWeight,
                  discomfortPenaltyWeight,
                ) ||
                other.discomfortPenaltyWeight == discomfortPenaltyWeight) &&
            (identical(
                  other.maxDurationOvershootSeconds,
                  maxDurationOvershootSeconds,
                ) ||
                other.maxDurationOvershootSeconds ==
                    maxDurationOvershootSeconds) &&
            (identical(other.recencyWindowDays, recencyWindowDays) ||
                other.recencyWindowDays == recencyWindowDays));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    version,
    bodyAreaMatchWeight,
    goalMatchWeight,
    timeMatchWeight,
    positionPreferenceWeight,
    difficultyMatchWeight,
    recencyPenaltyWeight,
    discomfortPenaltyWeight,
    maxDurationOvershootSeconds,
    recencyWindowDays,
  );

  @override
  String toString() {
    return 'RecommendationConfig(version: $version, bodyAreaMatchWeight: $bodyAreaMatchWeight, goalMatchWeight: $goalMatchWeight, timeMatchWeight: $timeMatchWeight, positionPreferenceWeight: $positionPreferenceWeight, difficultyMatchWeight: $difficultyMatchWeight, recencyPenaltyWeight: $recencyPenaltyWeight, discomfortPenaltyWeight: $discomfortPenaltyWeight, maxDurationOvershootSeconds: $maxDurationOvershootSeconds, recencyWindowDays: $recencyWindowDays)';
  }
}

/// @nodoc
abstract mixin class $RecommendationConfigCopyWith<$Res> {
  factory $RecommendationConfigCopyWith(
    RecommendationConfig value,
    $Res Function(RecommendationConfig) _then,
  ) = _$RecommendationConfigCopyWithImpl;
  @useResult
  $Res call({
    String version,
    int bodyAreaMatchWeight,
    int goalMatchWeight,
    int timeMatchWeight,
    int positionPreferenceWeight,
    int difficultyMatchWeight,
    int recencyPenaltyWeight,
    int discomfortPenaltyWeight,
    int maxDurationOvershootSeconds,
    int recencyWindowDays,
  });
}

/// @nodoc
class _$RecommendationConfigCopyWithImpl<$Res>
    implements $RecommendationConfigCopyWith<$Res> {
  _$RecommendationConfigCopyWithImpl(this._self, this._then);

  final RecommendationConfig _self;
  final $Res Function(RecommendationConfig) _then;

  /// Create a copy of RecommendationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? bodyAreaMatchWeight = null,
    Object? goalMatchWeight = null,
    Object? timeMatchWeight = null,
    Object? positionPreferenceWeight = null,
    Object? difficultyMatchWeight = null,
    Object? recencyPenaltyWeight = null,
    Object? discomfortPenaltyWeight = null,
    Object? maxDurationOvershootSeconds = null,
    Object? recencyWindowDays = null,
  }) {
    return _then(
      RecommendationConfig(
        version: null == version
            ? _self.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
        bodyAreaMatchWeight: null == bodyAreaMatchWeight
            ? _self.bodyAreaMatchWeight
            : bodyAreaMatchWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        goalMatchWeight: null == goalMatchWeight
            ? _self.goalMatchWeight
            : goalMatchWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        timeMatchWeight: null == timeMatchWeight
            ? _self.timeMatchWeight
            : timeMatchWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        positionPreferenceWeight: null == positionPreferenceWeight
            ? _self.positionPreferenceWeight
            : positionPreferenceWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        difficultyMatchWeight: null == difficultyMatchWeight
            ? _self.difficultyMatchWeight
            : difficultyMatchWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        recencyPenaltyWeight: null == recencyPenaltyWeight
            ? _self.recencyPenaltyWeight
            : recencyPenaltyWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        discomfortPenaltyWeight: null == discomfortPenaltyWeight
            ? _self.discomfortPenaltyWeight
            : discomfortPenaltyWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        maxDurationOvershootSeconds: null == maxDurationOvershootSeconds
            ? _self.maxDurationOvershootSeconds
            : maxDurationOvershootSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        recencyWindowDays: null == recencyWindowDays
            ? _self.recencyWindowDays
            : recencyWindowDays // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [RecommendationConfig].
extension RecommendationConfigPatterns on RecommendationConfig {
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
    TResult Function(_RecommendationConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationConfig() when $default != null:
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
    TResult Function(_RecommendationConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationConfig():
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
    TResult? Function(_RecommendationConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationConfig() when $default != null:
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
      String version,
      int bodyAreaMatchWeight,
      int goalMatchWeight,
      int timeMatchWeight,
      int positionPreferenceWeight,
      int difficultyMatchWeight,
      int recencyPenaltyWeight,
      int discomfortPenaltyWeight,
      int maxDurationOvershootSeconds,
      int recencyWindowDays,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationConfig() when $default != null:
        return $default(
          _that.version,
          _that.bodyAreaMatchWeight,
          _that.goalMatchWeight,
          _that.timeMatchWeight,
          _that.positionPreferenceWeight,
          _that.difficultyMatchWeight,
          _that.recencyPenaltyWeight,
          _that.discomfortPenaltyWeight,
          _that.maxDurationOvershootSeconds,
          _that.recencyWindowDays,
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
      String version,
      int bodyAreaMatchWeight,
      int goalMatchWeight,
      int timeMatchWeight,
      int positionPreferenceWeight,
      int difficultyMatchWeight,
      int recencyPenaltyWeight,
      int discomfortPenaltyWeight,
      int maxDurationOvershootSeconds,
      int recencyWindowDays,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationConfig():
        return $default(
          _that.version,
          _that.bodyAreaMatchWeight,
          _that.goalMatchWeight,
          _that.timeMatchWeight,
          _that.positionPreferenceWeight,
          _that.difficultyMatchWeight,
          _that.recencyPenaltyWeight,
          _that.discomfortPenaltyWeight,
          _that.maxDurationOvershootSeconds,
          _that.recencyWindowDays,
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
      String version,
      int bodyAreaMatchWeight,
      int goalMatchWeight,
      int timeMatchWeight,
      int positionPreferenceWeight,
      int difficultyMatchWeight,
      int recencyPenaltyWeight,
      int discomfortPenaltyWeight,
      int maxDurationOvershootSeconds,
      int recencyWindowDays,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationConfig() when $default != null:
        return $default(
          _that.version,
          _that.bodyAreaMatchWeight,
          _that.goalMatchWeight,
          _that.timeMatchWeight,
          _that.positionPreferenceWeight,
          _that.difficultyMatchWeight,
          _that.recencyPenaltyWeight,
          _that.discomfortPenaltyWeight,
          _that.maxDurationOvershootSeconds,
          _that.recencyWindowDays,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RecommendationConfig extends RecommendationConfig {
  const _RecommendationConfig({
    required this.version,
    required this.bodyAreaMatchWeight,
    required this.goalMatchWeight,
    required this.timeMatchWeight,
    required this.positionPreferenceWeight,
    required this.difficultyMatchWeight,
    required this.recencyPenaltyWeight,
    required this.discomfortPenaltyWeight,
    required this.maxDurationOvershootSeconds,
    required this.recencyWindowDays,
  }) : super._();

  /// Stable engine version recorded with every recommendation.
  @override
  final String version;

  /// Points added per selected body area the routine addresses.
  @override
  final int bodyAreaMatchWeight;

  /// Points added when the routine serves the selected goal.
  @override
  final int goalMatchWeight;

  /// Maximum time-fit points, scaled by how fully the routine fills the
  /// selected duration.
  @override
  final int timeMatchWeight;

  /// Points added when the routine can be performed in a preferred position.
  @override
  final int positionPreferenceWeight;

  /// Points added when the routine difficulty matches the experience level.
  @override
  final int difficultyMatchWeight;

  /// Points subtracted when the routine was recently completed.
  @override
  final int recencyPenaltyWeight;

  /// Points subtracted when the routine contains a previously uncomfortable
  /// exercise.
  @override
  final int discomfortPenaltyWeight;

  /// Allowed overshoot beyond the selected time in seconds. The MVP default
  /// is zero: a routine never exceeds the selected time unless a later
  /// product decision configures and explains a tolerance.
  @override
  final int maxDurationOvershootSeconds;

  /// How many days a prior completion remains "recent".
  @override
  final int recencyWindowDays;

  /// Create a copy of RecommendationConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecommendationConfigCopyWith<_RecommendationConfig> get copyWith =>
      __$RecommendationConfigCopyWithImpl<_RecommendationConfig>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecommendationConfig &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.bodyAreaMatchWeight, bodyAreaMatchWeight) ||
                other.bodyAreaMatchWeight == bodyAreaMatchWeight) &&
            (identical(other.goalMatchWeight, goalMatchWeight) ||
                other.goalMatchWeight == goalMatchWeight) &&
            (identical(other.timeMatchWeight, timeMatchWeight) ||
                other.timeMatchWeight == timeMatchWeight) &&
            (identical(
                  other.positionPreferenceWeight,
                  positionPreferenceWeight,
                ) ||
                other.positionPreferenceWeight == positionPreferenceWeight) &&
            (identical(other.difficultyMatchWeight, difficultyMatchWeight) ||
                other.difficultyMatchWeight == difficultyMatchWeight) &&
            (identical(other.recencyPenaltyWeight, recencyPenaltyWeight) ||
                other.recencyPenaltyWeight == recencyPenaltyWeight) &&
            (identical(
                  other.discomfortPenaltyWeight,
                  discomfortPenaltyWeight,
                ) ||
                other.discomfortPenaltyWeight == discomfortPenaltyWeight) &&
            (identical(
                  other.maxDurationOvershootSeconds,
                  maxDurationOvershootSeconds,
                ) ||
                other.maxDurationOvershootSeconds ==
                    maxDurationOvershootSeconds) &&
            (identical(other.recencyWindowDays, recencyWindowDays) ||
                other.recencyWindowDays == recencyWindowDays));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    version,
    bodyAreaMatchWeight,
    goalMatchWeight,
    timeMatchWeight,
    positionPreferenceWeight,
    difficultyMatchWeight,
    recencyPenaltyWeight,
    discomfortPenaltyWeight,
    maxDurationOvershootSeconds,
    recencyWindowDays,
  );

  @override
  String toString() {
    return 'RecommendationConfig(version: $version, bodyAreaMatchWeight: $bodyAreaMatchWeight, goalMatchWeight: $goalMatchWeight, timeMatchWeight: $timeMatchWeight, positionPreferenceWeight: $positionPreferenceWeight, difficultyMatchWeight: $difficultyMatchWeight, recencyPenaltyWeight: $recencyPenaltyWeight, discomfortPenaltyWeight: $discomfortPenaltyWeight, maxDurationOvershootSeconds: $maxDurationOvershootSeconds, recencyWindowDays: $recencyWindowDays)';
  }
}

/// @nodoc
abstract mixin class _$RecommendationConfigCopyWith<$Res>
    implements $RecommendationConfigCopyWith<$Res> {
  factory _$RecommendationConfigCopyWith(
    _RecommendationConfig value,
    $Res Function(_RecommendationConfig) _then,
  ) = __$RecommendationConfigCopyWithImpl;
  @override
  @useResult
  $Res call({
    String version,
    int bodyAreaMatchWeight,
    int goalMatchWeight,
    int timeMatchWeight,
    int positionPreferenceWeight,
    int difficultyMatchWeight,
    int recencyPenaltyWeight,
    int discomfortPenaltyWeight,
    int maxDurationOvershootSeconds,
    int recencyWindowDays,
  });
}

/// @nodoc
class __$RecommendationConfigCopyWithImpl<$Res>
    implements _$RecommendationConfigCopyWith<$Res> {
  __$RecommendationConfigCopyWithImpl(this._self, this._then);

  final _RecommendationConfig _self;
  final $Res Function(_RecommendationConfig) _then;

  /// Create a copy of RecommendationConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? version = null,
    Object? bodyAreaMatchWeight = null,
    Object? goalMatchWeight = null,
    Object? timeMatchWeight = null,
    Object? positionPreferenceWeight = null,
    Object? difficultyMatchWeight = null,
    Object? recencyPenaltyWeight = null,
    Object? discomfortPenaltyWeight = null,
    Object? maxDurationOvershootSeconds = null,
    Object? recencyWindowDays = null,
  }) {
    return _then(
      _RecommendationConfig(
        version: null == version
            ? _self.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
        bodyAreaMatchWeight: null == bodyAreaMatchWeight
            ? _self.bodyAreaMatchWeight
            : bodyAreaMatchWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        goalMatchWeight: null == goalMatchWeight
            ? _self.goalMatchWeight
            : goalMatchWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        timeMatchWeight: null == timeMatchWeight
            ? _self.timeMatchWeight
            : timeMatchWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        positionPreferenceWeight: null == positionPreferenceWeight
            ? _self.positionPreferenceWeight
            : positionPreferenceWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        difficultyMatchWeight: null == difficultyMatchWeight
            ? _self.difficultyMatchWeight
            : difficultyMatchWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        recencyPenaltyWeight: null == recencyPenaltyWeight
            ? _self.recencyPenaltyWeight
            : recencyPenaltyWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        discomfortPenaltyWeight: null == discomfortPenaltyWeight
            ? _self.discomfortPenaltyWeight
            : discomfortPenaltyWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        maxDurationOvershootSeconds: null == maxDurationOvershootSeconds
            ? _self.maxDurationOvershootSeconds
            : maxDurationOvershootSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        recencyWindowDays: null == recencyWindowDays
            ? _self.recencyWindowDays
            : recencyWindowDays // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}
