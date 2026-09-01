// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoutinePlaybackPlan {
  String get routineId;
  int get routineVersion;
  String get routineName;
  List<RoutineStepPlan> get steps;

  /// Create a copy of RoutinePlaybackPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RoutinePlaybackPlanCopyWith<RoutinePlaybackPlan> get copyWith =>
      _$RoutinePlaybackPlanCopyWithImpl<RoutinePlaybackPlan>(
        this as RoutinePlaybackPlan,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RoutinePlaybackPlan &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.routineVersion, routineVersion) ||
                other.routineVersion == routineVersion) &&
            (identical(other.routineName, routineName) ||
                other.routineName == routineName) &&
            const DeepCollectionEquality().equals(other.steps, steps));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    routineId,
    routineVersion,
    routineName,
    const DeepCollectionEquality().hash(steps),
  );

  @override
  String toString() {
    return 'RoutinePlaybackPlan(routineId: $routineId, routineVersion: $routineVersion, routineName: $routineName, steps: $steps)';
  }
}

/// @nodoc
abstract mixin class $RoutinePlaybackPlanCopyWith<$Res> {
  factory $RoutinePlaybackPlanCopyWith(
    RoutinePlaybackPlan value,
    $Res Function(RoutinePlaybackPlan) _then,
  ) = _$RoutinePlaybackPlanCopyWithImpl;
  @useResult
  $Res call({
    String routineId,
    int routineVersion,
    String routineName,
    List<RoutineStepPlan> steps,
  });
}

/// @nodoc
class _$RoutinePlaybackPlanCopyWithImpl<$Res>
    implements $RoutinePlaybackPlanCopyWith<$Res> {
  _$RoutinePlaybackPlanCopyWithImpl(this._self, this._then);

  final RoutinePlaybackPlan _self;
  final $Res Function(RoutinePlaybackPlan) _then;

  /// Create a copy of RoutinePlaybackPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routineId = null,
    Object? routineVersion = null,
    Object? routineName = null,
    Object? steps = null,
  }) {
    return _then(
      RoutinePlaybackPlan(
        routineId: null == routineId
            ? _self.routineId
            : routineId // ignore: cast_nullable_to_non_nullable
                  as String,
        routineVersion: null == routineVersion
            ? _self.routineVersion
            : routineVersion // ignore: cast_nullable_to_non_nullable
                  as int,
        routineName: null == routineName
            ? _self.routineName
            : routineName // ignore: cast_nullable_to_non_nullable
                  as String,
        steps: null == steps
            ? _self.steps
            : steps // ignore: cast_nullable_to_non_nullable
                  as List<RoutineStepPlan>,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [RoutinePlaybackPlan].
extension RoutinePlaybackPlanPatterns on RoutinePlaybackPlan {
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
    TResult Function(_RoutinePlaybackPlan value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RoutinePlaybackPlan() when $default != null:
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
    TResult Function(_RoutinePlaybackPlan value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RoutinePlaybackPlan():
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
    TResult? Function(_RoutinePlaybackPlan value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RoutinePlaybackPlan() when $default != null:
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
      int routineVersion,
      String routineName,
      List<RoutineStepPlan> steps,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RoutinePlaybackPlan() when $default != null:
        return $default(
          _that.routineId,
          _that.routineVersion,
          _that.routineName,
          _that.steps,
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
      int routineVersion,
      String routineName,
      List<RoutineStepPlan> steps,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RoutinePlaybackPlan():
        return $default(
          _that.routineId,
          _that.routineVersion,
          _that.routineName,
          _that.steps,
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
      int routineVersion,
      String routineName,
      List<RoutineStepPlan> steps,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RoutinePlaybackPlan() when $default != null:
        return $default(
          _that.routineId,
          _that.routineVersion,
          _that.routineName,
          _that.steps,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RoutinePlaybackPlan extends RoutinePlaybackPlan {
  const _RoutinePlaybackPlan({
    required this.routineId,
    required this.routineVersion,
    required this.routineName,
    required List<RoutineStepPlan> steps,
  }) : _steps = steps,
       super._();

  @override
  final String routineId;
  @override
  final int routineVersion;
  @override
  final String routineName;
  final List<RoutineStepPlan> _steps;
  @override
  List<RoutineStepPlan> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  /// Create a copy of RoutinePlaybackPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RoutinePlaybackPlanCopyWith<_RoutinePlaybackPlan> get copyWith =>
      __$RoutinePlaybackPlanCopyWithImpl<_RoutinePlaybackPlan>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RoutinePlaybackPlan &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.routineVersion, routineVersion) ||
                other.routineVersion == routineVersion) &&
            (identical(other.routineName, routineName) ||
                other.routineName == routineName) &&
            const DeepCollectionEquality().equals(other._steps, _steps));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    routineId,
    routineVersion,
    routineName,
    const DeepCollectionEquality().hash(_steps),
  );

  @override
  String toString() {
    return 'RoutinePlaybackPlan(routineId: $routineId, routineVersion: $routineVersion, routineName: $routineName, steps: $steps)';
  }
}

/// @nodoc
abstract mixin class _$RoutinePlaybackPlanCopyWith<$Res>
    implements $RoutinePlaybackPlanCopyWith<$Res> {
  factory _$RoutinePlaybackPlanCopyWith(
    _RoutinePlaybackPlan value,
    $Res Function(_RoutinePlaybackPlan) _then,
  ) = __$RoutinePlaybackPlanCopyWithImpl;
  @override
  @useResult
  $Res call({
    String routineId,
    int routineVersion,
    String routineName,
    List<RoutineStepPlan> steps,
  });
}

/// @nodoc
class __$RoutinePlaybackPlanCopyWithImpl<$Res>
    implements _$RoutinePlaybackPlanCopyWith<$Res> {
  __$RoutinePlaybackPlanCopyWithImpl(this._self, this._then);

  final _RoutinePlaybackPlan _self;
  final $Res Function(_RoutinePlaybackPlan) _then;

  /// Create a copy of RoutinePlaybackPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? routineId = null,
    Object? routineVersion = null,
    Object? routineName = null,
    Object? steps = null,
  }) {
    return _then(
      _RoutinePlaybackPlan(
        routineId: null == routineId
            ? _self.routineId
            : routineId // ignore: cast_nullable_to_non_nullable
                  as String,
        routineVersion: null == routineVersion
            ? _self.routineVersion
            : routineVersion // ignore: cast_nullable_to_non_nullable
                  as int,
        routineName: null == routineName
            ? _self.routineName
            : routineName // ignore: cast_nullable_to_non_nullable
                  as String,
        steps: null == steps
            ? _self._steps
            : steps // ignore: cast_nullable_to_non_nullable
                  as List<RoutineStepPlan>,
      ),
    );
  }
}

/// @nodoc
mixin _$RoutineStepPlan {
  String get stepId;
  String get exerciseId;
  String get name;
  String? get shortCue;
  int get durationSeconds;
  MediaDelivery get media;

  /// Create a copy of RoutineStepPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RoutineStepPlanCopyWith<RoutineStepPlan> get copyWith =>
      _$RoutineStepPlanCopyWithImpl<RoutineStepPlan>(
        this as RoutineStepPlan,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RoutineStepPlan &&
            (identical(other.stepId, stepId) || other.stepId == stepId) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.shortCue, shortCue) ||
                other.shortCue == shortCue) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.media, media) || other.media == media));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    stepId,
    exerciseId,
    name,
    shortCue,
    durationSeconds,
    media,
  );

  @override
  String toString() {
    return 'RoutineStepPlan(stepId: $stepId, exerciseId: $exerciseId, name: $name, shortCue: $shortCue, durationSeconds: $durationSeconds, media: $media)';
  }
}

/// @nodoc
abstract mixin class $RoutineStepPlanCopyWith<$Res> {
  factory $RoutineStepPlanCopyWith(
    RoutineStepPlan value,
    $Res Function(RoutineStepPlan) _then,
  ) = _$RoutineStepPlanCopyWithImpl;
  @useResult
  $Res call({
    String stepId,
    String exerciseId,
    String name,
    String? shortCue,
    int durationSeconds,
    MediaDelivery media,
  });
}

/// @nodoc
class _$RoutineStepPlanCopyWithImpl<$Res>
    implements $RoutineStepPlanCopyWith<$Res> {
  _$RoutineStepPlanCopyWithImpl(this._self, this._then);

  final RoutineStepPlan _self;
  final $Res Function(RoutineStepPlan) _then;

  /// Create a copy of RoutineStepPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stepId = null,
    Object? exerciseId = null,
    Object? name = null,
    Object? shortCue = freezed,
    Object? durationSeconds = null,
    Object? media = null,
  }) {
    return _then(
      RoutineStepPlan(
        stepId: null == stepId
            ? _self.stepId
            : stepId // ignore: cast_nullable_to_non_nullable
                  as String,
        exerciseId: null == exerciseId
            ? _self.exerciseId
            : exerciseId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        shortCue: freezed == shortCue
            ? _self.shortCue
            : shortCue // ignore: cast_nullable_to_non_nullable
                  as String?,
        durationSeconds: null == durationSeconds
            ? _self.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        media: null == media
            ? _self.media
            : media // ignore: cast_nullable_to_non_nullable
                  as MediaDelivery,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [RoutineStepPlan].
extension RoutineStepPlanPatterns on RoutineStepPlan {
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
    TResult Function(_RoutineStepPlan value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RoutineStepPlan() when $default != null:
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
    TResult Function(_RoutineStepPlan value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RoutineStepPlan():
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
    TResult? Function(_RoutineStepPlan value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RoutineStepPlan() when $default != null:
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
      String stepId,
      String exerciseId,
      String name,
      String? shortCue,
      int durationSeconds,
      MediaDelivery media,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RoutineStepPlan() when $default != null:
        return $default(
          _that.stepId,
          _that.exerciseId,
          _that.name,
          _that.shortCue,
          _that.durationSeconds,
          _that.media,
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
      String stepId,
      String exerciseId,
      String name,
      String? shortCue,
      int durationSeconds,
      MediaDelivery media,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RoutineStepPlan():
        return $default(
          _that.stepId,
          _that.exerciseId,
          _that.name,
          _that.shortCue,
          _that.durationSeconds,
          _that.media,
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
      String stepId,
      String exerciseId,
      String name,
      String? shortCue,
      int durationSeconds,
      MediaDelivery media,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RoutineStepPlan() when $default != null:
        return $default(
          _that.stepId,
          _that.exerciseId,
          _that.name,
          _that.shortCue,
          _that.durationSeconds,
          _that.media,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RoutineStepPlan implements RoutineStepPlan {
  const _RoutineStepPlan({
    required this.stepId,
    required this.exerciseId,
    required this.name,
    this.shortCue,
    required this.durationSeconds,
    required this.media,
  });

  @override
  final String stepId;
  @override
  final String exerciseId;
  @override
  final String name;
  @override
  final String? shortCue;
  @override
  final int durationSeconds;
  @override
  final MediaDelivery media;

  /// Create a copy of RoutineStepPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RoutineStepPlanCopyWith<_RoutineStepPlan> get copyWith =>
      __$RoutineStepPlanCopyWithImpl<_RoutineStepPlan>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RoutineStepPlan &&
            (identical(other.stepId, stepId) || other.stepId == stepId) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.shortCue, shortCue) ||
                other.shortCue == shortCue) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.media, media) || other.media == media));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    stepId,
    exerciseId,
    name,
    shortCue,
    durationSeconds,
    media,
  );

  @override
  String toString() {
    return 'RoutineStepPlan(stepId: $stepId, exerciseId: $exerciseId, name: $name, shortCue: $shortCue, durationSeconds: $durationSeconds, media: $media)';
  }
}

/// @nodoc
abstract mixin class _$RoutineStepPlanCopyWith<$Res>
    implements $RoutineStepPlanCopyWith<$Res> {
  factory _$RoutineStepPlanCopyWith(
    _RoutineStepPlan value,
    $Res Function(_RoutineStepPlan) _then,
  ) = __$RoutineStepPlanCopyWithImpl;
  @override
  @useResult
  $Res call({
    String stepId,
    String exerciseId,
    String name,
    String? shortCue,
    int durationSeconds,
    MediaDelivery media,
  });
}

/// @nodoc
class __$RoutineStepPlanCopyWithImpl<$Res>
    implements _$RoutineStepPlanCopyWith<$Res> {
  __$RoutineStepPlanCopyWithImpl(this._self, this._then);

  final _RoutineStepPlan _self;
  final $Res Function(_RoutineStepPlan) _then;

  /// Create a copy of RoutineStepPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? stepId = null,
    Object? exerciseId = null,
    Object? name = null,
    Object? shortCue = freezed,
    Object? durationSeconds = null,
    Object? media = null,
  }) {
    return _then(
      _RoutineStepPlan(
        stepId: null == stepId
            ? _self.stepId
            : stepId // ignore: cast_nullable_to_non_nullable
                  as String,
        exerciseId: null == exerciseId
            ? _self.exerciseId
            : exerciseId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        shortCue: freezed == shortCue
            ? _self.shortCue
            : shortCue // ignore: cast_nullable_to_non_nullable
                  as String?,
        durationSeconds: null == durationSeconds
            ? _self.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        media: null == media
            ? _self.media
            : media // ignore: cast_nullable_to_non_nullable
                  as MediaDelivery,
      ),
    );
  }
}
