// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_feedback_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoutineFeedbackArgs {
  String get sessionId;
  String get routineId;

  /// Create a copy of RoutineFeedbackArgs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RoutineFeedbackArgsCopyWith<RoutineFeedbackArgs> get copyWith =>
      _$RoutineFeedbackArgsCopyWithImpl<RoutineFeedbackArgs>(
        this as RoutineFeedbackArgs,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RoutineFeedbackArgs &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, routineId);

  @override
  String toString() {
    return 'RoutineFeedbackArgs(sessionId: $sessionId, routineId: $routineId)';
  }
}

/// @nodoc
abstract mixin class $RoutineFeedbackArgsCopyWith<$Res> {
  factory $RoutineFeedbackArgsCopyWith(
    RoutineFeedbackArgs value,
    $Res Function(RoutineFeedbackArgs) _then,
  ) = _$RoutineFeedbackArgsCopyWithImpl;
  @useResult
  $Res call({String sessionId, String routineId});
}

/// @nodoc
class _$RoutineFeedbackArgsCopyWithImpl<$Res>
    implements $RoutineFeedbackArgsCopyWith<$Res> {
  _$RoutineFeedbackArgsCopyWithImpl(this._self, this._then);

  final RoutineFeedbackArgs _self;
  final $Res Function(RoutineFeedbackArgs) _then;

  /// Create a copy of RoutineFeedbackArgs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? sessionId = null, Object? routineId = null}) {
    return _then(
      RoutineFeedbackArgs(
        sessionId: null == sessionId
            ? _self.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        routineId: null == routineId
            ? _self.routineId
            : routineId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [RoutineFeedbackArgs].
extension RoutineFeedbackArgsPatterns on RoutineFeedbackArgs {
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
    TResult Function(_RoutineFeedbackArgs value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RoutineFeedbackArgs() when $default != null:
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
    TResult Function(_RoutineFeedbackArgs value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RoutineFeedbackArgs():
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
    TResult? Function(_RoutineFeedbackArgs value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RoutineFeedbackArgs() when $default != null:
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
    TResult Function(String sessionId, String routineId)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RoutineFeedbackArgs() when $default != null:
        return $default(_that.sessionId, _that.routineId);
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
    TResult Function(String sessionId, String routineId) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RoutineFeedbackArgs():
        return $default(_that.sessionId, _that.routineId);
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
    TResult? Function(String sessionId, String routineId)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RoutineFeedbackArgs() when $default != null:
        return $default(_that.sessionId, _that.routineId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RoutineFeedbackArgs implements RoutineFeedbackArgs {
  const _RoutineFeedbackArgs({
    required this.sessionId,
    required this.routineId,
  });

  @override
  final String sessionId;
  @override
  final String routineId;

  /// Create a copy of RoutineFeedbackArgs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RoutineFeedbackArgsCopyWith<_RoutineFeedbackArgs> get copyWith =>
      __$RoutineFeedbackArgsCopyWithImpl<_RoutineFeedbackArgs>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RoutineFeedbackArgs &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, routineId);

  @override
  String toString() {
    return 'RoutineFeedbackArgs(sessionId: $sessionId, routineId: $routineId)';
  }
}

/// @nodoc
abstract mixin class _$RoutineFeedbackArgsCopyWith<$Res>
    implements $RoutineFeedbackArgsCopyWith<$Res> {
  factory _$RoutineFeedbackArgsCopyWith(
    _RoutineFeedbackArgs value,
    $Res Function(_RoutineFeedbackArgs) _then,
  ) = __$RoutineFeedbackArgsCopyWithImpl;
  @override
  @useResult
  $Res call({String sessionId, String routineId});
}

/// @nodoc
class __$RoutineFeedbackArgsCopyWithImpl<$Res>
    implements _$RoutineFeedbackArgsCopyWith<$Res> {
  __$RoutineFeedbackArgsCopyWithImpl(this._self, this._then);

  final _RoutineFeedbackArgs _self;
  final $Res Function(_RoutineFeedbackArgs) _then;

  /// Create a copy of RoutineFeedbackArgs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? sessionId = null, Object? routineId = null}) {
    return _then(
      _RoutineFeedbackArgs(
        sessionId: null == sessionId
            ? _self.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        routineId: null == routineId
            ? _self.routineId
            : routineId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}
