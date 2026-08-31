// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_candidate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecommendationCandidate {

 String get routineId; ContentStatus get status; AccessTier get accessTier; DifficultyLevel get difficulty; int get estimatedDurationSeconds;/// Stable taxonomy keys the routine addresses (body_area kind).
 Set<String> get bodyAreas;/// Stable taxonomy keys the routine serves (goal kind).
 Set<String> get goals;/// Stable taxonomy keys the routine can be performed in (position kind).
 Set<String> get positions;/// Stable exercise ids referenced by the routine's published steps.
 Set<String> get exerciseIds;/// True only when every referenced exercise is safety-approved.
 bool get exercisesSafetyApproved;/// True only when every referenced exercise has a preferred, published,
/// playable media asset.
 bool get exercisesHavePlayableMedia;/// Minimum app version required by the current content release, if any.
 String? get minimumAppVersion;
/// Create a copy of RecommendationCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationCandidateCopyWith<RecommendationCandidate> get copyWith => _$RecommendationCandidateCopyWithImpl<RecommendationCandidate>(this as RecommendationCandidate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationCandidate&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.status, status) || other.status == status)&&(identical(other.accessTier, accessTier) || other.accessTier == accessTier)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedDurationSeconds, estimatedDurationSeconds) || other.estimatedDurationSeconds == estimatedDurationSeconds)&&const DeepCollectionEquality().equals(other.bodyAreas, bodyAreas)&&const DeepCollectionEquality().equals(other.goals, goals)&&const DeepCollectionEquality().equals(other.positions, positions)&&const DeepCollectionEquality().equals(other.exerciseIds, exerciseIds)&&(identical(other.exercisesSafetyApproved, exercisesSafetyApproved) || other.exercisesSafetyApproved == exercisesSafetyApproved)&&(identical(other.exercisesHavePlayableMedia, exercisesHavePlayableMedia) || other.exercisesHavePlayableMedia == exercisesHavePlayableMedia)&&(identical(other.minimumAppVersion, minimumAppVersion) || other.minimumAppVersion == minimumAppVersion));
}


@override
int get hashCode => Object.hash(runtimeType,routineId,status,accessTier,difficulty,estimatedDurationSeconds,const DeepCollectionEquality().hash(bodyAreas),const DeepCollectionEquality().hash(goals),const DeepCollectionEquality().hash(positions),const DeepCollectionEquality().hash(exerciseIds),exercisesSafetyApproved,exercisesHavePlayableMedia,minimumAppVersion);

@override
String toString() {
  return 'RecommendationCandidate(routineId: $routineId, status: $status, accessTier: $accessTier, difficulty: $difficulty, estimatedDurationSeconds: $estimatedDurationSeconds, bodyAreas: $bodyAreas, goals: $goals, positions: $positions, exerciseIds: $exerciseIds, exercisesSafetyApproved: $exercisesSafetyApproved, exercisesHavePlayableMedia: $exercisesHavePlayableMedia, minimumAppVersion: $minimumAppVersion)';
}


}

/// @nodoc
abstract mixin class $RecommendationCandidateCopyWith<$Res>  {
  factory $RecommendationCandidateCopyWith(RecommendationCandidate value, $Res Function(RecommendationCandidate) _then) = _$RecommendationCandidateCopyWithImpl;
@useResult
$Res call({
 String routineId, ContentStatus status, AccessTier accessTier, DifficultyLevel difficulty, int estimatedDurationSeconds, Set<String> bodyAreas, Set<String> goals, Set<String> positions, Set<String> exerciseIds, bool exercisesSafetyApproved, bool exercisesHavePlayableMedia, String? minimumAppVersion
});




}
/// @nodoc
class _$RecommendationCandidateCopyWithImpl<$Res>
    implements $RecommendationCandidateCopyWith<$Res> {
  _$RecommendationCandidateCopyWithImpl(this._self, this._then);

  final RecommendationCandidate _self;
  final $Res Function(RecommendationCandidate) _then;

/// Create a copy of RecommendationCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routineId = null,Object? status = null,Object? accessTier = null,Object? difficulty = null,Object? estimatedDurationSeconds = null,Object? bodyAreas = null,Object? goals = null,Object? positions = null,Object? exerciseIds = null,Object? exercisesSafetyApproved = null,Object? exercisesHavePlayableMedia = null,Object? minimumAppVersion = freezed,}) {
  return _then(RecommendationCandidate(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,accessTier: null == accessTier ? _self.accessTier : accessTier // ignore: cast_nullable_to_non_nullable
as AccessTier,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as DifficultyLevel,estimatedDurationSeconds: null == estimatedDurationSeconds ? _self.estimatedDurationSeconds : estimatedDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,bodyAreas: null == bodyAreas ? _self.bodyAreas : bodyAreas // ignore: cast_nullable_to_non_nullable
as Set<String>,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as Set<String>,positions: null == positions ? _self.positions : positions // ignore: cast_nullable_to_non_nullable
as Set<String>,exerciseIds: null == exerciseIds ? _self.exerciseIds : exerciseIds // ignore: cast_nullable_to_non_nullable
as Set<String>,exercisesSafetyApproved: null == exercisesSafetyApproved ? _self.exercisesSafetyApproved : exercisesSafetyApproved // ignore: cast_nullable_to_non_nullable
as bool,exercisesHavePlayableMedia: null == exercisesHavePlayableMedia ? _self.exercisesHavePlayableMedia : exercisesHavePlayableMedia // ignore: cast_nullable_to_non_nullable
as bool,minimumAppVersion: freezed == minimumAppVersion ? _self.minimumAppVersion : minimumAppVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecommendationCandidate].
extension RecommendationCandidatePatterns on RecommendationCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationCandidate value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String routineId,  ContentStatus status,  AccessTier accessTier,  DifficultyLevel difficulty,  int estimatedDurationSeconds,  Set<String> bodyAreas,  Set<String> goals,  Set<String> positions,  Set<String> exerciseIds,  bool exercisesSafetyApproved,  bool exercisesHavePlayableMedia,  String? minimumAppVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationCandidate() when $default != null:
return $default(_that.routineId,_that.status,_that.accessTier,_that.difficulty,_that.estimatedDurationSeconds,_that.bodyAreas,_that.goals,_that.positions,_that.exerciseIds,_that.exercisesSafetyApproved,_that.exercisesHavePlayableMedia,_that.minimumAppVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String routineId,  ContentStatus status,  AccessTier accessTier,  DifficultyLevel difficulty,  int estimatedDurationSeconds,  Set<String> bodyAreas,  Set<String> goals,  Set<String> positions,  Set<String> exerciseIds,  bool exercisesSafetyApproved,  bool exercisesHavePlayableMedia,  String? minimumAppVersion)  $default,) {final _that = this;
switch (_that) {
case _RecommendationCandidate():
return $default(_that.routineId,_that.status,_that.accessTier,_that.difficulty,_that.estimatedDurationSeconds,_that.bodyAreas,_that.goals,_that.positions,_that.exerciseIds,_that.exercisesSafetyApproved,_that.exercisesHavePlayableMedia,_that.minimumAppVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String routineId,  ContentStatus status,  AccessTier accessTier,  DifficultyLevel difficulty,  int estimatedDurationSeconds,  Set<String> bodyAreas,  Set<String> goals,  Set<String> positions,  Set<String> exerciseIds,  bool exercisesSafetyApproved,  bool exercisesHavePlayableMedia,  String? minimumAppVersion)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationCandidate() when $default != null:
return $default(_that.routineId,_that.status,_that.accessTier,_that.difficulty,_that.estimatedDurationSeconds,_that.bodyAreas,_that.goals,_that.positions,_that.exerciseIds,_that.exercisesSafetyApproved,_that.exercisesHavePlayableMedia,_that.minimumAppVersion);case _:
  return null;

}
}

}

/// @nodoc


class _RecommendationCandidate implements RecommendationCandidate {
  const _RecommendationCandidate({required this.routineId, required this.status, required this.accessTier, required this.difficulty, required this.estimatedDurationSeconds, required  Set<String> bodyAreas, required  Set<String> goals, required  Set<String> positions, required  Set<String> exerciseIds, required this.exercisesSafetyApproved, required this.exercisesHavePlayableMedia, this.minimumAppVersion}): _bodyAreas = bodyAreas,_goals = goals,_positions = positions,_exerciseIds = exerciseIds;
  

@override final  String routineId;
@override final  ContentStatus status;
@override final  AccessTier accessTier;
@override final  DifficultyLevel difficulty;
@override final  int estimatedDurationSeconds;
/// Stable taxonomy keys the routine addresses (body_area kind).
 final  Set<String> _bodyAreas;
/// Stable taxonomy keys the routine addresses (body_area kind).
@override Set<String> get bodyAreas {
  if (_bodyAreas is EqualUnmodifiableSetView) return _bodyAreas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_bodyAreas);
}

/// Stable taxonomy keys the routine serves (goal kind).
 final  Set<String> _goals;
/// Stable taxonomy keys the routine serves (goal kind).
@override Set<String> get goals {
  if (_goals is EqualUnmodifiableSetView) return _goals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_goals);
}

/// Stable taxonomy keys the routine can be performed in (position kind).
 final  Set<String> _positions;
/// Stable taxonomy keys the routine can be performed in (position kind).
@override Set<String> get positions {
  if (_positions is EqualUnmodifiableSetView) return _positions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_positions);
}

/// Stable exercise ids referenced by the routine's published steps.
 final  Set<String> _exerciseIds;
/// Stable exercise ids referenced by the routine's published steps.
@override Set<String> get exerciseIds {
  if (_exerciseIds is EqualUnmodifiableSetView) return _exerciseIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_exerciseIds);
}

/// True only when every referenced exercise is safety-approved.
@override final  bool exercisesSafetyApproved;
/// True only when every referenced exercise has a preferred, published,
/// playable media asset.
@override final  bool exercisesHavePlayableMedia;
/// Minimum app version required by the current content release, if any.
@override final  String? minimumAppVersion;

/// Create a copy of RecommendationCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationCandidateCopyWith<_RecommendationCandidate> get copyWith => __$RecommendationCandidateCopyWithImpl<_RecommendationCandidate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationCandidate&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.status, status) || other.status == status)&&(identical(other.accessTier, accessTier) || other.accessTier == accessTier)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedDurationSeconds, estimatedDurationSeconds) || other.estimatedDurationSeconds == estimatedDurationSeconds)&&const DeepCollectionEquality().equals(other._bodyAreas, _bodyAreas)&&const DeepCollectionEquality().equals(other._goals, _goals)&&const DeepCollectionEquality().equals(other._positions, _positions)&&const DeepCollectionEquality().equals(other._exerciseIds, _exerciseIds)&&(identical(other.exercisesSafetyApproved, exercisesSafetyApproved) || other.exercisesSafetyApproved == exercisesSafetyApproved)&&(identical(other.exercisesHavePlayableMedia, exercisesHavePlayableMedia) || other.exercisesHavePlayableMedia == exercisesHavePlayableMedia)&&(identical(other.minimumAppVersion, minimumAppVersion) || other.minimumAppVersion == minimumAppVersion));
}


@override
int get hashCode => Object.hash(runtimeType,routineId,status,accessTier,difficulty,estimatedDurationSeconds,const DeepCollectionEquality().hash(_bodyAreas),const DeepCollectionEquality().hash(_goals),const DeepCollectionEquality().hash(_positions),const DeepCollectionEquality().hash(_exerciseIds),exercisesSafetyApproved,exercisesHavePlayableMedia,minimumAppVersion);

@override
String toString() {
  return 'RecommendationCandidate(routineId: $routineId, status: $status, accessTier: $accessTier, difficulty: $difficulty, estimatedDurationSeconds: $estimatedDurationSeconds, bodyAreas: $bodyAreas, goals: $goals, positions: $positions, exerciseIds: $exerciseIds, exercisesSafetyApproved: $exercisesSafetyApproved, exercisesHavePlayableMedia: $exercisesHavePlayableMedia, minimumAppVersion: $minimumAppVersion)';
}


}

/// @nodoc
abstract mixin class _$RecommendationCandidateCopyWith<$Res> implements $RecommendationCandidateCopyWith<$Res> {
  factory _$RecommendationCandidateCopyWith(_RecommendationCandidate value, $Res Function(_RecommendationCandidate) _then) = __$RecommendationCandidateCopyWithImpl;
@override @useResult
$Res call({
 String routineId, ContentStatus status, AccessTier accessTier, DifficultyLevel difficulty, int estimatedDurationSeconds, Set<String> bodyAreas, Set<String> goals, Set<String> positions, Set<String> exerciseIds, bool exercisesSafetyApproved, bool exercisesHavePlayableMedia, String? minimumAppVersion
});




}
/// @nodoc
class __$RecommendationCandidateCopyWithImpl<$Res>
    implements _$RecommendationCandidateCopyWith<$Res> {
  __$RecommendationCandidateCopyWithImpl(this._self, this._then);

  final _RecommendationCandidate _self;
  final $Res Function(_RecommendationCandidate) _then;

/// Create a copy of RecommendationCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routineId = null,Object? status = null,Object? accessTier = null,Object? difficulty = null,Object? estimatedDurationSeconds = null,Object? bodyAreas = null,Object? goals = null,Object? positions = null,Object? exerciseIds = null,Object? exercisesSafetyApproved = null,Object? exercisesHavePlayableMedia = null,Object? minimumAppVersion = freezed,}) {
  return _then(_RecommendationCandidate(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,accessTier: null == accessTier ? _self.accessTier : accessTier // ignore: cast_nullable_to_non_nullable
as AccessTier,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as DifficultyLevel,estimatedDurationSeconds: null == estimatedDurationSeconds ? _self.estimatedDurationSeconds : estimatedDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,bodyAreas: null == bodyAreas ? _self._bodyAreas : bodyAreas // ignore: cast_nullable_to_non_nullable
as Set<String>,goals: null == goals ? _self._goals : goals // ignore: cast_nullable_to_non_nullable
as Set<String>,positions: null == positions ? _self._positions : positions // ignore: cast_nullable_to_non_nullable
as Set<String>,exerciseIds: null == exerciseIds ? _self._exerciseIds : exerciseIds // ignore: cast_nullable_to_non_nullable
as Set<String>,exercisesSafetyApproved: null == exercisesSafetyApproved ? _self.exercisesSafetyApproved : exercisesSafetyApproved // ignore: cast_nullable_to_non_nullable
as bool,exercisesHavePlayableMedia: null == exercisesHavePlayableMedia ? _self.exercisesHavePlayableMedia : exercisesHavePlayableMedia // ignore: cast_nullable_to_non_nullable
as bool,minimumAppVersion: freezed == minimumAppVersion ? _self.minimumAppVersion : minimumAppVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
