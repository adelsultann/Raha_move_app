// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_session_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoutineStepSnapshot {

 String get stepId; String get exerciseId; int get position; String get status; int get targetDurationSeconds; int get activeDurationSeconds; bool get skipRequested;
/// Create a copy of RoutineStepSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineStepSnapshotCopyWith<RoutineStepSnapshot> get copyWith => _$RoutineStepSnapshotCopyWithImpl<RoutineStepSnapshot>(this as RoutineStepSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineStepSnapshot&&(identical(other.stepId, stepId) || other.stepId == stepId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.position, position) || other.position == position)&&(identical(other.status, status) || other.status == status)&&(identical(other.targetDurationSeconds, targetDurationSeconds) || other.targetDurationSeconds == targetDurationSeconds)&&(identical(other.activeDurationSeconds, activeDurationSeconds) || other.activeDurationSeconds == activeDurationSeconds)&&(identical(other.skipRequested, skipRequested) || other.skipRequested == skipRequested));
}


@override
int get hashCode => Object.hash(runtimeType,stepId,exerciseId,position,status,targetDurationSeconds,activeDurationSeconds,skipRequested);

@override
String toString() {
  return 'RoutineStepSnapshot(stepId: $stepId, exerciseId: $exerciseId, position: $position, status: $status, targetDurationSeconds: $targetDurationSeconds, activeDurationSeconds: $activeDurationSeconds, skipRequested: $skipRequested)';
}


}

/// @nodoc
abstract mixin class $RoutineStepSnapshotCopyWith<$Res>  {
  factory $RoutineStepSnapshotCopyWith(RoutineStepSnapshot value, $Res Function(RoutineStepSnapshot) _then) = _$RoutineStepSnapshotCopyWithImpl;
@useResult
$Res call({
 String stepId, String exerciseId, int position, String status, int targetDurationSeconds, int activeDurationSeconds, bool skipRequested
});




}
/// @nodoc
class _$RoutineStepSnapshotCopyWithImpl<$Res>
    implements $RoutineStepSnapshotCopyWith<$Res> {
  _$RoutineStepSnapshotCopyWithImpl(this._self, this._then);

  final RoutineStepSnapshot _self;
  final $Res Function(RoutineStepSnapshot) _then;

/// Create a copy of RoutineStepSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stepId = null,Object? exerciseId = null,Object? position = null,Object? status = null,Object? targetDurationSeconds = null,Object? activeDurationSeconds = null,Object? skipRequested = null,}) {
  return _then(RoutineStepSnapshot(
stepId: null == stepId ? _self.stepId : stepId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,targetDurationSeconds: null == targetDurationSeconds ? _self.targetDurationSeconds : targetDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,activeDurationSeconds: null == activeDurationSeconds ? _self.activeDurationSeconds : activeDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,skipRequested: null == skipRequested ? _self.skipRequested : skipRequested // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineStepSnapshot].
extension RoutineStepSnapshotPatterns on RoutineStepSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineStepSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineStepSnapshot() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineStepSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _RoutineStepSnapshot():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineStepSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineStepSnapshot() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stepId,  String exerciseId,  int position,  String status,  int targetDurationSeconds,  int activeDurationSeconds,  bool skipRequested)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineStepSnapshot() when $default != null:
return $default(_that.stepId,_that.exerciseId,_that.position,_that.status,_that.targetDurationSeconds,_that.activeDurationSeconds,_that.skipRequested);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stepId,  String exerciseId,  int position,  String status,  int targetDurationSeconds,  int activeDurationSeconds,  bool skipRequested)  $default,) {final _that = this;
switch (_that) {
case _RoutineStepSnapshot():
return $default(_that.stepId,_that.exerciseId,_that.position,_that.status,_that.targetDurationSeconds,_that.activeDurationSeconds,_that.skipRequested);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stepId,  String exerciseId,  int position,  String status,  int targetDurationSeconds,  int activeDurationSeconds,  bool skipRequested)?  $default,) {final _that = this;
switch (_that) {
case _RoutineStepSnapshot() when $default != null:
return $default(_that.stepId,_that.exerciseId,_that.position,_that.status,_that.targetDurationSeconds,_that.activeDurationSeconds,_that.skipRequested);case _:
  return null;

}
}

}

/// @nodoc


class _RoutineStepSnapshot implements RoutineStepSnapshot {
  const _RoutineStepSnapshot({required this.stepId, required this.exerciseId, required this.position, required this.status, required this.targetDurationSeconds, required this.activeDurationSeconds, required this.skipRequested});
  

@override final  String stepId;
@override final  String exerciseId;
@override final  int position;
@override final  String status;
@override final  int targetDurationSeconds;
@override final  int activeDurationSeconds;
@override final  bool skipRequested;

/// Create a copy of RoutineStepSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineStepSnapshotCopyWith<_RoutineStepSnapshot> get copyWith => __$RoutineStepSnapshotCopyWithImpl<_RoutineStepSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineStepSnapshot&&(identical(other.stepId, stepId) || other.stepId == stepId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.position, position) || other.position == position)&&(identical(other.status, status) || other.status == status)&&(identical(other.targetDurationSeconds, targetDurationSeconds) || other.targetDurationSeconds == targetDurationSeconds)&&(identical(other.activeDurationSeconds, activeDurationSeconds) || other.activeDurationSeconds == activeDurationSeconds)&&(identical(other.skipRequested, skipRequested) || other.skipRequested == skipRequested));
}


@override
int get hashCode => Object.hash(runtimeType,stepId,exerciseId,position,status,targetDurationSeconds,activeDurationSeconds,skipRequested);

@override
String toString() {
  return 'RoutineStepSnapshot(stepId: $stepId, exerciseId: $exerciseId, position: $position, status: $status, targetDurationSeconds: $targetDurationSeconds, activeDurationSeconds: $activeDurationSeconds, skipRequested: $skipRequested)';
}


}

/// @nodoc
abstract mixin class _$RoutineStepSnapshotCopyWith<$Res> implements $RoutineStepSnapshotCopyWith<$Res> {
  factory _$RoutineStepSnapshotCopyWith(_RoutineStepSnapshot value, $Res Function(_RoutineStepSnapshot) _then) = __$RoutineStepSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String stepId, String exerciseId, int position, String status, int targetDurationSeconds, int activeDurationSeconds, bool skipRequested
});




}
/// @nodoc
class __$RoutineStepSnapshotCopyWithImpl<$Res>
    implements _$RoutineStepSnapshotCopyWith<$Res> {
  __$RoutineStepSnapshotCopyWithImpl(this._self, this._then);

  final _RoutineStepSnapshot _self;
  final $Res Function(_RoutineStepSnapshot) _then;

/// Create a copy of RoutineStepSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stepId = null,Object? exerciseId = null,Object? position = null,Object? status = null,Object? targetDurationSeconds = null,Object? activeDurationSeconds = null,Object? skipRequested = null,}) {
  return _then(_RoutineStepSnapshot(
stepId: null == stepId ? _self.stepId : stepId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,targetDurationSeconds: null == targetDurationSeconds ? _self.targetDurationSeconds : targetDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,activeDurationSeconds: null == activeDurationSeconds ? _self.activeDurationSeconds : activeDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,skipRequested: null == skipRequested ? _self.skipRequested : skipRequested // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RoutineSessionSnapshot {

 String get sessionId; String get routineId; int get routineVersion; String? get recommendationId; DateTime get startedAt; String get status; int? get currentStepPosition; int? get currentStepActiveSeconds; List<RoutineStepSnapshot> get steps;
/// Create a copy of RoutineSessionSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineSessionSnapshotCopyWith<RoutineSessionSnapshot> get copyWith => _$RoutineSessionSnapshotCopyWithImpl<RoutineSessionSnapshot>(this as RoutineSessionSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineSessionSnapshot&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.routineVersion, routineVersion) || other.routineVersion == routineVersion)&&(identical(other.recommendationId, recommendationId) || other.recommendationId == recommendationId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentStepPosition, currentStepPosition) || other.currentStepPosition == currentStepPosition)&&(identical(other.currentStepActiveSeconds, currentStepActiveSeconds) || other.currentStepActiveSeconds == currentStepActiveSeconds)&&const DeepCollectionEquality().equals(other.steps, steps));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,routineId,routineVersion,recommendationId,startedAt,status,currentStepPosition,currentStepActiveSeconds,const DeepCollectionEquality().hash(steps));

@override
String toString() {
  return 'RoutineSessionSnapshot(sessionId: $sessionId, routineId: $routineId, routineVersion: $routineVersion, recommendationId: $recommendationId, startedAt: $startedAt, status: $status, currentStepPosition: $currentStepPosition, currentStepActiveSeconds: $currentStepActiveSeconds, steps: $steps)';
}


}

/// @nodoc
abstract mixin class $RoutineSessionSnapshotCopyWith<$Res>  {
  factory $RoutineSessionSnapshotCopyWith(RoutineSessionSnapshot value, $Res Function(RoutineSessionSnapshot) _then) = _$RoutineSessionSnapshotCopyWithImpl;
@useResult
$Res call({
 String sessionId, String routineId, int routineVersion, String? recommendationId, DateTime startedAt, String status, int? currentStepPosition, int? currentStepActiveSeconds, List<RoutineStepSnapshot> steps
});




}
/// @nodoc
class _$RoutineSessionSnapshotCopyWithImpl<$Res>
    implements $RoutineSessionSnapshotCopyWith<$Res> {
  _$RoutineSessionSnapshotCopyWithImpl(this._self, this._then);

  final RoutineSessionSnapshot _self;
  final $Res Function(RoutineSessionSnapshot) _then;

/// Create a copy of RoutineSessionSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? routineId = null,Object? routineVersion = null,Object? recommendationId = freezed,Object? startedAt = null,Object? status = null,Object? currentStepPosition = freezed,Object? currentStepActiveSeconds = freezed,Object? steps = null,}) {
  return _then(RoutineSessionSnapshot(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,routineVersion: null == routineVersion ? _self.routineVersion : routineVersion // ignore: cast_nullable_to_non_nullable
as int,recommendationId: freezed == recommendationId ? _self.recommendationId : recommendationId // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,currentStepPosition: freezed == currentStepPosition ? _self.currentStepPosition : currentStepPosition // ignore: cast_nullable_to_non_nullable
as int?,currentStepActiveSeconds: freezed == currentStepActiveSeconds ? _self.currentStepActiveSeconds : currentStepActiveSeconds // ignore: cast_nullable_to_non_nullable
as int?,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<RoutineStepSnapshot>,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineSessionSnapshot].
extension RoutineSessionSnapshotPatterns on RoutineSessionSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineSessionSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineSessionSnapshot() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineSessionSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _RoutineSessionSnapshot():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineSessionSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineSessionSnapshot() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId,  String routineId,  int routineVersion,  String? recommendationId,  DateTime startedAt,  String status,  int? currentStepPosition,  int? currentStepActiveSeconds,  List<RoutineStepSnapshot> steps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineSessionSnapshot() when $default != null:
return $default(_that.sessionId,_that.routineId,_that.routineVersion,_that.recommendationId,_that.startedAt,_that.status,_that.currentStepPosition,_that.currentStepActiveSeconds,_that.steps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId,  String routineId,  int routineVersion,  String? recommendationId,  DateTime startedAt,  String status,  int? currentStepPosition,  int? currentStepActiveSeconds,  List<RoutineStepSnapshot> steps)  $default,) {final _that = this;
switch (_that) {
case _RoutineSessionSnapshot():
return $default(_that.sessionId,_that.routineId,_that.routineVersion,_that.recommendationId,_that.startedAt,_that.status,_that.currentStepPosition,_that.currentStepActiveSeconds,_that.steps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId,  String routineId,  int routineVersion,  String? recommendationId,  DateTime startedAt,  String status,  int? currentStepPosition,  int? currentStepActiveSeconds,  List<RoutineStepSnapshot> steps)?  $default,) {final _that = this;
switch (_that) {
case _RoutineSessionSnapshot() when $default != null:
return $default(_that.sessionId,_that.routineId,_that.routineVersion,_that.recommendationId,_that.startedAt,_that.status,_that.currentStepPosition,_that.currentStepActiveSeconds,_that.steps);case _:
  return null;

}
}

}

/// @nodoc


class _RoutineSessionSnapshot implements RoutineSessionSnapshot {
  const _RoutineSessionSnapshot({required this.sessionId, required this.routineId, required this.routineVersion, this.recommendationId, required this.startedAt, required this.status, this.currentStepPosition, this.currentStepActiveSeconds, required  List<RoutineStepSnapshot> steps}): _steps = steps;
  

@override final  String sessionId;
@override final  String routineId;
@override final  int routineVersion;
@override final  String? recommendationId;
@override final  DateTime startedAt;
@override final  String status;
@override final  int? currentStepPosition;
@override final  int? currentStepActiveSeconds;
 final  List<RoutineStepSnapshot> _steps;
@override List<RoutineStepSnapshot> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}


/// Create a copy of RoutineSessionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineSessionSnapshotCopyWith<_RoutineSessionSnapshot> get copyWith => __$RoutineSessionSnapshotCopyWithImpl<_RoutineSessionSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineSessionSnapshot&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.routineVersion, routineVersion) || other.routineVersion == routineVersion)&&(identical(other.recommendationId, recommendationId) || other.recommendationId == recommendationId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentStepPosition, currentStepPosition) || other.currentStepPosition == currentStepPosition)&&(identical(other.currentStepActiveSeconds, currentStepActiveSeconds) || other.currentStepActiveSeconds == currentStepActiveSeconds)&&const DeepCollectionEquality().equals(other._steps, _steps));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,routineId,routineVersion,recommendationId,startedAt,status,currentStepPosition,currentStepActiveSeconds,const DeepCollectionEquality().hash(_steps));

@override
String toString() {
  return 'RoutineSessionSnapshot(sessionId: $sessionId, routineId: $routineId, routineVersion: $routineVersion, recommendationId: $recommendationId, startedAt: $startedAt, status: $status, currentStepPosition: $currentStepPosition, currentStepActiveSeconds: $currentStepActiveSeconds, steps: $steps)';
}


}

/// @nodoc
abstract mixin class _$RoutineSessionSnapshotCopyWith<$Res> implements $RoutineSessionSnapshotCopyWith<$Res> {
  factory _$RoutineSessionSnapshotCopyWith(_RoutineSessionSnapshot value, $Res Function(_RoutineSessionSnapshot) _then) = __$RoutineSessionSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, String routineId, int routineVersion, String? recommendationId, DateTime startedAt, String status, int? currentStepPosition, int? currentStepActiveSeconds, List<RoutineStepSnapshot> steps
});




}
/// @nodoc
class __$RoutineSessionSnapshotCopyWithImpl<$Res>
    implements _$RoutineSessionSnapshotCopyWith<$Res> {
  __$RoutineSessionSnapshotCopyWithImpl(this._self, this._then);

  final _RoutineSessionSnapshot _self;
  final $Res Function(_RoutineSessionSnapshot) _then;

/// Create a copy of RoutineSessionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? routineId = null,Object? routineVersion = null,Object? recommendationId = freezed,Object? startedAt = null,Object? status = null,Object? currentStepPosition = freezed,Object? currentStepActiveSeconds = freezed,Object? steps = null,}) {
  return _then(_RoutineSessionSnapshot(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,routineVersion: null == routineVersion ? _self.routineVersion : routineVersion // ignore: cast_nullable_to_non_nullable
as int,recommendationId: freezed == recommendationId ? _self.recommendationId : recommendationId // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,currentStepPosition: freezed == currentStepPosition ? _self.currentStepPosition : currentStepPosition // ignore: cast_nullable_to_non_nullable
as int?,currentStepActiveSeconds: freezed == currentStepActiveSeconds ? _self.currentStepActiveSeconds : currentStepActiveSeconds // ignore: cast_nullable_to_non_nullable
as int?,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<RoutineStepSnapshot>,
  ));
}


}

// dart format on
