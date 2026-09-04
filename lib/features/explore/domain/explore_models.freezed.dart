// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'explore_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExploreFilters {
  Set<int> get durationsMinutes;
  Set<String> get bodyAreas;
  Set<String> get positions;
  Set<DifficultyLevel> get difficulties;
  Set<String> get equipment;

  /// Create a copy of ExploreFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExploreFiltersCopyWith<ExploreFilters> get copyWith =>
      _$ExploreFiltersCopyWithImpl<ExploreFilters>(
        this as ExploreFilters,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExploreFilters &&
            const DeepCollectionEquality().equals(
              other.durationsMinutes,
              durationsMinutes,
            ) &&
            const DeepCollectionEquality().equals(other.bodyAreas, bodyAreas) &&
            const DeepCollectionEquality().equals(other.positions, positions) &&
            const DeepCollectionEquality().equals(
              other.difficulties,
              difficulties,
            ) &&
            const DeepCollectionEquality().equals(other.equipment, equipment));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(durationsMinutes),
    const DeepCollectionEquality().hash(bodyAreas),
    const DeepCollectionEquality().hash(positions),
    const DeepCollectionEquality().hash(difficulties),
    const DeepCollectionEquality().hash(equipment),
  );

  @override
  String toString() {
    return 'ExploreFilters(durationsMinutes: $durationsMinutes, bodyAreas: $bodyAreas, positions: $positions, difficulties: $difficulties, equipment: $equipment)';
  }
}

/// @nodoc
abstract mixin class $ExploreFiltersCopyWith<$Res> {
  factory $ExploreFiltersCopyWith(
    ExploreFilters value,
    $Res Function(ExploreFilters) _then,
  ) = _$ExploreFiltersCopyWithImpl;
  @useResult
  $Res call({
    Set<int> durationsMinutes,
    Set<String> bodyAreas,
    Set<String> positions,
    Set<DifficultyLevel> difficulties,
    Set<String> equipment,
  });
}

/// @nodoc
class _$ExploreFiltersCopyWithImpl<$Res>
    implements $ExploreFiltersCopyWith<$Res> {
  _$ExploreFiltersCopyWithImpl(this._self, this._then);

  final ExploreFilters _self;
  final $Res Function(ExploreFilters) _then;

  /// Create a copy of ExploreFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? durationsMinutes = null,
    Object? bodyAreas = null,
    Object? positions = null,
    Object? difficulties = null,
    Object? equipment = null,
  }) {
    return _then(
      ExploreFilters(
        durationsMinutes: null == durationsMinutes
            ? _self.durationsMinutes
            : durationsMinutes // ignore: cast_nullable_to_non_nullable
                  as Set<int>,
        bodyAreas: null == bodyAreas
            ? _self.bodyAreas
            : bodyAreas // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        positions: null == positions
            ? _self.positions
            : positions // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        difficulties: null == difficulties
            ? _self.difficulties
            : difficulties // ignore: cast_nullable_to_non_nullable
                  as Set<DifficultyLevel>,
        equipment: null == equipment
            ? _self.equipment
            : equipment // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ExploreFilters].
extension ExploreFiltersPatterns on ExploreFilters {
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
    TResult Function(_ExploreFilters value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExploreFilters() when $default != null:
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
    TResult Function(_ExploreFilters value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreFilters():
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
    TResult? Function(_ExploreFilters value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreFilters() when $default != null:
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
      Set<int> durationsMinutes,
      Set<String> bodyAreas,
      Set<String> positions,
      Set<DifficultyLevel> difficulties,
      Set<String> equipment,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExploreFilters() when $default != null:
        return $default(
          _that.durationsMinutes,
          _that.bodyAreas,
          _that.positions,
          _that.difficulties,
          _that.equipment,
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
      Set<int> durationsMinutes,
      Set<String> bodyAreas,
      Set<String> positions,
      Set<DifficultyLevel> difficulties,
      Set<String> equipment,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreFilters():
        return $default(
          _that.durationsMinutes,
          _that.bodyAreas,
          _that.positions,
          _that.difficulties,
          _that.equipment,
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
      Set<int> durationsMinutes,
      Set<String> bodyAreas,
      Set<String> positions,
      Set<DifficultyLevel> difficulties,
      Set<String> equipment,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreFilters() when $default != null:
        return $default(
          _that.durationsMinutes,
          _that.bodyAreas,
          _that.positions,
          _that.difficulties,
          _that.equipment,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ExploreFilters extends ExploreFilters {
  const _ExploreFilters({
    Set<int> durationsMinutes = const <int>{},
    Set<String> bodyAreas = const <String>{},
    Set<String> positions = const <String>{},
    Set<DifficultyLevel> difficulties = const <DifficultyLevel>{},
    Set<String> equipment = const <String>{},
  }) : _durationsMinutes = durationsMinutes,
       _bodyAreas = bodyAreas,
       _positions = positions,
       _difficulties = difficulties,
       _equipment = equipment,
       super._();

  final Set<int> _durationsMinutes;
  @override
  @JsonKey()
  Set<int> get durationsMinutes {
    if (_durationsMinutes is EqualUnmodifiableSetView) return _durationsMinutes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_durationsMinutes);
  }

  final Set<String> _bodyAreas;
  @override
  @JsonKey()
  Set<String> get bodyAreas {
    if (_bodyAreas is EqualUnmodifiableSetView) return _bodyAreas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_bodyAreas);
  }

  final Set<String> _positions;
  @override
  @JsonKey()
  Set<String> get positions {
    if (_positions is EqualUnmodifiableSetView) return _positions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_positions);
  }

  final Set<DifficultyLevel> _difficulties;
  @override
  @JsonKey()
  Set<DifficultyLevel> get difficulties {
    if (_difficulties is EqualUnmodifiableSetView) return _difficulties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_difficulties);
  }

  final Set<String> _equipment;
  @override
  @JsonKey()
  Set<String> get equipment {
    if (_equipment is EqualUnmodifiableSetView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_equipment);
  }

  /// Create a copy of ExploreFilters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExploreFiltersCopyWith<_ExploreFilters> get copyWith =>
      __$ExploreFiltersCopyWithImpl<_ExploreFilters>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExploreFilters &&
            const DeepCollectionEquality().equals(
              other._durationsMinutes,
              _durationsMinutes,
            ) &&
            const DeepCollectionEquality().equals(
              other._bodyAreas,
              _bodyAreas,
            ) &&
            const DeepCollectionEquality().equals(
              other._positions,
              _positions,
            ) &&
            const DeepCollectionEquality().equals(
              other._difficulties,
              _difficulties,
            ) &&
            const DeepCollectionEquality().equals(
              other._equipment,
              _equipment,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_durationsMinutes),
    const DeepCollectionEquality().hash(_bodyAreas),
    const DeepCollectionEquality().hash(_positions),
    const DeepCollectionEquality().hash(_difficulties),
    const DeepCollectionEquality().hash(_equipment),
  );

  @override
  String toString() {
    return 'ExploreFilters(durationsMinutes: $durationsMinutes, bodyAreas: $bodyAreas, positions: $positions, difficulties: $difficulties, equipment: $equipment)';
  }
}

/// @nodoc
abstract mixin class _$ExploreFiltersCopyWith<$Res>
    implements $ExploreFiltersCopyWith<$Res> {
  factory _$ExploreFiltersCopyWith(
    _ExploreFilters value,
    $Res Function(_ExploreFilters) _then,
  ) = __$ExploreFiltersCopyWithImpl;
  @override
  @useResult
  $Res call({
    Set<int> durationsMinutes,
    Set<String> bodyAreas,
    Set<String> positions,
    Set<DifficultyLevel> difficulties,
    Set<String> equipment,
  });
}

/// @nodoc
class __$ExploreFiltersCopyWithImpl<$Res>
    implements _$ExploreFiltersCopyWith<$Res> {
  __$ExploreFiltersCopyWithImpl(this._self, this._then);

  final _ExploreFilters _self;
  final $Res Function(_ExploreFilters) _then;

  /// Create a copy of ExploreFilters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? durationsMinutes = null,
    Object? bodyAreas = null,
    Object? positions = null,
    Object? difficulties = null,
    Object? equipment = null,
  }) {
    return _then(
      _ExploreFilters(
        durationsMinutes: null == durationsMinutes
            ? _self._durationsMinutes
            : durationsMinutes // ignore: cast_nullable_to_non_nullable
                  as Set<int>,
        bodyAreas: null == bodyAreas
            ? _self._bodyAreas
            : bodyAreas // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        positions: null == positions
            ? _self._positions
            : positions // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        difficulties: null == difficulties
            ? _self._difficulties
            : difficulties // ignore: cast_nullable_to_non_nullable
                  as Set<DifficultyLevel>,
        equipment: null == equipment
            ? _self._equipment
            : equipment // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
      ),
    );
  }
}

/// @nodoc
mixin _$ExploreRoutineCard {
  String get routineId;
  String get name;
  String get summary;
  int get durationSeconds;
  DifficultyLevel get difficulty;
  Set<String> get positions;
  Set<String> get equipment;
  int get movementCount;

  /// Create a copy of ExploreRoutineCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExploreRoutineCardCopyWith<ExploreRoutineCard> get copyWith =>
      _$ExploreRoutineCardCopyWithImpl<ExploreRoutineCard>(
        this as ExploreRoutineCard,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExploreRoutineCard &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality().equals(other.positions, positions) &&
            const DeepCollectionEquality().equals(other.equipment, equipment) &&
            (identical(other.movementCount, movementCount) ||
                other.movementCount == movementCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    routineId,
    name,
    summary,
    durationSeconds,
    difficulty,
    const DeepCollectionEquality().hash(positions),
    const DeepCollectionEquality().hash(equipment),
    movementCount,
  );

  @override
  String toString() {
    return 'ExploreRoutineCard(routineId: $routineId, name: $name, summary: $summary, durationSeconds: $durationSeconds, difficulty: $difficulty, positions: $positions, equipment: $equipment, movementCount: $movementCount)';
  }
}

/// @nodoc
abstract mixin class $ExploreRoutineCardCopyWith<$Res> {
  factory $ExploreRoutineCardCopyWith(
    ExploreRoutineCard value,
    $Res Function(ExploreRoutineCard) _then,
  ) = _$ExploreRoutineCardCopyWithImpl;
  @useResult
  $Res call({
    String routineId,
    String name,
    String summary,
    int durationSeconds,
    DifficultyLevel difficulty,
    Set<String> positions,
    Set<String> equipment,
    int movementCount,
  });
}

/// @nodoc
class _$ExploreRoutineCardCopyWithImpl<$Res>
    implements $ExploreRoutineCardCopyWith<$Res> {
  _$ExploreRoutineCardCopyWithImpl(this._self, this._then);

  final ExploreRoutineCard _self;
  final $Res Function(ExploreRoutineCard) _then;

  /// Create a copy of ExploreRoutineCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routineId = null,
    Object? name = null,
    Object? summary = null,
    Object? durationSeconds = null,
    Object? difficulty = null,
    Object? positions = null,
    Object? equipment = null,
    Object? movementCount = null,
  }) {
    return _then(
      ExploreRoutineCard(
        routineId: null == routineId
            ? _self.routineId
            : routineId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        summary: null == summary
            ? _self.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String,
        durationSeconds: null == durationSeconds
            ? _self.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        difficulty: null == difficulty
            ? _self.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as DifficultyLevel,
        positions: null == positions
            ? _self.positions
            : positions // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        equipment: null == equipment
            ? _self.equipment
            : equipment // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        movementCount: null == movementCount
            ? _self.movementCount
            : movementCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ExploreRoutineCard].
extension ExploreRoutineCardPatterns on ExploreRoutineCard {
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
    TResult Function(_ExploreRoutineCard value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExploreRoutineCard() when $default != null:
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
    TResult Function(_ExploreRoutineCard value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreRoutineCard():
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
    TResult? Function(_ExploreRoutineCard value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreRoutineCard() when $default != null:
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
      String name,
      String summary,
      int durationSeconds,
      DifficultyLevel difficulty,
      Set<String> positions,
      Set<String> equipment,
      int movementCount,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExploreRoutineCard() when $default != null:
        return $default(
          _that.routineId,
          _that.name,
          _that.summary,
          _that.durationSeconds,
          _that.difficulty,
          _that.positions,
          _that.equipment,
          _that.movementCount,
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
      String name,
      String summary,
      int durationSeconds,
      DifficultyLevel difficulty,
      Set<String> positions,
      Set<String> equipment,
      int movementCount,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreRoutineCard():
        return $default(
          _that.routineId,
          _that.name,
          _that.summary,
          _that.durationSeconds,
          _that.difficulty,
          _that.positions,
          _that.equipment,
          _that.movementCount,
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
      String name,
      String summary,
      int durationSeconds,
      DifficultyLevel difficulty,
      Set<String> positions,
      Set<String> equipment,
      int movementCount,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreRoutineCard() when $default != null:
        return $default(
          _that.routineId,
          _that.name,
          _that.summary,
          _that.durationSeconds,
          _that.difficulty,
          _that.positions,
          _that.equipment,
          _that.movementCount,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ExploreRoutineCard implements ExploreRoutineCard {
  const _ExploreRoutineCard({
    required this.routineId,
    required this.name,
    required this.summary,
    required this.durationSeconds,
    required this.difficulty,
    required Set<String> positions,
    required Set<String> equipment,
    required this.movementCount,
  }) : _positions = positions,
       _equipment = equipment;

  @override
  final String routineId;
  @override
  final String name;
  @override
  final String summary;
  @override
  final int durationSeconds;
  @override
  final DifficultyLevel difficulty;
  final Set<String> _positions;
  @override
  Set<String> get positions {
    if (_positions is EqualUnmodifiableSetView) return _positions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_positions);
  }

  final Set<String> _equipment;
  @override
  Set<String> get equipment {
    if (_equipment is EqualUnmodifiableSetView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_equipment);
  }

  @override
  final int movementCount;

  /// Create a copy of ExploreRoutineCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExploreRoutineCardCopyWith<_ExploreRoutineCard> get copyWith =>
      __$ExploreRoutineCardCopyWithImpl<_ExploreRoutineCard>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExploreRoutineCard &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality().equals(
              other._positions,
              _positions,
            ) &&
            const DeepCollectionEquality().equals(
              other._equipment,
              _equipment,
            ) &&
            (identical(other.movementCount, movementCount) ||
                other.movementCount == movementCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    routineId,
    name,
    summary,
    durationSeconds,
    difficulty,
    const DeepCollectionEquality().hash(_positions),
    const DeepCollectionEquality().hash(_equipment),
    movementCount,
  );

  @override
  String toString() {
    return 'ExploreRoutineCard(routineId: $routineId, name: $name, summary: $summary, durationSeconds: $durationSeconds, difficulty: $difficulty, positions: $positions, equipment: $equipment, movementCount: $movementCount)';
  }
}

/// @nodoc
abstract mixin class _$ExploreRoutineCardCopyWith<$Res>
    implements $ExploreRoutineCardCopyWith<$Res> {
  factory _$ExploreRoutineCardCopyWith(
    _ExploreRoutineCard value,
    $Res Function(_ExploreRoutineCard) _then,
  ) = __$ExploreRoutineCardCopyWithImpl;
  @override
  @useResult
  $Res call({
    String routineId,
    String name,
    String summary,
    int durationSeconds,
    DifficultyLevel difficulty,
    Set<String> positions,
    Set<String> equipment,
    int movementCount,
  });
}

/// @nodoc
class __$ExploreRoutineCardCopyWithImpl<$Res>
    implements _$ExploreRoutineCardCopyWith<$Res> {
  __$ExploreRoutineCardCopyWithImpl(this._self, this._then);

  final _ExploreRoutineCard _self;
  final $Res Function(_ExploreRoutineCard) _then;

  /// Create a copy of ExploreRoutineCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? routineId = null,
    Object? name = null,
    Object? summary = null,
    Object? durationSeconds = null,
    Object? difficulty = null,
    Object? positions = null,
    Object? equipment = null,
    Object? movementCount = null,
  }) {
    return _then(
      _ExploreRoutineCard(
        routineId: null == routineId
            ? _self.routineId
            : routineId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        summary: null == summary
            ? _self.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String,
        durationSeconds: null == durationSeconds
            ? _self.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        difficulty: null == difficulty
            ? _self.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as DifficultyLevel,
        positions: null == positions
            ? _self._positions
            : positions // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        equipment: null == equipment
            ? _self._equipment
            : equipment // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        movementCount: null == movementCount
            ? _self.movementCount
            : movementCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
mixin _$ExploreCategory {
  String get key;
  String get label;

  /// Create a copy of ExploreCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExploreCategoryCopyWith<ExploreCategory> get copyWith =>
      _$ExploreCategoryCopyWithImpl<ExploreCategory>(
        this as ExploreCategory,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExploreCategory &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.label, label) || other.label == label));
  }

  @override
  int get hashCode => Object.hash(runtimeType, key, label);

  @override
  String toString() {
    return 'ExploreCategory(key: $key, label: $label)';
  }
}

/// @nodoc
abstract mixin class $ExploreCategoryCopyWith<$Res> {
  factory $ExploreCategoryCopyWith(
    ExploreCategory value,
    $Res Function(ExploreCategory) _then,
  ) = _$ExploreCategoryCopyWithImpl;
  @useResult
  $Res call({String key, String label});
}

/// @nodoc
class _$ExploreCategoryCopyWithImpl<$Res>
    implements $ExploreCategoryCopyWith<$Res> {
  _$ExploreCategoryCopyWithImpl(this._self, this._then);

  final ExploreCategory _self;
  final $Res Function(ExploreCategory) _then;

  /// Create a copy of ExploreCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? key = null, Object? label = null}) {
    return _then(
      ExploreCategory(
        key: null == key
            ? _self.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _self.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ExploreCategory].
extension ExploreCategoryPatterns on ExploreCategory {
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
    TResult Function(_ExploreCategory value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExploreCategory() when $default != null:
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
    TResult Function(_ExploreCategory value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreCategory():
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
    TResult? Function(_ExploreCategory value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreCategory() when $default != null:
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
    TResult Function(String key, String label)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExploreCategory() when $default != null:
        return $default(_that.key, _that.label);
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
    TResult Function(String key, String label) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreCategory():
        return $default(_that.key, _that.label);
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
    TResult? Function(String key, String label)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreCategory() when $default != null:
        return $default(_that.key, _that.label);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ExploreCategory implements ExploreCategory {
  const _ExploreCategory({required this.key, required this.label});

  @override
  final String key;
  @override
  final String label;

  /// Create a copy of ExploreCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExploreCategoryCopyWith<_ExploreCategory> get copyWith =>
      __$ExploreCategoryCopyWithImpl<_ExploreCategory>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExploreCategory &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.label, label) || other.label == label));
  }

  @override
  int get hashCode => Object.hash(runtimeType, key, label);

  @override
  String toString() {
    return 'ExploreCategory(key: $key, label: $label)';
  }
}

/// @nodoc
abstract mixin class _$ExploreCategoryCopyWith<$Res>
    implements $ExploreCategoryCopyWith<$Res> {
  factory _$ExploreCategoryCopyWith(
    _ExploreCategory value,
    $Res Function(_ExploreCategory) _then,
  ) = __$ExploreCategoryCopyWithImpl;
  @override
  @useResult
  $Res call({String key, String label});
}

/// @nodoc
class __$ExploreCategoryCopyWithImpl<$Res>
    implements _$ExploreCategoryCopyWith<$Res> {
  __$ExploreCategoryCopyWithImpl(this._self, this._then);

  final _ExploreCategory _self;
  final $Res Function(_ExploreCategory) _then;

  /// Create a copy of ExploreCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? key = null, Object? label = null}) {
    return _then(
      _ExploreCategory(
        key: null == key
            ? _self.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _self.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
mixin _$RoutineStartEligibility {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RoutineStartEligibility);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RoutineStartEligibility()';
  }
}

/// @nodoc
class $RoutineStartEligibilityCopyWith<$Res> {
  $RoutineStartEligibilityCopyWith(
    RoutineStartEligibility _,
    $Res Function(RoutineStartEligibility) __,
  );
}

/// Adds pattern-matching-related methods to [RoutineStartEligibility].
extension RoutineStartEligibilityPatterns on RoutineStartEligibility {
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
    TResult Function(RoutineStartAllowed value)? allowed,
    TResult Function(RoutineStartBlocked value)? blocked,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RoutineStartAllowed() when allowed != null:
        return allowed(_that);
      case RoutineStartBlocked() when blocked != null:
        return blocked(_that);
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
    required TResult Function(RoutineStartAllowed value) allowed,
    required TResult Function(RoutineStartBlocked value) blocked,
  }) {
    final _that = this;
    switch (_that) {
      case RoutineStartAllowed():
        return allowed(_that);
      case RoutineStartBlocked():
        return blocked(_that);
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
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RoutineStartAllowed value)? allowed,
    TResult? Function(RoutineStartBlocked value)? blocked,
  }) {
    final _that = this;
    switch (_that) {
      case RoutineStartAllowed() when allowed != null:
        return allowed(_that);
      case RoutineStartBlocked() when blocked != null:
        return blocked(_that);
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
    TResult Function()? allowed,
    TResult Function(RoutineStartBlock reason)? blocked,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RoutineStartAllowed() when allowed != null:
        return allowed();
      case RoutineStartBlocked() when blocked != null:
        return blocked(_that.reason);
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
    required TResult Function() allowed,
    required TResult Function(RoutineStartBlock reason) blocked,
  }) {
    final _that = this;
    switch (_that) {
      case RoutineStartAllowed():
        return allowed();
      case RoutineStartBlocked():
        return blocked(_that.reason);
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
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? allowed,
    TResult? Function(RoutineStartBlock reason)? blocked,
  }) {
    final _that = this;
    switch (_that) {
      case RoutineStartAllowed() when allowed != null:
        return allowed();
      case RoutineStartBlocked() when blocked != null:
        return blocked(_that.reason);
      case _:
        return null;
    }
  }
}

/// @nodoc

class RoutineStartAllowed implements RoutineStartEligibility {
  const RoutineStartAllowed();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RoutineStartAllowed);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RoutineStartEligibility.allowed()';
  }
}

/// @nodoc

class RoutineStartBlocked implements RoutineStartEligibility {
  const RoutineStartBlocked(this.reason);

  final RoutineStartBlock reason;

  /// Create a copy of RoutineStartEligibility
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RoutineStartBlockedCopyWith<RoutineStartBlocked> get copyWith =>
      _$RoutineStartBlockedCopyWithImpl<RoutineStartBlocked>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RoutineStartBlocked &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @override
  String toString() {
    return 'RoutineStartEligibility.blocked(reason: $reason)';
  }
}

/// @nodoc
abstract mixin class $RoutineStartBlockedCopyWith<$Res>
    implements $RoutineStartEligibilityCopyWith<$Res> {
  factory $RoutineStartBlockedCopyWith(
    RoutineStartBlocked value,
    $Res Function(RoutineStartBlocked) _then,
  ) = _$RoutineStartBlockedCopyWithImpl;
  @useResult
  $Res call({RoutineStartBlock reason});
}

/// @nodoc
class _$RoutineStartBlockedCopyWithImpl<$Res>
    implements $RoutineStartBlockedCopyWith<$Res> {
  _$RoutineStartBlockedCopyWithImpl(this._self, this._then);

  final RoutineStartBlocked _self;
  final $Res Function(RoutineStartBlocked) _then;

  /// Create a copy of RoutineStartEligibility
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({Object? reason = null}) {
    return _then(
      RoutineStartBlocked(
        null == reason
            ? _self.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as RoutineStartBlock,
      ),
    );
  }
}

/// @nodoc
mixin _$ExploreRoutineDetails {
  RoutinePresentation get presentation;
  RoutineStartEligibility get eligibility;
  Map<String, String> get equipmentLabels;

  /// Create a copy of ExploreRoutineDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExploreRoutineDetailsCopyWith<ExploreRoutineDetails> get copyWith =>
      _$ExploreRoutineDetailsCopyWithImpl<ExploreRoutineDetails>(
        this as ExploreRoutineDetails,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExploreRoutineDetails &&
            (identical(other.presentation, presentation) ||
                other.presentation == presentation) &&
            (identical(other.eligibility, eligibility) ||
                other.eligibility == eligibility) &&
            const DeepCollectionEquality().equals(
              other.equipmentLabels,
              equipmentLabels,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    presentation,
    eligibility,
    const DeepCollectionEquality().hash(equipmentLabels),
  );

  @override
  String toString() {
    return 'ExploreRoutineDetails(presentation: $presentation, eligibility: $eligibility, equipmentLabels: $equipmentLabels)';
  }
}

/// @nodoc
abstract mixin class $ExploreRoutineDetailsCopyWith<$Res> {
  factory $ExploreRoutineDetailsCopyWith(
    ExploreRoutineDetails value,
    $Res Function(ExploreRoutineDetails) _then,
  ) = _$ExploreRoutineDetailsCopyWithImpl;
  @useResult
  $Res call({
    RoutinePresentation presentation,
    RoutineStartEligibility eligibility,
    Map<String, String> equipmentLabels,
  });

  $RoutinePresentationCopyWith<$Res> get presentation;
  $RoutineStartEligibilityCopyWith<$Res> get eligibility;
}

/// @nodoc
class _$ExploreRoutineDetailsCopyWithImpl<$Res>
    implements $ExploreRoutineDetailsCopyWith<$Res> {
  _$ExploreRoutineDetailsCopyWithImpl(this._self, this._then);

  final ExploreRoutineDetails _self;
  final $Res Function(ExploreRoutineDetails) _then;

  /// Create a copy of ExploreRoutineDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? presentation = null,
    Object? eligibility = null,
    Object? equipmentLabels = null,
  }) {
    return _then(
      ExploreRoutineDetails(
        presentation: null == presentation
            ? _self.presentation
            : presentation // ignore: cast_nullable_to_non_nullable
                  as RoutinePresentation,
        eligibility: null == eligibility
            ? _self.eligibility
            : eligibility // ignore: cast_nullable_to_non_nullable
                  as RoutineStartEligibility,
        equipmentLabels: null == equipmentLabels
            ? _self.equipmentLabels
            : equipmentLabels // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }

  /// Create a copy of ExploreRoutineDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RoutinePresentationCopyWith<$Res> get presentation {
    return $RoutinePresentationCopyWith<$Res>(_self.presentation, (value) {
      return _then(_self.copyWith(presentation: value));
    });
  }

  /// Create a copy of ExploreRoutineDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RoutineStartEligibilityCopyWith<$Res> get eligibility {
    return $RoutineStartEligibilityCopyWith<$Res>(_self.eligibility, (value) {
      return _then(_self.copyWith(eligibility: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ExploreRoutineDetails].
extension ExploreRoutineDetailsPatterns on ExploreRoutineDetails {
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
    TResult Function(_ExploreRoutineDetails value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExploreRoutineDetails() when $default != null:
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
    TResult Function(_ExploreRoutineDetails value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreRoutineDetails():
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
    TResult? Function(_ExploreRoutineDetails value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreRoutineDetails() when $default != null:
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
      RoutinePresentation presentation,
      RoutineStartEligibility eligibility,
      Map<String, String> equipmentLabels,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExploreRoutineDetails() when $default != null:
        return $default(
          _that.presentation,
          _that.eligibility,
          _that.equipmentLabels,
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
      RoutinePresentation presentation,
      RoutineStartEligibility eligibility,
      Map<String, String> equipmentLabels,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreRoutineDetails():
        return $default(
          _that.presentation,
          _that.eligibility,
          _that.equipmentLabels,
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
      RoutinePresentation presentation,
      RoutineStartEligibility eligibility,
      Map<String, String> equipmentLabels,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExploreRoutineDetails() when $default != null:
        return $default(
          _that.presentation,
          _that.eligibility,
          _that.equipmentLabels,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ExploreRoutineDetails implements ExploreRoutineDetails {
  const _ExploreRoutineDetails({
    required this.presentation,
    required this.eligibility,
    Map<String, String> equipmentLabels = const <String, String>{},
  }) : _equipmentLabels = equipmentLabels;

  @override
  final RoutinePresentation presentation;
  @override
  final RoutineStartEligibility eligibility;
  final Map<String, String> _equipmentLabels;
  @override
  @JsonKey()
  Map<String, String> get equipmentLabels {
    if (_equipmentLabels is EqualUnmodifiableMapView) return _equipmentLabels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_equipmentLabels);
  }

  /// Create a copy of ExploreRoutineDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExploreRoutineDetailsCopyWith<_ExploreRoutineDetails> get copyWith =>
      __$ExploreRoutineDetailsCopyWithImpl<_ExploreRoutineDetails>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExploreRoutineDetails &&
            (identical(other.presentation, presentation) ||
                other.presentation == presentation) &&
            (identical(other.eligibility, eligibility) ||
                other.eligibility == eligibility) &&
            const DeepCollectionEquality().equals(
              other._equipmentLabels,
              _equipmentLabels,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    presentation,
    eligibility,
    const DeepCollectionEquality().hash(_equipmentLabels),
  );

  @override
  String toString() {
    return 'ExploreRoutineDetails(presentation: $presentation, eligibility: $eligibility, equipmentLabels: $equipmentLabels)';
  }
}

/// @nodoc
abstract mixin class _$ExploreRoutineDetailsCopyWith<$Res>
    implements $ExploreRoutineDetailsCopyWith<$Res> {
  factory _$ExploreRoutineDetailsCopyWith(
    _ExploreRoutineDetails value,
    $Res Function(_ExploreRoutineDetails) _then,
  ) = __$ExploreRoutineDetailsCopyWithImpl;
  @override
  @useResult
  $Res call({
    RoutinePresentation presentation,
    RoutineStartEligibility eligibility,
    Map<String, String> equipmentLabels,
  });

  @override
  $RoutinePresentationCopyWith<$Res> get presentation;
  @override
  $RoutineStartEligibilityCopyWith<$Res> get eligibility;
}

/// @nodoc
class __$ExploreRoutineDetailsCopyWithImpl<$Res>
    implements _$ExploreRoutineDetailsCopyWith<$Res> {
  __$ExploreRoutineDetailsCopyWithImpl(this._self, this._then);

  final _ExploreRoutineDetails _self;
  final $Res Function(_ExploreRoutineDetails) _then;

  /// Create a copy of ExploreRoutineDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? presentation = null,
    Object? eligibility = null,
    Object? equipmentLabels = null,
  }) {
    return _then(
      _ExploreRoutineDetails(
        presentation: null == presentation
            ? _self.presentation
            : presentation // ignore: cast_nullable_to_non_nullable
                  as RoutinePresentation,
        eligibility: null == eligibility
            ? _self.eligibility
            : eligibility // ignore: cast_nullable_to_non_nullable
                  as RoutineStartEligibility,
        equipmentLabels: null == equipmentLabels
            ? _self._equipmentLabels
            : equipmentLabels // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }

  /// Create a copy of ExploreRoutineDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RoutinePresentationCopyWith<$Res> get presentation {
    return $RoutinePresentationCopyWith<$Res>(_self.presentation, (value) {
      return _then(_self.copyWith(presentation: value));
    });
  }

  /// Create a copy of ExploreRoutineDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RoutineStartEligibilityCopyWith<$Res> get eligibility {
    return $RoutineStartEligibilityCopyWith<$Res>(_self.eligibility, (value) {
      return _then(_self.copyWith(eligibility: value));
    });
  }
}
