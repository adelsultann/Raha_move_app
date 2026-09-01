// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_rejection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecommendationRefinement {
  /// Routines already rejected for this check-in. A rejected routine is never
  /// immediately returned while another compatible candidate exists, and this
  /// set grows monotonically, guaranteeing the sequence terminates.
  Set<String> get rejectedRoutineIds;

  /// Position keys the user cannot use (constraint: filtering).
  Set<String> get excludedPositionKeys;

  /// Body-area keys the user reports uncomfortable (constraint: filtering).
  Set<String> get excludedBodyAreaKeys;

  /// Preferred difficulty after `too_easy`/`too_difficult` (preference:
  /// scoring). Null means "use the experience-level default".
  DifficultyLevel? get difficultyOverride;

  /// Create a copy of RecommendationRefinement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecommendationRefinementCopyWith<RecommendationRefinement> get copyWith =>
      _$RecommendationRefinementCopyWithImpl<RecommendationRefinement>(
        this as RecommendationRefinement,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecommendationRefinement &&
            const DeepCollectionEquality().equals(
              other.rejectedRoutineIds,
              rejectedRoutineIds,
            ) &&
            const DeepCollectionEquality().equals(
              other.excludedPositionKeys,
              excludedPositionKeys,
            ) &&
            const DeepCollectionEquality().equals(
              other.excludedBodyAreaKeys,
              excludedBodyAreaKeys,
            ) &&
            (identical(other.difficultyOverride, difficultyOverride) ||
                other.difficultyOverride == difficultyOverride));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(rejectedRoutineIds),
    const DeepCollectionEquality().hash(excludedPositionKeys),
    const DeepCollectionEquality().hash(excludedBodyAreaKeys),
    difficultyOverride,
  );

  @override
  String toString() {
    return 'RecommendationRefinement(rejectedRoutineIds: $rejectedRoutineIds, excludedPositionKeys: $excludedPositionKeys, excludedBodyAreaKeys: $excludedBodyAreaKeys, difficultyOverride: $difficultyOverride)';
  }
}

/// @nodoc
abstract mixin class $RecommendationRefinementCopyWith<$Res> {
  factory $RecommendationRefinementCopyWith(
    RecommendationRefinement value,
    $Res Function(RecommendationRefinement) _then,
  ) = _$RecommendationRefinementCopyWithImpl;
  @useResult
  $Res call({
    Set<String> rejectedRoutineIds,
    Set<String> excludedPositionKeys,
    Set<String> excludedBodyAreaKeys,
    DifficultyLevel? difficultyOverride,
  });
}

/// @nodoc
class _$RecommendationRefinementCopyWithImpl<$Res>
    implements $RecommendationRefinementCopyWith<$Res> {
  _$RecommendationRefinementCopyWithImpl(this._self, this._then);

  final RecommendationRefinement _self;
  final $Res Function(RecommendationRefinement) _then;

  /// Create a copy of RecommendationRefinement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rejectedRoutineIds = null,
    Object? excludedPositionKeys = null,
    Object? excludedBodyAreaKeys = null,
    Object? difficultyOverride = freezed,
  }) {
    return _then(
      RecommendationRefinement(
        rejectedRoutineIds: null == rejectedRoutineIds
            ? _self.rejectedRoutineIds
            : rejectedRoutineIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        excludedPositionKeys: null == excludedPositionKeys
            ? _self.excludedPositionKeys
            : excludedPositionKeys // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        excludedBodyAreaKeys: null == excludedBodyAreaKeys
            ? _self.excludedBodyAreaKeys
            : excludedBodyAreaKeys // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        difficultyOverride: freezed == difficultyOverride
            ? _self.difficultyOverride
            : difficultyOverride // ignore: cast_nullable_to_non_nullable
                  as DifficultyLevel?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [RecommendationRefinement].
extension RecommendationRefinementPatterns on RecommendationRefinement {
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
    TResult Function(_RecommendationRefinement value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationRefinement() when $default != null:
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
    TResult Function(_RecommendationRefinement value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationRefinement():
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
    TResult? Function(_RecommendationRefinement value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationRefinement() when $default != null:
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
      Set<String> rejectedRoutineIds,
      Set<String> excludedPositionKeys,
      Set<String> excludedBodyAreaKeys,
      DifficultyLevel? difficultyOverride,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationRefinement() when $default != null:
        return $default(
          _that.rejectedRoutineIds,
          _that.excludedPositionKeys,
          _that.excludedBodyAreaKeys,
          _that.difficultyOverride,
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
      Set<String> rejectedRoutineIds,
      Set<String> excludedPositionKeys,
      Set<String> excludedBodyAreaKeys,
      DifficultyLevel? difficultyOverride,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationRefinement():
        return $default(
          _that.rejectedRoutineIds,
          _that.excludedPositionKeys,
          _that.excludedBodyAreaKeys,
          _that.difficultyOverride,
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
      Set<String> rejectedRoutineIds,
      Set<String> excludedPositionKeys,
      Set<String> excludedBodyAreaKeys,
      DifficultyLevel? difficultyOverride,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationRefinement() when $default != null:
        return $default(
          _that.rejectedRoutineIds,
          _that.excludedPositionKeys,
          _that.excludedBodyAreaKeys,
          _that.difficultyOverride,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RecommendationRefinement extends RecommendationRefinement {
  const _RecommendationRefinement({
    Set<String> rejectedRoutineIds = const <String>{},
    Set<String> excludedPositionKeys = const <String>{},
    Set<String> excludedBodyAreaKeys = const <String>{},
    this.difficultyOverride,
  }) : _rejectedRoutineIds = rejectedRoutineIds,
       _excludedPositionKeys = excludedPositionKeys,
       _excludedBodyAreaKeys = excludedBodyAreaKeys,
       super._();

  /// Routines already rejected for this check-in. A rejected routine is never
  /// immediately returned while another compatible candidate exists, and this
  /// set grows monotonically, guaranteeing the sequence terminates.
  final Set<String> _rejectedRoutineIds;

  /// Routines already rejected for this check-in. A rejected routine is never
  /// immediately returned while another compatible candidate exists, and this
  /// set grows monotonically, guaranteeing the sequence terminates.
  @override
  @JsonKey()
  Set<String> get rejectedRoutineIds {
    if (_rejectedRoutineIds is EqualUnmodifiableSetView)
      return _rejectedRoutineIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_rejectedRoutineIds);
  }

  /// Position keys the user cannot use (constraint: filtering).
  final Set<String> _excludedPositionKeys;

  /// Position keys the user cannot use (constraint: filtering).
  @override
  @JsonKey()
  Set<String> get excludedPositionKeys {
    if (_excludedPositionKeys is EqualUnmodifiableSetView)
      return _excludedPositionKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_excludedPositionKeys);
  }

  /// Body-area keys the user reports uncomfortable (constraint: filtering).
  final Set<String> _excludedBodyAreaKeys;

  /// Body-area keys the user reports uncomfortable (constraint: filtering).
  @override
  @JsonKey()
  Set<String> get excludedBodyAreaKeys {
    if (_excludedBodyAreaKeys is EqualUnmodifiableSetView)
      return _excludedBodyAreaKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_excludedBodyAreaKeys);
  }

  /// Preferred difficulty after `too_easy`/`too_difficult` (preference:
  /// scoring). Null means "use the experience-level default".
  @override
  final DifficultyLevel? difficultyOverride;

  /// Create a copy of RecommendationRefinement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecommendationRefinementCopyWith<_RecommendationRefinement> get copyWith =>
      __$RecommendationRefinementCopyWithImpl<_RecommendationRefinement>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecommendationRefinement &&
            const DeepCollectionEquality().equals(
              other._rejectedRoutineIds,
              _rejectedRoutineIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._excludedPositionKeys,
              _excludedPositionKeys,
            ) &&
            const DeepCollectionEquality().equals(
              other._excludedBodyAreaKeys,
              _excludedBodyAreaKeys,
            ) &&
            (identical(other.difficultyOverride, difficultyOverride) ||
                other.difficultyOverride == difficultyOverride));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_rejectedRoutineIds),
    const DeepCollectionEquality().hash(_excludedPositionKeys),
    const DeepCollectionEquality().hash(_excludedBodyAreaKeys),
    difficultyOverride,
  );

  @override
  String toString() {
    return 'RecommendationRefinement(rejectedRoutineIds: $rejectedRoutineIds, excludedPositionKeys: $excludedPositionKeys, excludedBodyAreaKeys: $excludedBodyAreaKeys, difficultyOverride: $difficultyOverride)';
  }
}

/// @nodoc
abstract mixin class _$RecommendationRefinementCopyWith<$Res>
    implements $RecommendationRefinementCopyWith<$Res> {
  factory _$RecommendationRefinementCopyWith(
    _RecommendationRefinement value,
    $Res Function(_RecommendationRefinement) _then,
  ) = __$RecommendationRefinementCopyWithImpl;
  @override
  @useResult
  $Res call({
    Set<String> rejectedRoutineIds,
    Set<String> excludedPositionKeys,
    Set<String> excludedBodyAreaKeys,
    DifficultyLevel? difficultyOverride,
  });
}

/// @nodoc
class __$RecommendationRefinementCopyWithImpl<$Res>
    implements _$RecommendationRefinementCopyWith<$Res> {
  __$RecommendationRefinementCopyWithImpl(this._self, this._then);

  final _RecommendationRefinement _self;
  final $Res Function(_RecommendationRefinement) _then;

  /// Create a copy of RecommendationRefinement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? rejectedRoutineIds = null,
    Object? excludedPositionKeys = null,
    Object? excludedBodyAreaKeys = null,
    Object? difficultyOverride = freezed,
  }) {
    return _then(
      _RecommendationRefinement(
        rejectedRoutineIds: null == rejectedRoutineIds
            ? _self._rejectedRoutineIds
            : rejectedRoutineIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        excludedPositionKeys: null == excludedPositionKeys
            ? _self._excludedPositionKeys
            : excludedPositionKeys // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        excludedBodyAreaKeys: null == excludedBodyAreaKeys
            ? _self._excludedBodyAreaKeys
            : excludedBodyAreaKeys // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        difficultyOverride: freezed == difficultyOverride
            ? _self.difficultyOverride
            : difficultyOverride // ignore: cast_nullable_to_non_nullable
                  as DifficultyLevel?,
      ),
    );
  }
}
