// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoutineStepPlayback {

 String get stepId; String get exerciseId; String get name; String? get shortCue; int get durationSeconds; StepPlaybackState get state; int get creditedSeconds; bool get skipRequested;
/// Create a copy of RoutineStepPlayback
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineStepPlaybackCopyWith<RoutineStepPlayback> get copyWith => _$RoutineStepPlaybackCopyWithImpl<RoutineStepPlayback>(this as RoutineStepPlayback, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineStepPlayback&&(identical(other.stepId, stepId) || other.stepId == stepId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.shortCue, shortCue) || other.shortCue == shortCue)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.state, state) || other.state == state)&&(identical(other.creditedSeconds, creditedSeconds) || other.creditedSeconds == creditedSeconds)&&(identical(other.skipRequested, skipRequested) || other.skipRequested == skipRequested));
}


@override
int get hashCode => Object.hash(runtimeType,stepId,exerciseId,name,shortCue,durationSeconds,state,creditedSeconds,skipRequested);

@override
String toString() {
  return 'RoutineStepPlayback(stepId: $stepId, exerciseId: $exerciseId, name: $name, shortCue: $shortCue, durationSeconds: $durationSeconds, state: $state, creditedSeconds: $creditedSeconds, skipRequested: $skipRequested)';
}


}

/// @nodoc
abstract mixin class $RoutineStepPlaybackCopyWith<$Res>  {
  factory $RoutineStepPlaybackCopyWith(RoutineStepPlayback value, $Res Function(RoutineStepPlayback) _then) = _$RoutineStepPlaybackCopyWithImpl;
@useResult
$Res call({
 String stepId, String exerciseId, String name, String? shortCue, int durationSeconds, StepPlaybackState state, int creditedSeconds, bool skipRequested
});




}
/// @nodoc
class _$RoutineStepPlaybackCopyWithImpl<$Res>
    implements $RoutineStepPlaybackCopyWith<$Res> {
  _$RoutineStepPlaybackCopyWithImpl(this._self, this._then);

  final RoutineStepPlayback _self;
  final $Res Function(RoutineStepPlayback) _then;

/// Create a copy of RoutineStepPlayback
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stepId = null,Object? exerciseId = null,Object? name = null,Object? shortCue = freezed,Object? durationSeconds = null,Object? state = null,Object? creditedSeconds = null,Object? skipRequested = null,}) {
  return _then(RoutineStepPlayback(
stepId: null == stepId ? _self.stepId : stepId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortCue: freezed == shortCue ? _self.shortCue : shortCue // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as StepPlaybackState,creditedSeconds: null == creditedSeconds ? _self.creditedSeconds : creditedSeconds // ignore: cast_nullable_to_non_nullable
as int,skipRequested: null == skipRequested ? _self.skipRequested : skipRequested // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineStepPlayback].
extension RoutineStepPlaybackPatterns on RoutineStepPlayback {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineStepPlayback value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineStepPlayback() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineStepPlayback value)  $default,){
final _that = this;
switch (_that) {
case _RoutineStepPlayback():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineStepPlayback value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineStepPlayback() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stepId,  String exerciseId,  String name,  String? shortCue,  int durationSeconds,  StepPlaybackState state,  int creditedSeconds,  bool skipRequested)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineStepPlayback() when $default != null:
return $default(_that.stepId,_that.exerciseId,_that.name,_that.shortCue,_that.durationSeconds,_that.state,_that.creditedSeconds,_that.skipRequested);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stepId,  String exerciseId,  String name,  String? shortCue,  int durationSeconds,  StepPlaybackState state,  int creditedSeconds,  bool skipRequested)  $default,) {final _that = this;
switch (_that) {
case _RoutineStepPlayback():
return $default(_that.stepId,_that.exerciseId,_that.name,_that.shortCue,_that.durationSeconds,_that.state,_that.creditedSeconds,_that.skipRequested);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stepId,  String exerciseId,  String name,  String? shortCue,  int durationSeconds,  StepPlaybackState state,  int creditedSeconds,  bool skipRequested)?  $default,) {final _that = this;
switch (_that) {
case _RoutineStepPlayback() when $default != null:
return $default(_that.stepId,_that.exerciseId,_that.name,_that.shortCue,_that.durationSeconds,_that.state,_that.creditedSeconds,_that.skipRequested);case _:
  return null;

}
}

}

/// @nodoc


class _RoutineStepPlayback implements RoutineStepPlayback {
  const _RoutineStepPlayback({required this.stepId, required this.exerciseId, required this.name, this.shortCue, required this.durationSeconds, required this.state, required this.creditedSeconds, required this.skipRequested});
  

@override final  String stepId;
@override final  String exerciseId;
@override final  String name;
@override final  String? shortCue;
@override final  int durationSeconds;
@override final  StepPlaybackState state;
@override final  int creditedSeconds;
@override final  bool skipRequested;

/// Create a copy of RoutineStepPlayback
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineStepPlaybackCopyWith<_RoutineStepPlayback> get copyWith => __$RoutineStepPlaybackCopyWithImpl<_RoutineStepPlayback>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineStepPlayback&&(identical(other.stepId, stepId) || other.stepId == stepId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.shortCue, shortCue) || other.shortCue == shortCue)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.state, state) || other.state == state)&&(identical(other.creditedSeconds, creditedSeconds) || other.creditedSeconds == creditedSeconds)&&(identical(other.skipRequested, skipRequested) || other.skipRequested == skipRequested));
}


@override
int get hashCode => Object.hash(runtimeType,stepId,exerciseId,name,shortCue,durationSeconds,state,creditedSeconds,skipRequested);

@override
String toString() {
  return 'RoutineStepPlayback(stepId: $stepId, exerciseId: $exerciseId, name: $name, shortCue: $shortCue, durationSeconds: $durationSeconds, state: $state, creditedSeconds: $creditedSeconds, skipRequested: $skipRequested)';
}


}

/// @nodoc
abstract mixin class _$RoutineStepPlaybackCopyWith<$Res> implements $RoutineStepPlaybackCopyWith<$Res> {
  factory _$RoutineStepPlaybackCopyWith(_RoutineStepPlayback value, $Res Function(_RoutineStepPlayback) _then) = __$RoutineStepPlaybackCopyWithImpl;
@override @useResult
$Res call({
 String stepId, String exerciseId, String name, String? shortCue, int durationSeconds, StepPlaybackState state, int creditedSeconds, bool skipRequested
});




}
/// @nodoc
class __$RoutineStepPlaybackCopyWithImpl<$Res>
    implements _$RoutineStepPlaybackCopyWith<$Res> {
  __$RoutineStepPlaybackCopyWithImpl(this._self, this._then);

  final _RoutineStepPlayback _self;
  final $Res Function(_RoutineStepPlayback) _then;

/// Create a copy of RoutineStepPlayback
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stepId = null,Object? exerciseId = null,Object? name = null,Object? shortCue = freezed,Object? durationSeconds = null,Object? state = null,Object? creditedSeconds = null,Object? skipRequested = null,}) {
  return _then(_RoutineStepPlayback(
stepId: null == stepId ? _self.stepId : stepId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortCue: freezed == shortCue ? _self.shortCue : shortCue // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as StepPlaybackState,creditedSeconds: null == creditedSeconds ? _self.creditedSeconds : creditedSeconds // ignore: cast_nullable_to_non_nullable
as int,skipRequested: null == skipRequested ? _self.skipRequested : skipRequested // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RoutinePlaybackSession {

 String get sessionId; String get routineId; int get routineVersion; String get routineName; String? get recommendationId; PlaybackStatus get status; int get currentStepIndex; List<RoutineStepPlayback> get steps;
/// Create a copy of RoutinePlaybackSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutinePlaybackSessionCopyWith<RoutinePlaybackSession> get copyWith => _$RoutinePlaybackSessionCopyWithImpl<RoutinePlaybackSession>(this as RoutinePlaybackSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutinePlaybackSession&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.routineVersion, routineVersion) || other.routineVersion == routineVersion)&&(identical(other.routineName, routineName) || other.routineName == routineName)&&(identical(other.recommendationId, recommendationId) || other.recommendationId == recommendationId)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentStepIndex, currentStepIndex) || other.currentStepIndex == currentStepIndex)&&const DeepCollectionEquality().equals(other.steps, steps));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,routineId,routineVersion,routineName,recommendationId,status,currentStepIndex,const DeepCollectionEquality().hash(steps));

@override
String toString() {
  return 'RoutinePlaybackSession(sessionId: $sessionId, routineId: $routineId, routineVersion: $routineVersion, routineName: $routineName, recommendationId: $recommendationId, status: $status, currentStepIndex: $currentStepIndex, steps: $steps)';
}


}

/// @nodoc
abstract mixin class $RoutinePlaybackSessionCopyWith<$Res>  {
  factory $RoutinePlaybackSessionCopyWith(RoutinePlaybackSession value, $Res Function(RoutinePlaybackSession) _then) = _$RoutinePlaybackSessionCopyWithImpl;
@useResult
$Res call({
 String sessionId, String routineId, int routineVersion, String routineName, String? recommendationId, PlaybackStatus status, int currentStepIndex, List<RoutineStepPlayback> steps
});




}
/// @nodoc
class _$RoutinePlaybackSessionCopyWithImpl<$Res>
    implements $RoutinePlaybackSessionCopyWith<$Res> {
  _$RoutinePlaybackSessionCopyWithImpl(this._self, this._then);

  final RoutinePlaybackSession _self;
  final $Res Function(RoutinePlaybackSession) _then;

/// Create a copy of RoutinePlaybackSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? routineId = null,Object? routineVersion = null,Object? routineName = null,Object? recommendationId = freezed,Object? status = null,Object? currentStepIndex = null,Object? steps = null,}) {
  return _then(RoutinePlaybackSession(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,routineVersion: null == routineVersion ? _self.routineVersion : routineVersion // ignore: cast_nullable_to_non_nullable
as int,routineName: null == routineName ? _self.routineName : routineName // ignore: cast_nullable_to_non_nullable
as String,recommendationId: freezed == recommendationId ? _self.recommendationId : recommendationId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlaybackStatus,currentStepIndex: null == currentStepIndex ? _self.currentStepIndex : currentStepIndex // ignore: cast_nullable_to_non_nullable
as int,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<RoutineStepPlayback>,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutinePlaybackSession].
extension RoutinePlaybackSessionPatterns on RoutinePlaybackSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutinePlaybackSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutinePlaybackSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutinePlaybackSession value)  $default,){
final _that = this;
switch (_that) {
case _RoutinePlaybackSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutinePlaybackSession value)?  $default,){
final _that = this;
switch (_that) {
case _RoutinePlaybackSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId,  String routineId,  int routineVersion,  String routineName,  String? recommendationId,  PlaybackStatus status,  int currentStepIndex,  List<RoutineStepPlayback> steps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutinePlaybackSession() when $default != null:
return $default(_that.sessionId,_that.routineId,_that.routineVersion,_that.routineName,_that.recommendationId,_that.status,_that.currentStepIndex,_that.steps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId,  String routineId,  int routineVersion,  String routineName,  String? recommendationId,  PlaybackStatus status,  int currentStepIndex,  List<RoutineStepPlayback> steps)  $default,) {final _that = this;
switch (_that) {
case _RoutinePlaybackSession():
return $default(_that.sessionId,_that.routineId,_that.routineVersion,_that.routineName,_that.recommendationId,_that.status,_that.currentStepIndex,_that.steps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId,  String routineId,  int routineVersion,  String routineName,  String? recommendationId,  PlaybackStatus status,  int currentStepIndex,  List<RoutineStepPlayback> steps)?  $default,) {final _that = this;
switch (_that) {
case _RoutinePlaybackSession() when $default != null:
return $default(_that.sessionId,_that.routineId,_that.routineVersion,_that.routineName,_that.recommendationId,_that.status,_that.currentStepIndex,_that.steps);case _:
  return null;

}
}

}

/// @nodoc


class _RoutinePlaybackSession extends RoutinePlaybackSession {
  const _RoutinePlaybackSession({required this.sessionId, required this.routineId, required this.routineVersion, required this.routineName, this.recommendationId, required this.status, required this.currentStepIndex, required  List<RoutineStepPlayback> steps}): _steps = steps,super._();
  

@override final  String sessionId;
@override final  String routineId;
@override final  int routineVersion;
@override final  String routineName;
@override final  String? recommendationId;
@override final  PlaybackStatus status;
@override final  int currentStepIndex;
 final  List<RoutineStepPlayback> _steps;
@override List<RoutineStepPlayback> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}


/// Create a copy of RoutinePlaybackSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutinePlaybackSessionCopyWith<_RoutinePlaybackSession> get copyWith => __$RoutinePlaybackSessionCopyWithImpl<_RoutinePlaybackSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutinePlaybackSession&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.routineVersion, routineVersion) || other.routineVersion == routineVersion)&&(identical(other.routineName, routineName) || other.routineName == routineName)&&(identical(other.recommendationId, recommendationId) || other.recommendationId == recommendationId)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentStepIndex, currentStepIndex) || other.currentStepIndex == currentStepIndex)&&const DeepCollectionEquality().equals(other._steps, _steps));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,routineId,routineVersion,routineName,recommendationId,status,currentStepIndex,const DeepCollectionEquality().hash(_steps));

@override
String toString() {
  return 'RoutinePlaybackSession(sessionId: $sessionId, routineId: $routineId, routineVersion: $routineVersion, routineName: $routineName, recommendationId: $recommendationId, status: $status, currentStepIndex: $currentStepIndex, steps: $steps)';
}


}

/// @nodoc
abstract mixin class _$RoutinePlaybackSessionCopyWith<$Res> implements $RoutinePlaybackSessionCopyWith<$Res> {
  factory _$RoutinePlaybackSessionCopyWith(_RoutinePlaybackSession value, $Res Function(_RoutinePlaybackSession) _then) = __$RoutinePlaybackSessionCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, String routineId, int routineVersion, String routineName, String? recommendationId, PlaybackStatus status, int currentStepIndex, List<RoutineStepPlayback> steps
});




}
/// @nodoc
class __$RoutinePlaybackSessionCopyWithImpl<$Res>
    implements _$RoutinePlaybackSessionCopyWith<$Res> {
  __$RoutinePlaybackSessionCopyWithImpl(this._self, this._then);

  final _RoutinePlaybackSession _self;
  final $Res Function(_RoutinePlaybackSession) _then;

/// Create a copy of RoutinePlaybackSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? routineId = null,Object? routineVersion = null,Object? routineName = null,Object? recommendationId = freezed,Object? status = null,Object? currentStepIndex = null,Object? steps = null,}) {
  return _then(_RoutinePlaybackSession(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,routineVersion: null == routineVersion ? _self.routineVersion : routineVersion // ignore: cast_nullable_to_non_nullable
as int,routineName: null == routineName ? _self.routineName : routineName // ignore: cast_nullable_to_non_nullable
as String,recommendationId: freezed == recommendationId ? _self.recommendationId : recommendationId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlaybackStatus,currentStepIndex: null == currentStepIndex ? _self.currentStepIndex : currentStepIndex // ignore: cast_nullable_to_non_nullable
as int,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<RoutineStepPlayback>,
  ));
}


}

// dart format on
