// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_presentation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MovementPreviewEntry {

 String get name; int get durationSeconds;
/// Create a copy of MovementPreviewEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovementPreviewEntryCopyWith<MovementPreviewEntry> get copyWith => _$MovementPreviewEntryCopyWithImpl<MovementPreviewEntry>(this as MovementPreviewEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovementPreviewEntry&&(identical(other.name, name) || other.name == name)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,name,durationSeconds);

@override
String toString() {
  return 'MovementPreviewEntry(name: $name, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class $MovementPreviewEntryCopyWith<$Res>  {
  factory $MovementPreviewEntryCopyWith(MovementPreviewEntry value, $Res Function(MovementPreviewEntry) _then) = _$MovementPreviewEntryCopyWithImpl;
@useResult
$Res call({
 String name, int durationSeconds
});




}
/// @nodoc
class _$MovementPreviewEntryCopyWithImpl<$Res>
    implements $MovementPreviewEntryCopyWith<$Res> {
  _$MovementPreviewEntryCopyWithImpl(this._self, this._then);

  final MovementPreviewEntry _self;
  final $Res Function(MovementPreviewEntry) _then;

/// Create a copy of MovementPreviewEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? durationSeconds = null,}) {
  return _then(MovementPreviewEntry(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MovementPreviewEntry].
extension MovementPreviewEntryPatterns on MovementPreviewEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovementPreviewEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovementPreviewEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovementPreviewEntry value)  $default,){
final _that = this;
switch (_that) {
case _MovementPreviewEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovementPreviewEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MovementPreviewEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int durationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovementPreviewEntry() when $default != null:
return $default(_that.name,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int durationSeconds)  $default,) {final _that = this;
switch (_that) {
case _MovementPreviewEntry():
return $default(_that.name,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int durationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _MovementPreviewEntry() when $default != null:
return $default(_that.name,_that.durationSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _MovementPreviewEntry implements MovementPreviewEntry {
  const _MovementPreviewEntry({required this.name, required this.durationSeconds});
  

@override final  String name;
@override final  int durationSeconds;

/// Create a copy of MovementPreviewEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovementPreviewEntryCopyWith<_MovementPreviewEntry> get copyWith => __$MovementPreviewEntryCopyWithImpl<_MovementPreviewEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovementPreviewEntry&&(identical(other.name, name) || other.name == name)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,name,durationSeconds);

@override
String toString() {
  return 'MovementPreviewEntry(name: $name, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class _$MovementPreviewEntryCopyWith<$Res> implements $MovementPreviewEntryCopyWith<$Res> {
  factory _$MovementPreviewEntryCopyWith(_MovementPreviewEntry value, $Res Function(_MovementPreviewEntry) _then) = __$MovementPreviewEntryCopyWithImpl;
@override @useResult
$Res call({
 String name, int durationSeconds
});




}
/// @nodoc
class __$MovementPreviewEntryCopyWithImpl<$Res>
    implements _$MovementPreviewEntryCopyWith<$Res> {
  __$MovementPreviewEntryCopyWithImpl(this._self, this._then);

  final _MovementPreviewEntry _self;
  final $Res Function(_MovementPreviewEntry) _then;

/// Create a copy of MovementPreviewEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? durationSeconds = null,}) {
  return _then(_MovementPreviewEntry(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$RoutinePresentation {

 String get routineId;/// Localized routine name (requested locale, falling back to `en`).
 String get name;/// Localized intended-benefit summary (requested locale, fallback `en`).
 String get summary;/// Ordered, localized movement names and durations.
 List<MovementPreviewEntry> get movements; DifficultyLevel get difficulty; int get estimatedDurationSeconds;/// Stable position taxonomy keys (localized by the presentation layer).
 Set<String> get positions;/// Stable equipment taxonomy keys (empty means no equipment).
 Set<String> get equipment;
/// Create a copy of RoutinePresentation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutinePresentationCopyWith<RoutinePresentation> get copyWith => _$RoutinePresentationCopyWithImpl<RoutinePresentation>(this as RoutinePresentation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutinePresentation&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.name, name) || other.name == name)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.movements, movements)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedDurationSeconds, estimatedDurationSeconds) || other.estimatedDurationSeconds == estimatedDurationSeconds)&&const DeepCollectionEquality().equals(other.positions, positions)&&const DeepCollectionEquality().equals(other.equipment, equipment));
}


@override
int get hashCode => Object.hash(runtimeType,routineId,name,summary,const DeepCollectionEquality().hash(movements),difficulty,estimatedDurationSeconds,const DeepCollectionEquality().hash(positions),const DeepCollectionEquality().hash(equipment));

@override
String toString() {
  return 'RoutinePresentation(routineId: $routineId, name: $name, summary: $summary, movements: $movements, difficulty: $difficulty, estimatedDurationSeconds: $estimatedDurationSeconds, positions: $positions, equipment: $equipment)';
}


}

/// @nodoc
abstract mixin class $RoutinePresentationCopyWith<$Res>  {
  factory $RoutinePresentationCopyWith(RoutinePresentation value, $Res Function(RoutinePresentation) _then) = _$RoutinePresentationCopyWithImpl;
@useResult
$Res call({
 String routineId, String name, String summary, List<MovementPreviewEntry> movements, DifficultyLevel difficulty, int estimatedDurationSeconds, Set<String> positions, Set<String> equipment
});




}
/// @nodoc
class _$RoutinePresentationCopyWithImpl<$Res>
    implements $RoutinePresentationCopyWith<$Res> {
  _$RoutinePresentationCopyWithImpl(this._self, this._then);

  final RoutinePresentation _self;
  final $Res Function(RoutinePresentation) _then;

/// Create a copy of RoutinePresentation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routineId = null,Object? name = null,Object? summary = null,Object? movements = null,Object? difficulty = null,Object? estimatedDurationSeconds = null,Object? positions = null,Object? equipment = null,}) {
  return _then(RoutinePresentation(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,movements: null == movements ? _self.movements : movements // ignore: cast_nullable_to_non_nullable
as List<MovementPreviewEntry>,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as DifficultyLevel,estimatedDurationSeconds: null == estimatedDurationSeconds ? _self.estimatedDurationSeconds : estimatedDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,positions: null == positions ? _self.positions : positions // ignore: cast_nullable_to_non_nullable
as Set<String>,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutinePresentation].
extension RoutinePresentationPatterns on RoutinePresentation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutinePresentation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutinePresentation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutinePresentation value)  $default,){
final _that = this;
switch (_that) {
case _RoutinePresentation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutinePresentation value)?  $default,){
final _that = this;
switch (_that) {
case _RoutinePresentation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String routineId,  String name,  String summary,  List<MovementPreviewEntry> movements,  DifficultyLevel difficulty,  int estimatedDurationSeconds,  Set<String> positions,  Set<String> equipment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutinePresentation() when $default != null:
return $default(_that.routineId,_that.name,_that.summary,_that.movements,_that.difficulty,_that.estimatedDurationSeconds,_that.positions,_that.equipment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String routineId,  String name,  String summary,  List<MovementPreviewEntry> movements,  DifficultyLevel difficulty,  int estimatedDurationSeconds,  Set<String> positions,  Set<String> equipment)  $default,) {final _that = this;
switch (_that) {
case _RoutinePresentation():
return $default(_that.routineId,_that.name,_that.summary,_that.movements,_that.difficulty,_that.estimatedDurationSeconds,_that.positions,_that.equipment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String routineId,  String name,  String summary,  List<MovementPreviewEntry> movements,  DifficultyLevel difficulty,  int estimatedDurationSeconds,  Set<String> positions,  Set<String> equipment)?  $default,) {final _that = this;
switch (_that) {
case _RoutinePresentation() when $default != null:
return $default(_that.routineId,_that.name,_that.summary,_that.movements,_that.difficulty,_that.estimatedDurationSeconds,_that.positions,_that.equipment);case _:
  return null;

}
}

}

/// @nodoc


class _RoutinePresentation extends RoutinePresentation {
  const _RoutinePresentation({required this.routineId, required this.name, required this.summary, required  List<MovementPreviewEntry> movements, required this.difficulty, required this.estimatedDurationSeconds, required  Set<String> positions, required  Set<String> equipment}): _movements = movements,_positions = positions,_equipment = equipment,super._();
  

@override final  String routineId;
/// Localized routine name (requested locale, falling back to `en`).
@override final  String name;
/// Localized intended-benefit summary (requested locale, fallback `en`).
@override final  String summary;
/// Ordered, localized movement names and durations.
 final  List<MovementPreviewEntry> _movements;
/// Ordered, localized movement names and durations.
@override List<MovementPreviewEntry> get movements {
  if (_movements is EqualUnmodifiableListView) return _movements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_movements);
}

@override final  DifficultyLevel difficulty;
@override final  int estimatedDurationSeconds;
/// Stable position taxonomy keys (localized by the presentation layer).
 final  Set<String> _positions;
/// Stable position taxonomy keys (localized by the presentation layer).
@override Set<String> get positions {
  if (_positions is EqualUnmodifiableSetView) return _positions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_positions);
}

/// Stable equipment taxonomy keys (empty means no equipment).
 final  Set<String> _equipment;
/// Stable equipment taxonomy keys (empty means no equipment).
@override Set<String> get equipment {
  if (_equipment is EqualUnmodifiableSetView) return _equipment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_equipment);
}


/// Create a copy of RoutinePresentation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutinePresentationCopyWith<_RoutinePresentation> get copyWith => __$RoutinePresentationCopyWithImpl<_RoutinePresentation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutinePresentation&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.name, name) || other.name == name)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._movements, _movements)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedDurationSeconds, estimatedDurationSeconds) || other.estimatedDurationSeconds == estimatedDurationSeconds)&&const DeepCollectionEquality().equals(other._positions, _positions)&&const DeepCollectionEquality().equals(other._equipment, _equipment));
}


@override
int get hashCode => Object.hash(runtimeType,routineId,name,summary,const DeepCollectionEquality().hash(_movements),difficulty,estimatedDurationSeconds,const DeepCollectionEquality().hash(_positions),const DeepCollectionEquality().hash(_equipment));

@override
String toString() {
  return 'RoutinePresentation(routineId: $routineId, name: $name, summary: $summary, movements: $movements, difficulty: $difficulty, estimatedDurationSeconds: $estimatedDurationSeconds, positions: $positions, equipment: $equipment)';
}


}

/// @nodoc
abstract mixin class _$RoutinePresentationCopyWith<$Res> implements $RoutinePresentationCopyWith<$Res> {
  factory _$RoutinePresentationCopyWith(_RoutinePresentation value, $Res Function(_RoutinePresentation) _then) = __$RoutinePresentationCopyWithImpl;
@override @useResult
$Res call({
 String routineId, String name, String summary, List<MovementPreviewEntry> movements, DifficultyLevel difficulty, int estimatedDurationSeconds, Set<String> positions, Set<String> equipment
});




}
/// @nodoc
class __$RoutinePresentationCopyWithImpl<$Res>
    implements _$RoutinePresentationCopyWith<$Res> {
  __$RoutinePresentationCopyWithImpl(this._self, this._then);

  final _RoutinePresentation _self;
  final $Res Function(_RoutinePresentation) _then;

/// Create a copy of RoutinePresentation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routineId = null,Object? name = null,Object? summary = null,Object? movements = null,Object? difficulty = null,Object? estimatedDurationSeconds = null,Object? positions = null,Object? equipment = null,}) {
  return _then(_RoutinePresentation(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,movements: null == movements ? _self._movements : movements // ignore: cast_nullable_to_non_nullable
as List<MovementPreviewEntry>,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as DifficultyLevel,estimatedDurationSeconds: null == estimatedDurationSeconds ? _self.estimatedDurationSeconds : estimatedDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,positions: null == positions ? _self._positions : positions // ignore: cast_nullable_to_non_nullable
as Set<String>,equipment: null == equipment ? _self._equipment : equipment // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
