// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_engine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecommendationRequest {
  CheckInAnswers get checkIn;
  List<RecommendationCandidate> get candidates;
  UserPreferences get preferences;
  RecommendationHistory get history;
  RecommendationConfig get config;

  /// The "now" instant for the recency window. Must be injected (not read
  /// from the system clock) so the engine is deterministic in tests.
  DateTime get now;

  /// The running application version (`MAJOR.MINOR.PATCH`).
  String get appVersion;

  /// Whether the user currently holds premium access. Free content is always
  /// eligible; premium candidates require this to be true.
  bool get hasPremiumAccess;

  /// Accumulated refinements from rejected alternatives (RAHA-043). Empty by
  /// default; the engine applies exclusions and the difficulty override.
  RecommendationRefinement get refinement;

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecommendationRequestCopyWith<RecommendationRequest> get copyWith =>
      _$RecommendationRequestCopyWithImpl<RecommendationRequest>(
        this as RecommendationRequest,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecommendationRequest &&
            (identical(other.checkIn, checkIn) || other.checkIn == checkIn) &&
            const DeepCollectionEquality().equals(
              other.candidates,
              candidates,
            ) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences) &&
            (identical(other.history, history) || other.history == history) &&
            (identical(other.config, config) || other.config == config) &&
            (identical(other.now, now) || other.now == now) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            (identical(other.hasPremiumAccess, hasPremiumAccess) ||
                other.hasPremiumAccess == hasPremiumAccess) &&
            (identical(other.refinement, refinement) ||
                other.refinement == refinement));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    checkIn,
    const DeepCollectionEquality().hash(candidates),
    preferences,
    history,
    config,
    now,
    appVersion,
    hasPremiumAccess,
    refinement,
  );

  @override
  String toString() {
    return 'RecommendationRequest(checkIn: $checkIn, candidates: $candidates, preferences: $preferences, history: $history, config: $config, now: $now, appVersion: $appVersion, hasPremiumAccess: $hasPremiumAccess, refinement: $refinement)';
  }
}

/// @nodoc
abstract mixin class $RecommendationRequestCopyWith<$Res> {
  factory $RecommendationRequestCopyWith(
    RecommendationRequest value,
    $Res Function(RecommendationRequest) _then,
  ) = _$RecommendationRequestCopyWithImpl;
  @useResult
  $Res call({
    CheckInAnswers checkIn,
    List<RecommendationCandidate> candidates,
    UserPreferences preferences,
    RecommendationHistory history,
    RecommendationConfig config,
    DateTime now,
    String appVersion,
    bool hasPremiumAccess,
    RecommendationRefinement refinement,
  });

  $CheckInAnswersCopyWith<$Res> get checkIn;
  $UserPreferencesCopyWith<$Res> get preferences;
  $RecommendationHistoryCopyWith<$Res> get history;
  $RecommendationConfigCopyWith<$Res> get config;
  $RecommendationRefinementCopyWith<$Res> get refinement;
}

/// @nodoc
class _$RecommendationRequestCopyWithImpl<$Res>
    implements $RecommendationRequestCopyWith<$Res> {
  _$RecommendationRequestCopyWithImpl(this._self, this._then);

  final RecommendationRequest _self;
  final $Res Function(RecommendationRequest) _then;

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? checkIn = null,
    Object? candidates = null,
    Object? preferences = null,
    Object? history = null,
    Object? config = null,
    Object? now = null,
    Object? appVersion = null,
    Object? hasPremiumAccess = null,
    Object? refinement = null,
  }) {
    return _then(
      RecommendationRequest(
        checkIn: null == checkIn
            ? _self.checkIn
            : checkIn // ignore: cast_nullable_to_non_nullable
                  as CheckInAnswers,
        candidates: null == candidates
            ? _self.candidates
            : candidates // ignore: cast_nullable_to_non_nullable
                  as List<RecommendationCandidate>,
        preferences: null == preferences
            ? _self.preferences
            : preferences // ignore: cast_nullable_to_non_nullable
                  as UserPreferences,
        history: null == history
            ? _self.history
            : history // ignore: cast_nullable_to_non_nullable
                  as RecommendationHistory,
        config: null == config
            ? _self.config
            : config // ignore: cast_nullable_to_non_nullable
                  as RecommendationConfig,
        now: null == now
            ? _self.now
            : now // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        appVersion: null == appVersion
            ? _self.appVersion
            : appVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        hasPremiumAccess: null == hasPremiumAccess
            ? _self.hasPremiumAccess
            : hasPremiumAccess // ignore: cast_nullable_to_non_nullable
                  as bool,
        refinement: null == refinement
            ? _self.refinement
            : refinement // ignore: cast_nullable_to_non_nullable
                  as RecommendationRefinement,
      ),
    );
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInAnswersCopyWith<$Res> get checkIn {
    return $CheckInAnswersCopyWith<$Res>(_self.checkIn, (value) {
      return _then(_self.copyWith(checkIn: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserPreferencesCopyWith<$Res> get preferences {
    return $UserPreferencesCopyWith<$Res>(_self.preferences, (value) {
      return _then(_self.copyWith(preferences: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecommendationHistoryCopyWith<$Res> get history {
    return $RecommendationHistoryCopyWith<$Res>(_self.history, (value) {
      return _then(_self.copyWith(history: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecommendationConfigCopyWith<$Res> get config {
    return $RecommendationConfigCopyWith<$Res>(_self.config, (value) {
      return _then(_self.copyWith(config: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecommendationRefinementCopyWith<$Res> get refinement {
    return $RecommendationRefinementCopyWith<$Res>(_self.refinement, (value) {
      return _then(_self.copyWith(refinement: value));
    });
  }
}

/// Adds pattern-matching-related methods to [RecommendationRequest].
extension RecommendationRequestPatterns on RecommendationRequest {
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
    TResult Function(_RecommendationRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationRequest() when $default != null:
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
    TResult Function(_RecommendationRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationRequest():
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
    TResult? Function(_RecommendationRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationRequest() when $default != null:
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
      CheckInAnswers checkIn,
      List<RecommendationCandidate> candidates,
      UserPreferences preferences,
      RecommendationHistory history,
      RecommendationConfig config,
      DateTime now,
      String appVersion,
      bool hasPremiumAccess,
      RecommendationRefinement refinement,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationRequest() when $default != null:
        return $default(
          _that.checkIn,
          _that.candidates,
          _that.preferences,
          _that.history,
          _that.config,
          _that.now,
          _that.appVersion,
          _that.hasPremiumAccess,
          _that.refinement,
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
      CheckInAnswers checkIn,
      List<RecommendationCandidate> candidates,
      UserPreferences preferences,
      RecommendationHistory history,
      RecommendationConfig config,
      DateTime now,
      String appVersion,
      bool hasPremiumAccess,
      RecommendationRefinement refinement,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationRequest():
        return $default(
          _that.checkIn,
          _that.candidates,
          _that.preferences,
          _that.history,
          _that.config,
          _that.now,
          _that.appVersion,
          _that.hasPremiumAccess,
          _that.refinement,
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
      CheckInAnswers checkIn,
      List<RecommendationCandidate> candidates,
      UserPreferences preferences,
      RecommendationHistory history,
      RecommendationConfig config,
      DateTime now,
      String appVersion,
      bool hasPremiumAccess,
      RecommendationRefinement refinement,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationRequest() when $default != null:
        return $default(
          _that.checkIn,
          _that.candidates,
          _that.preferences,
          _that.history,
          _that.config,
          _that.now,
          _that.appVersion,
          _that.hasPremiumAccess,
          _that.refinement,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RecommendationRequest implements RecommendationRequest {
  const _RecommendationRequest({
    required this.checkIn,
    required List<RecommendationCandidate> candidates,
    required this.preferences,
    required this.history,
    required this.config,
    required this.now,
    required this.appVersion,
    this.hasPremiumAccess = false,
    this.refinement = RecommendationRefinement.initial,
  }) : _candidates = candidates;

  @override
  final CheckInAnswers checkIn;
  final List<RecommendationCandidate> _candidates;
  @override
  List<RecommendationCandidate> get candidates {
    if (_candidates is EqualUnmodifiableListView) return _candidates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_candidates);
  }

  @override
  final UserPreferences preferences;
  @override
  final RecommendationHistory history;
  @override
  final RecommendationConfig config;

  /// The "now" instant for the recency window. Must be injected (not read
  /// from the system clock) so the engine is deterministic in tests.
  @override
  final DateTime now;

  /// The running application version (`MAJOR.MINOR.PATCH`).
  @override
  final String appVersion;

  /// Whether the user currently holds premium access. Free content is always
  /// eligible; premium candidates require this to be true.
  @override
  @JsonKey()
  final bool hasPremiumAccess;

  /// Accumulated refinements from rejected alternatives (RAHA-043). Empty by
  /// default; the engine applies exclusions and the difficulty override.
  @override
  @JsonKey()
  final RecommendationRefinement refinement;

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecommendationRequestCopyWith<_RecommendationRequest> get copyWith =>
      __$RecommendationRequestCopyWithImpl<_RecommendationRequest>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecommendationRequest &&
            (identical(other.checkIn, checkIn) || other.checkIn == checkIn) &&
            const DeepCollectionEquality().equals(
              other._candidates,
              _candidates,
            ) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences) &&
            (identical(other.history, history) || other.history == history) &&
            (identical(other.config, config) || other.config == config) &&
            (identical(other.now, now) || other.now == now) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            (identical(other.hasPremiumAccess, hasPremiumAccess) ||
                other.hasPremiumAccess == hasPremiumAccess) &&
            (identical(other.refinement, refinement) ||
                other.refinement == refinement));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    checkIn,
    const DeepCollectionEquality().hash(_candidates),
    preferences,
    history,
    config,
    now,
    appVersion,
    hasPremiumAccess,
    refinement,
  );

  @override
  String toString() {
    return 'RecommendationRequest(checkIn: $checkIn, candidates: $candidates, preferences: $preferences, history: $history, config: $config, now: $now, appVersion: $appVersion, hasPremiumAccess: $hasPremiumAccess, refinement: $refinement)';
  }
}

/// @nodoc
abstract mixin class _$RecommendationRequestCopyWith<$Res>
    implements $RecommendationRequestCopyWith<$Res> {
  factory _$RecommendationRequestCopyWith(
    _RecommendationRequest value,
    $Res Function(_RecommendationRequest) _then,
  ) = __$RecommendationRequestCopyWithImpl;
  @override
  @useResult
  $Res call({
    CheckInAnswers checkIn,
    List<RecommendationCandidate> candidates,
    UserPreferences preferences,
    RecommendationHistory history,
    RecommendationConfig config,
    DateTime now,
    String appVersion,
    bool hasPremiumAccess,
    RecommendationRefinement refinement,
  });

  @override
  $CheckInAnswersCopyWith<$Res> get checkIn;
  @override
  $UserPreferencesCopyWith<$Res> get preferences;
  @override
  $RecommendationHistoryCopyWith<$Res> get history;
  @override
  $RecommendationConfigCopyWith<$Res> get config;
  @override
  $RecommendationRefinementCopyWith<$Res> get refinement;
}

/// @nodoc
class __$RecommendationRequestCopyWithImpl<$Res>
    implements _$RecommendationRequestCopyWith<$Res> {
  __$RecommendationRequestCopyWithImpl(this._self, this._then);

  final _RecommendationRequest _self;
  final $Res Function(_RecommendationRequest) _then;

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? checkIn = null,
    Object? candidates = null,
    Object? preferences = null,
    Object? history = null,
    Object? config = null,
    Object? now = null,
    Object? appVersion = null,
    Object? hasPremiumAccess = null,
    Object? refinement = null,
  }) {
    return _then(
      _RecommendationRequest(
        checkIn: null == checkIn
            ? _self.checkIn
            : checkIn // ignore: cast_nullable_to_non_nullable
                  as CheckInAnswers,
        candidates: null == candidates
            ? _self._candidates
            : candidates // ignore: cast_nullable_to_non_nullable
                  as List<RecommendationCandidate>,
        preferences: null == preferences
            ? _self.preferences
            : preferences // ignore: cast_nullable_to_non_nullable
                  as UserPreferences,
        history: null == history
            ? _self.history
            : history // ignore: cast_nullable_to_non_nullable
                  as RecommendationHistory,
        config: null == config
            ? _self.config
            : config // ignore: cast_nullable_to_non_nullable
                  as RecommendationConfig,
        now: null == now
            ? _self.now
            : now // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        appVersion: null == appVersion
            ? _self.appVersion
            : appVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        hasPremiumAccess: null == hasPremiumAccess
            ? _self.hasPremiumAccess
            : hasPremiumAccess // ignore: cast_nullable_to_non_nullable
                  as bool,
        refinement: null == refinement
            ? _self.refinement
            : refinement // ignore: cast_nullable_to_non_nullable
                  as RecommendationRefinement,
      ),
    );
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInAnswersCopyWith<$Res> get checkIn {
    return $CheckInAnswersCopyWith<$Res>(_self.checkIn, (value) {
      return _then(_self.copyWith(checkIn: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserPreferencesCopyWith<$Res> get preferences {
    return $UserPreferencesCopyWith<$Res>(_self.preferences, (value) {
      return _then(_self.copyWith(preferences: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecommendationHistoryCopyWith<$Res> get history {
    return $RecommendationHistoryCopyWith<$Res>(_self.history, (value) {
      return _then(_self.copyWith(history: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecommendationConfigCopyWith<$Res> get config {
    return $RecommendationConfigCopyWith<$Res>(_self.config, (value) {
      return _then(_self.copyWith(config: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecommendationRefinementCopyWith<$Res> get refinement {
    return $RecommendationRefinementCopyWith<$Res>(_self.refinement, (value) {
      return _then(_self.copyWith(refinement: value));
    });
  }
}

/// @nodoc
mixin _$ScoredRoutine {
  String get routineId;

  /// Zero-based rank (0 = top candidate). Matches the local convention used
  /// by `local_recommendations.rank`.
  int get rank;

  /// Total score, comparable only within [RecommendationResult.engineVersion].
  int get score;

  /// Component key → integer contribution. Deterministically ordered.
  Map<String, int> get scoreComponents;

  /// Stable, language-neutral reason keys, in canonical order.
  List<String> get reasonCodes;

  /// Create a copy of ScoredRoutine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScoredRoutineCopyWith<ScoredRoutine> get copyWith =>
      _$ScoredRoutineCopyWithImpl<ScoredRoutine>(
        this as ScoredRoutine,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScoredRoutine &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.score, score) || other.score == score) &&
            const DeepCollectionEquality().equals(
              other.scoreComponents,
              scoreComponents,
            ) &&
            const DeepCollectionEquality().equals(
              other.reasonCodes,
              reasonCodes,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    routineId,
    rank,
    score,
    const DeepCollectionEquality().hash(scoreComponents),
    const DeepCollectionEquality().hash(reasonCodes),
  );

  @override
  String toString() {
    return 'ScoredRoutine(routineId: $routineId, rank: $rank, score: $score, scoreComponents: $scoreComponents, reasonCodes: $reasonCodes)';
  }
}

/// @nodoc
abstract mixin class $ScoredRoutineCopyWith<$Res> {
  factory $ScoredRoutineCopyWith(
    ScoredRoutine value,
    $Res Function(ScoredRoutine) _then,
  ) = _$ScoredRoutineCopyWithImpl;
  @useResult
  $Res call({
    String routineId,
    int rank,
    int score,
    Map<String, int> scoreComponents,
    List<String> reasonCodes,
  });
}

/// @nodoc
class _$ScoredRoutineCopyWithImpl<$Res>
    implements $ScoredRoutineCopyWith<$Res> {
  _$ScoredRoutineCopyWithImpl(this._self, this._then);

  final ScoredRoutine _self;
  final $Res Function(ScoredRoutine) _then;

  /// Create a copy of ScoredRoutine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routineId = null,
    Object? rank = null,
    Object? score = null,
    Object? scoreComponents = null,
    Object? reasonCodes = null,
  }) {
    return _then(
      ScoredRoutine(
        routineId: null == routineId
            ? _self.routineId
            : routineId // ignore: cast_nullable_to_non_nullable
                  as String,
        rank: null == rank
            ? _self.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        score: null == score
            ? _self.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        scoreComponents: null == scoreComponents
            ? _self.scoreComponents
            : scoreComponents // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        reasonCodes: null == reasonCodes
            ? _self.reasonCodes
            : reasonCodes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ScoredRoutine].
extension ScoredRoutinePatterns on ScoredRoutine {
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
    TResult Function(_ScoredRoutine value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScoredRoutine() when $default != null:
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
    TResult Function(_ScoredRoutine value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScoredRoutine():
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
    TResult? Function(_ScoredRoutine value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScoredRoutine() when $default != null:
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
      String routineId,
      int rank,
      int score,
      Map<String, int> scoreComponents,
      List<String> reasonCodes,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScoredRoutine() when $default != null:
        return $default(
          _that.routineId,
          _that.rank,
          _that.score,
          _that.scoreComponents,
          _that.reasonCodes,
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
      String routineId,
      int rank,
      int score,
      Map<String, int> scoreComponents,
      List<String> reasonCodes,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScoredRoutine():
        return $default(
          _that.routineId,
          _that.rank,
          _that.score,
          _that.scoreComponents,
          _that.reasonCodes,
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
      String routineId,
      int rank,
      int score,
      Map<String, int> scoreComponents,
      List<String> reasonCodes,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScoredRoutine() when $default != null:
        return $default(
          _that.routineId,
          _that.rank,
          _that.score,
          _that.scoreComponents,
          _that.reasonCodes,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ScoredRoutine implements ScoredRoutine {
  const _ScoredRoutine({
    required this.routineId,
    required this.rank,
    required this.score,
    required Map<String, int> scoreComponents,
    required List<String> reasonCodes,
  }) : _scoreComponents = scoreComponents,
       _reasonCodes = reasonCodes;

  @override
  final String routineId;

  /// Zero-based rank (0 = top candidate). Matches the local convention used
  /// by `local_recommendations.rank`.
  @override
  final int rank;

  /// Total score, comparable only within [RecommendationResult.engineVersion].
  @override
  final int score;

  /// Component key → integer contribution. Deterministically ordered.
  final Map<String, int> _scoreComponents;

  /// Component key → integer contribution. Deterministically ordered.
  @override
  Map<String, int> get scoreComponents {
    if (_scoreComponents is EqualUnmodifiableMapView) return _scoreComponents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scoreComponents);
  }

  /// Stable, language-neutral reason keys, in canonical order.
  final List<String> _reasonCodes;

  /// Stable, language-neutral reason keys, in canonical order.
  @override
  List<String> get reasonCodes {
    if (_reasonCodes is EqualUnmodifiableListView) return _reasonCodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reasonCodes);
  }

  /// Create a copy of ScoredRoutine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScoredRoutineCopyWith<_ScoredRoutine> get copyWith =>
      __$ScoredRoutineCopyWithImpl<_ScoredRoutine>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScoredRoutine &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.score, score) || other.score == score) &&
            const DeepCollectionEquality().equals(
              other._scoreComponents,
              _scoreComponents,
            ) &&
            const DeepCollectionEquality().equals(
              other._reasonCodes,
              _reasonCodes,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    routineId,
    rank,
    score,
    const DeepCollectionEquality().hash(_scoreComponents),
    const DeepCollectionEquality().hash(_reasonCodes),
  );

  @override
  String toString() {
    return 'ScoredRoutine(routineId: $routineId, rank: $rank, score: $score, scoreComponents: $scoreComponents, reasonCodes: $reasonCodes)';
  }
}

/// @nodoc
abstract mixin class _$ScoredRoutineCopyWith<$Res>
    implements $ScoredRoutineCopyWith<$Res> {
  factory _$ScoredRoutineCopyWith(
    _ScoredRoutine value,
    $Res Function(_ScoredRoutine) _then,
  ) = __$ScoredRoutineCopyWithImpl;
  @override
  @useResult
  $Res call({
    String routineId,
    int rank,
    int score,
    Map<String, int> scoreComponents,
    List<String> reasonCodes,
  });
}

/// @nodoc
class __$ScoredRoutineCopyWithImpl<$Res>
    implements _$ScoredRoutineCopyWith<$Res> {
  __$ScoredRoutineCopyWithImpl(this._self, this._then);

  final _ScoredRoutine _self;
  final $Res Function(_ScoredRoutine) _then;

  /// Create a copy of ScoredRoutine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? routineId = null,
    Object? rank = null,
    Object? score = null,
    Object? scoreComponents = null,
    Object? reasonCodes = null,
  }) {
    return _then(
      _ScoredRoutine(
        routineId: null == routineId
            ? _self.routineId
            : routineId // ignore: cast_nullable_to_non_nullable
                  as String,
        rank: null == rank
            ? _self.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        score: null == score
            ? _self.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        scoreComponents: null == scoreComponents
            ? _self._scoreComponents
            : scoreComponents // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        reasonCodes: null == reasonCodes
            ? _self._reasonCodes
            : reasonCodes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
mixin _$RecommendationResult {
  String get engineVersion;
  List<ScoredRoutine> get recommendations;

  /// Create a copy of RecommendationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecommendationResultCopyWith<RecommendationResult> get copyWith =>
      _$RecommendationResultCopyWithImpl<RecommendationResult>(
        this as RecommendationResult,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecommendationResult &&
            (identical(other.engineVersion, engineVersion) ||
                other.engineVersion == engineVersion) &&
            const DeepCollectionEquality().equals(
              other.recommendations,
              recommendations,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    engineVersion,
    const DeepCollectionEquality().hash(recommendations),
  );

  @override
  String toString() {
    return 'RecommendationResult(engineVersion: $engineVersion, recommendations: $recommendations)';
  }
}

/// @nodoc
abstract mixin class $RecommendationResultCopyWith<$Res> {
  factory $RecommendationResultCopyWith(
    RecommendationResult value,
    $Res Function(RecommendationResult) _then,
  ) = _$RecommendationResultCopyWithImpl;
  @useResult
  $Res call({String engineVersion, List<ScoredRoutine> recommendations});
}

/// @nodoc
class _$RecommendationResultCopyWithImpl<$Res>
    implements $RecommendationResultCopyWith<$Res> {
  _$RecommendationResultCopyWithImpl(this._self, this._then);

  final RecommendationResult _self;
  final $Res Function(RecommendationResult) _then;

  /// Create a copy of RecommendationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? engineVersion = null, Object? recommendations = null}) {
    return _then(
      RecommendationResult(
        engineVersion: null == engineVersion
            ? _self.engineVersion
            : engineVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        recommendations: null == recommendations
            ? _self.recommendations
            : recommendations // ignore: cast_nullable_to_non_nullable
                  as List<ScoredRoutine>,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [RecommendationResult].
extension RecommendationResultPatterns on RecommendationResult {
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
    TResult Function(_RecommendationResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationResult() when $default != null:
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
    TResult Function(_RecommendationResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationResult():
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
    TResult? Function(_RecommendationResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationResult() when $default != null:
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
    TResult Function(String engineVersion, List<ScoredRoutine> recommendations)?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationResult() when $default != null:
        return $default(_that.engineVersion, _that.recommendations);
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
    TResult Function(String engineVersion, List<ScoredRoutine> recommendations)
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationResult():
        return $default(_that.engineVersion, _that.recommendations);
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
      String engineVersion,
      List<ScoredRoutine> recommendations,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationResult() when $default != null:
        return $default(_that.engineVersion, _that.recommendations);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RecommendationResult extends RecommendationResult {
  const _RecommendationResult({
    required this.engineVersion,
    required List<ScoredRoutine> recommendations,
  }) : _recommendations = recommendations,
       super._();

  @override
  final String engineVersion;
  final List<ScoredRoutine> _recommendations;
  @override
  List<ScoredRoutine> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  /// Create a copy of RecommendationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecommendationResultCopyWith<_RecommendationResult> get copyWith =>
      __$RecommendationResultCopyWithImpl<_RecommendationResult>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecommendationResult &&
            (identical(other.engineVersion, engineVersion) ||
                other.engineVersion == engineVersion) &&
            const DeepCollectionEquality().equals(
              other._recommendations,
              _recommendations,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    engineVersion,
    const DeepCollectionEquality().hash(_recommendations),
  );

  @override
  String toString() {
    return 'RecommendationResult(engineVersion: $engineVersion, recommendations: $recommendations)';
  }
}

/// @nodoc
abstract mixin class _$RecommendationResultCopyWith<$Res>
    implements $RecommendationResultCopyWith<$Res> {
  factory _$RecommendationResultCopyWith(
    _RecommendationResult value,
    $Res Function(_RecommendationResult) _then,
  ) = __$RecommendationResultCopyWithImpl;
  @override
  @useResult
  $Res call({String engineVersion, List<ScoredRoutine> recommendations});
}

/// @nodoc
class __$RecommendationResultCopyWithImpl<$Res>
    implements _$RecommendationResultCopyWith<$Res> {
  __$RecommendationResultCopyWithImpl(this._self, this._then);

  final _RecommendationResult _self;
  final $Res Function(_RecommendationResult) _then;

  /// Create a copy of RecommendationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? engineVersion = null, Object? recommendations = null}) {
    return _then(
      _RecommendationResult(
        engineVersion: null == engineVersion
            ? _self.engineVersion
            : engineVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        recommendations: null == recommendations
            ? _self._recommendations
            : recommendations // ignore: cast_nullable_to_non_nullable
                  as List<ScoredRoutine>,
      ),
    );
  }
}
