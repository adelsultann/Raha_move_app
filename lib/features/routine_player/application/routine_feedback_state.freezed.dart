// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_feedback_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoutineFeedbackState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RoutineFeedbackState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RoutineFeedbackState()';
  }
}

/// @nodoc
class $RoutineFeedbackStateCopyWith<$Res> {
  $RoutineFeedbackStateCopyWith(
    RoutineFeedbackState _,
    $Res Function(RoutineFeedbackState) __,
  );
}

/// Adds pattern-matching-related methods to [RoutineFeedbackState].
extension RoutineFeedbackStatePatterns on RoutineFeedbackState {
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
    TResult Function(RoutineFeedbackLoading value)? loading,
    TResult Function(RoutineFeedbackIdle value)? idle,
    TResult Function(RoutineFeedbackSaving value)? saving,
    TResult Function(RoutineFeedbackSaved value)? saved,
    TResult Function(RoutineFeedbackError value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RoutineFeedbackLoading() when loading != null:
        return loading(_that);
      case RoutineFeedbackIdle() when idle != null:
        return idle(_that);
      case RoutineFeedbackSaving() when saving != null:
        return saving(_that);
      case RoutineFeedbackSaved() when saved != null:
        return saved(_that);
      case RoutineFeedbackError() when error != null:
        return error(_that);
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
    required TResult Function(RoutineFeedbackLoading value) loading,
    required TResult Function(RoutineFeedbackIdle value) idle,
    required TResult Function(RoutineFeedbackSaving value) saving,
    required TResult Function(RoutineFeedbackSaved value) saved,
    required TResult Function(RoutineFeedbackError value) error,
  }) {
    final _that = this;
    switch (_that) {
      case RoutineFeedbackLoading():
        return loading(_that);
      case RoutineFeedbackIdle():
        return idle(_that);
      case RoutineFeedbackSaving():
        return saving(_that);
      case RoutineFeedbackSaved():
        return saved(_that);
      case RoutineFeedbackError():
        return error(_that);
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
    TResult? Function(RoutineFeedbackLoading value)? loading,
    TResult? Function(RoutineFeedbackIdle value)? idle,
    TResult? Function(RoutineFeedbackSaving value)? saving,
    TResult? Function(RoutineFeedbackSaved value)? saved,
    TResult? Function(RoutineFeedbackError value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case RoutineFeedbackLoading() when loading != null:
        return loading(_that);
      case RoutineFeedbackIdle() when idle != null:
        return idle(_that);
      case RoutineFeedbackSaving() when saving != null:
        return saving(_that);
      case RoutineFeedbackSaved() when saved != null:
        return saved(_that);
      case RoutineFeedbackError() when error != null:
        return error(_that);
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
    TResult Function()? loading,
    TResult Function()? idle,
    TResult Function(FeedbackRating rating)? saving,
    TResult Function(FeedbackRating rating)? saved,
    TResult Function(FeedbackRating rating)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RoutineFeedbackLoading() when loading != null:
        return loading();
      case RoutineFeedbackIdle() when idle != null:
        return idle();
      case RoutineFeedbackSaving() when saving != null:
        return saving(_that.rating);
      case RoutineFeedbackSaved() when saved != null:
        return saved(_that.rating);
      case RoutineFeedbackError() when error != null:
        return error(_that.rating);
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
    required TResult Function() loading,
    required TResult Function() idle,
    required TResult Function(FeedbackRating rating) saving,
    required TResult Function(FeedbackRating rating) saved,
    required TResult Function(FeedbackRating rating) error,
  }) {
    final _that = this;
    switch (_that) {
      case RoutineFeedbackLoading():
        return loading();
      case RoutineFeedbackIdle():
        return idle();
      case RoutineFeedbackSaving():
        return saving(_that.rating);
      case RoutineFeedbackSaved():
        return saved(_that.rating);
      case RoutineFeedbackError():
        return error(_that.rating);
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
    TResult? Function()? loading,
    TResult? Function()? idle,
    TResult? Function(FeedbackRating rating)? saving,
    TResult? Function(FeedbackRating rating)? saved,
    TResult? Function(FeedbackRating rating)? error,
  }) {
    final _that = this;
    switch (_that) {
      case RoutineFeedbackLoading() when loading != null:
        return loading();
      case RoutineFeedbackIdle() when idle != null:
        return idle();
      case RoutineFeedbackSaving() when saving != null:
        return saving(_that.rating);
      case RoutineFeedbackSaved() when saved != null:
        return saved(_that.rating);
      case RoutineFeedbackError() when error != null:
        return error(_that.rating);
      case _:
        return null;
    }
  }
}

/// @nodoc

class RoutineFeedbackLoading implements RoutineFeedbackState {
  const RoutineFeedbackLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RoutineFeedbackLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RoutineFeedbackState.loading()';
  }
}

/// @nodoc

class RoutineFeedbackIdle implements RoutineFeedbackState {
  const RoutineFeedbackIdle();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RoutineFeedbackIdle);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RoutineFeedbackState.idle()';
  }
}

/// @nodoc

class RoutineFeedbackSaving implements RoutineFeedbackState {
  const RoutineFeedbackSaving({required this.rating});

  final FeedbackRating rating;

  /// Create a copy of RoutineFeedbackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RoutineFeedbackSavingCopyWith<RoutineFeedbackSaving> get copyWith =>
      _$RoutineFeedbackSavingCopyWithImpl<RoutineFeedbackSaving>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RoutineFeedbackSaving &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rating);

  @override
  String toString() {
    return 'RoutineFeedbackState.saving(rating: $rating)';
  }
}

/// @nodoc
abstract mixin class $RoutineFeedbackSavingCopyWith<$Res>
    implements $RoutineFeedbackStateCopyWith<$Res> {
  factory $RoutineFeedbackSavingCopyWith(
    RoutineFeedbackSaving value,
    $Res Function(RoutineFeedbackSaving) _then,
  ) = _$RoutineFeedbackSavingCopyWithImpl;
  @useResult
  $Res call({FeedbackRating rating});
}

/// @nodoc
class _$RoutineFeedbackSavingCopyWithImpl<$Res>
    implements $RoutineFeedbackSavingCopyWith<$Res> {
  _$RoutineFeedbackSavingCopyWithImpl(this._self, this._then);

  final RoutineFeedbackSaving _self;
  final $Res Function(RoutineFeedbackSaving) _then;

  /// Create a copy of RoutineFeedbackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({Object? rating = null}) {
    return _then(
      RoutineFeedbackSaving(
        rating: null == rating
            ? _self.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as FeedbackRating,
      ),
    );
  }
}

/// @nodoc

class RoutineFeedbackSaved implements RoutineFeedbackState {
  const RoutineFeedbackSaved({required this.rating});

  final FeedbackRating rating;

  /// Create a copy of RoutineFeedbackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RoutineFeedbackSavedCopyWith<RoutineFeedbackSaved> get copyWith =>
      _$RoutineFeedbackSavedCopyWithImpl<RoutineFeedbackSaved>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RoutineFeedbackSaved &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rating);

  @override
  String toString() {
    return 'RoutineFeedbackState.saved(rating: $rating)';
  }
}

/// @nodoc
abstract mixin class $RoutineFeedbackSavedCopyWith<$Res>
    implements $RoutineFeedbackStateCopyWith<$Res> {
  factory $RoutineFeedbackSavedCopyWith(
    RoutineFeedbackSaved value,
    $Res Function(RoutineFeedbackSaved) _then,
  ) = _$RoutineFeedbackSavedCopyWithImpl;
  @useResult
  $Res call({FeedbackRating rating});
}

/// @nodoc
class _$RoutineFeedbackSavedCopyWithImpl<$Res>
    implements $RoutineFeedbackSavedCopyWith<$Res> {
  _$RoutineFeedbackSavedCopyWithImpl(this._self, this._then);

  final RoutineFeedbackSaved _self;
  final $Res Function(RoutineFeedbackSaved) _then;

  /// Create a copy of RoutineFeedbackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({Object? rating = null}) {
    return _then(
      RoutineFeedbackSaved(
        rating: null == rating
            ? _self.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as FeedbackRating,
      ),
    );
  }
}

/// @nodoc

class RoutineFeedbackError implements RoutineFeedbackState {
  const RoutineFeedbackError({required this.rating});

  final FeedbackRating rating;

  /// Create a copy of RoutineFeedbackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RoutineFeedbackErrorCopyWith<RoutineFeedbackError> get copyWith =>
      _$RoutineFeedbackErrorCopyWithImpl<RoutineFeedbackError>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RoutineFeedbackError &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rating);

  @override
  String toString() {
    return 'RoutineFeedbackState.error(rating: $rating)';
  }
}

/// @nodoc
abstract mixin class $RoutineFeedbackErrorCopyWith<$Res>
    implements $RoutineFeedbackStateCopyWith<$Res> {
  factory $RoutineFeedbackErrorCopyWith(
    RoutineFeedbackError value,
    $Res Function(RoutineFeedbackError) _then,
  ) = _$RoutineFeedbackErrorCopyWithImpl;
  @useResult
  $Res call({FeedbackRating rating});
}

/// @nodoc
class _$RoutineFeedbackErrorCopyWithImpl<$Res>
    implements $RoutineFeedbackErrorCopyWith<$Res> {
  _$RoutineFeedbackErrorCopyWithImpl(this._self, this._then);

  final RoutineFeedbackError _self;
  final $Res Function(RoutineFeedbackError) _then;

  /// Create a copy of RoutineFeedbackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({Object? rating = null}) {
    return _then(
      RoutineFeedbackError(
        rating: null == rating
            ? _self.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as FeedbackRating,
      ),
    );
  }
}
