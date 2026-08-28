// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Exercise {

 String get id; ContentStatus get status; AccessTier get accessTier; DifficultyLevel get difficulty; SafetyReviewStatus get safetyReviewStatus; Map<String, LocalizedExerciseContent> get translations; ExerciseClassification get classification; List<ProviderExerciseMapping> get providerMappings; List<MediaAsset> get mediaAssets;
/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseCopyWith<Exercise> get copyWith => _$ExerciseCopyWithImpl<Exercise>(this as Exercise, _$identity);

  /// Serializes this Exercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Exercise&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.accessTier, accessTier) || other.accessTier == accessTier)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.safetyReviewStatus, safetyReviewStatus) || other.safetyReviewStatus == safetyReviewStatus)&&const DeepCollectionEquality().equals(other.translations, translations)&&(identical(other.classification, classification) || other.classification == classification)&&const DeepCollectionEquality().equals(other.providerMappings, providerMappings)&&const DeepCollectionEquality().equals(other.mediaAssets, mediaAssets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,accessTier,difficulty,safetyReviewStatus,const DeepCollectionEquality().hash(translations),classification,const DeepCollectionEquality().hash(providerMappings),const DeepCollectionEquality().hash(mediaAssets));

@override
String toString() {
  return 'Exercise(id: $id, status: $status, accessTier: $accessTier, difficulty: $difficulty, safetyReviewStatus: $safetyReviewStatus, translations: $translations, classification: $classification, providerMappings: $providerMappings, mediaAssets: $mediaAssets)';
}


}

/// @nodoc
abstract mixin class $ExerciseCopyWith<$Res>  {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) _then) = _$ExerciseCopyWithImpl;
@useResult
$Res call({
 String id, ContentStatus status, AccessTier accessTier, DifficultyLevel difficulty, SafetyReviewStatus safetyReviewStatus, Map<String, LocalizedExerciseContent> translations, ExerciseClassification classification, List<ProviderExerciseMapping> providerMappings, List<MediaAsset> mediaAssets
});


$ExerciseClassificationCopyWith<$Res> get classification;

}
/// @nodoc
class _$ExerciseCopyWithImpl<$Res>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._self, this._then);

  final Exercise _self;
  final $Res Function(Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? accessTier = null,Object? difficulty = null,Object? safetyReviewStatus = null,Object? translations = null,Object? classification = null,Object? providerMappings = null,Object? mediaAssets = null,}) {
  return _then(Exercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,accessTier: null == accessTier ? _self.accessTier : accessTier // ignore: cast_nullable_to_non_nullable
as AccessTier,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as DifficultyLevel,safetyReviewStatus: null == safetyReviewStatus ? _self.safetyReviewStatus : safetyReviewStatus // ignore: cast_nullable_to_non_nullable
as SafetyReviewStatus,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as Map<String, LocalizedExerciseContent>,classification: null == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as ExerciseClassification,providerMappings: null == providerMappings ? _self.providerMappings : providerMappings // ignore: cast_nullable_to_non_nullable
as List<ProviderExerciseMapping>,mediaAssets: null == mediaAssets ? _self.mediaAssets : mediaAssets // ignore: cast_nullable_to_non_nullable
as List<MediaAsset>,
  ));
}
/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExerciseClassificationCopyWith<$Res> get classification {
  
  return $ExerciseClassificationCopyWith<$Res>(_self.classification, (value) {
    return _then(_self.copyWith(classification: value));
  });
}
}


/// Adds pattern-matching-related methods to [Exercise].
extension ExercisePatterns on Exercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Exercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Exercise value)  $default,){
final _that = this;
switch (_that) {
case _Exercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Exercise value)?  $default,){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ContentStatus status,  AccessTier accessTier,  DifficultyLevel difficulty,  SafetyReviewStatus safetyReviewStatus,  Map<String, LocalizedExerciseContent> translations,  ExerciseClassification classification,  List<ProviderExerciseMapping> providerMappings,  List<MediaAsset> mediaAssets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.status,_that.accessTier,_that.difficulty,_that.safetyReviewStatus,_that.translations,_that.classification,_that.providerMappings,_that.mediaAssets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ContentStatus status,  AccessTier accessTier,  DifficultyLevel difficulty,  SafetyReviewStatus safetyReviewStatus,  Map<String, LocalizedExerciseContent> translations,  ExerciseClassification classification,  List<ProviderExerciseMapping> providerMappings,  List<MediaAsset> mediaAssets)  $default,) {final _that = this;
switch (_that) {
case _Exercise():
return $default(_that.id,_that.status,_that.accessTier,_that.difficulty,_that.safetyReviewStatus,_that.translations,_that.classification,_that.providerMappings,_that.mediaAssets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ContentStatus status,  AccessTier accessTier,  DifficultyLevel difficulty,  SafetyReviewStatus safetyReviewStatus,  Map<String, LocalizedExerciseContent> translations,  ExerciseClassification classification,  List<ProviderExerciseMapping> providerMappings,  List<MediaAsset> mediaAssets)?  $default,) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.status,_that.accessTier,_that.difficulty,_that.safetyReviewStatus,_that.translations,_that.classification,_that.providerMappings,_that.mediaAssets);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Exercise implements Exercise {
  const _Exercise({required this.id, required this.status, required this.accessTier, required this.difficulty, required this.safetyReviewStatus, required  Map<String, LocalizedExerciseContent> translations, required this.classification,  List<ProviderExerciseMapping> providerMappings = const <ProviderExerciseMapping>[],  List<MediaAsset> mediaAssets = const <MediaAsset>[]}): _translations = translations,_providerMappings = providerMappings,_mediaAssets = mediaAssets;
  factory _Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

@override final  String id;
@override final  ContentStatus status;
@override final  AccessTier accessTier;
@override final  DifficultyLevel difficulty;
@override final  SafetyReviewStatus safetyReviewStatus;
 final  Map<String, LocalizedExerciseContent> _translations;
@override Map<String, LocalizedExerciseContent> get translations {
  if (_translations is EqualUnmodifiableMapView) return _translations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_translations);
}

@override final  ExerciseClassification classification;
 final  List<ProviderExerciseMapping> _providerMappings;
@override@JsonKey() List<ProviderExerciseMapping> get providerMappings {
  if (_providerMappings is EqualUnmodifiableListView) return _providerMappings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providerMappings);
}

 final  List<MediaAsset> _mediaAssets;
@override@JsonKey() List<MediaAsset> get mediaAssets {
  if (_mediaAssets is EqualUnmodifiableListView) return _mediaAssets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaAssets);
}


/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseCopyWith<_Exercise> get copyWith => __$ExerciseCopyWithImpl<_Exercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Exercise&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.accessTier, accessTier) || other.accessTier == accessTier)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.safetyReviewStatus, safetyReviewStatus) || other.safetyReviewStatus == safetyReviewStatus)&&const DeepCollectionEquality().equals(other._translations, _translations)&&(identical(other.classification, classification) || other.classification == classification)&&const DeepCollectionEquality().equals(other._providerMappings, _providerMappings)&&const DeepCollectionEquality().equals(other._mediaAssets, _mediaAssets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,accessTier,difficulty,safetyReviewStatus,const DeepCollectionEquality().hash(_translations),classification,const DeepCollectionEquality().hash(_providerMappings),const DeepCollectionEquality().hash(_mediaAssets));

@override
String toString() {
  return 'Exercise(id: $id, status: $status, accessTier: $accessTier, difficulty: $difficulty, safetyReviewStatus: $safetyReviewStatus, translations: $translations, classification: $classification, providerMappings: $providerMappings, mediaAssets: $mediaAssets)';
}


}

/// @nodoc
abstract mixin class _$ExerciseCopyWith<$Res> implements $ExerciseCopyWith<$Res> {
  factory _$ExerciseCopyWith(_Exercise value, $Res Function(_Exercise) _then) = __$ExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, ContentStatus status, AccessTier accessTier, DifficultyLevel difficulty, SafetyReviewStatus safetyReviewStatus, Map<String, LocalizedExerciseContent> translations, ExerciseClassification classification, List<ProviderExerciseMapping> providerMappings, List<MediaAsset> mediaAssets
});


@override $ExerciseClassificationCopyWith<$Res> get classification;

}
/// @nodoc
class __$ExerciseCopyWithImpl<$Res>
    implements _$ExerciseCopyWith<$Res> {
  __$ExerciseCopyWithImpl(this._self, this._then);

  final _Exercise _self;
  final $Res Function(_Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? accessTier = null,Object? difficulty = null,Object? safetyReviewStatus = null,Object? translations = null,Object? classification = null,Object? providerMappings = null,Object? mediaAssets = null,}) {
  return _then(_Exercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,accessTier: null == accessTier ? _self.accessTier : accessTier // ignore: cast_nullable_to_non_nullable
as AccessTier,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as DifficultyLevel,safetyReviewStatus: null == safetyReviewStatus ? _self.safetyReviewStatus : safetyReviewStatus // ignore: cast_nullable_to_non_nullable
as SafetyReviewStatus,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as Map<String, LocalizedExerciseContent>,classification: null == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as ExerciseClassification,providerMappings: null == providerMappings ? _self._providerMappings : providerMappings // ignore: cast_nullable_to_non_nullable
as List<ProviderExerciseMapping>,mediaAssets: null == mediaAssets ? _self._mediaAssets : mediaAssets // ignore: cast_nullable_to_non_nullable
as List<MediaAsset>,
  ));
}

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExerciseClassificationCopyWith<$Res> get classification {
  
  return $ExerciseClassificationCopyWith<$Res>(_self.classification, (value) {
    return _then(_self.copyWith(classification: value));
  });
}
}


/// @nodoc
mixin _$LocalizedExerciseContent {

 String get name; String? get description; String? get shortCue;
/// Create a copy of LocalizedExerciseContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalizedExerciseContentCopyWith<LocalizedExerciseContent> get copyWith => _$LocalizedExerciseContentCopyWithImpl<LocalizedExerciseContent>(this as LocalizedExerciseContent, _$identity);

  /// Serializes this LocalizedExerciseContent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalizedExerciseContent&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.shortCue, shortCue) || other.shortCue == shortCue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,shortCue);

@override
String toString() {
  return 'LocalizedExerciseContent(name: $name, description: $description, shortCue: $shortCue)';
}


}

/// @nodoc
abstract mixin class $LocalizedExerciseContentCopyWith<$Res>  {
  factory $LocalizedExerciseContentCopyWith(LocalizedExerciseContent value, $Res Function(LocalizedExerciseContent) _then) = _$LocalizedExerciseContentCopyWithImpl;
@useResult
$Res call({
 String name, String? description, String? shortCue
});




}
/// @nodoc
class _$LocalizedExerciseContentCopyWithImpl<$Res>
    implements $LocalizedExerciseContentCopyWith<$Res> {
  _$LocalizedExerciseContentCopyWithImpl(this._self, this._then);

  final LocalizedExerciseContent _self;
  final $Res Function(LocalizedExerciseContent) _then;

/// Create a copy of LocalizedExerciseContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = freezed,Object? shortCue = freezed,}) {
  return _then(LocalizedExerciseContent(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,shortCue: freezed == shortCue ? _self.shortCue : shortCue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalizedExerciseContent].
extension LocalizedExerciseContentPatterns on LocalizedExerciseContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalizedExerciseContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalizedExerciseContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalizedExerciseContent value)  $default,){
final _that = this;
switch (_that) {
case _LocalizedExerciseContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalizedExerciseContent value)?  $default,){
final _that = this;
switch (_that) {
case _LocalizedExerciseContent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? description,  String? shortCue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalizedExerciseContent() when $default != null:
return $default(_that.name,_that.description,_that.shortCue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? description,  String? shortCue)  $default,) {final _that = this;
switch (_that) {
case _LocalizedExerciseContent():
return $default(_that.name,_that.description,_that.shortCue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? description,  String? shortCue)?  $default,) {final _that = this;
switch (_that) {
case _LocalizedExerciseContent() when $default != null:
return $default(_that.name,_that.description,_that.shortCue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalizedExerciseContent implements LocalizedExerciseContent {
  const _LocalizedExerciseContent({required this.name, this.description, this.shortCue});
  factory _LocalizedExerciseContent.fromJson(Map<String, dynamic> json) => _$LocalizedExerciseContentFromJson(json);

@override final  String name;
@override final  String? description;
@override final  String? shortCue;

/// Create a copy of LocalizedExerciseContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalizedExerciseContentCopyWith<_LocalizedExerciseContent> get copyWith => __$LocalizedExerciseContentCopyWithImpl<_LocalizedExerciseContent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalizedExerciseContentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalizedExerciseContent&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.shortCue, shortCue) || other.shortCue == shortCue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,shortCue);

@override
String toString() {
  return 'LocalizedExerciseContent(name: $name, description: $description, shortCue: $shortCue)';
}


}

/// @nodoc
abstract mixin class _$LocalizedExerciseContentCopyWith<$Res> implements $LocalizedExerciseContentCopyWith<$Res> {
  factory _$LocalizedExerciseContentCopyWith(_LocalizedExerciseContent value, $Res Function(_LocalizedExerciseContent) _then) = __$LocalizedExerciseContentCopyWithImpl;
@override @useResult
$Res call({
 String name, String? description, String? shortCue
});




}
/// @nodoc
class __$LocalizedExerciseContentCopyWithImpl<$Res>
    implements _$LocalizedExerciseContentCopyWith<$Res> {
  __$LocalizedExerciseContentCopyWithImpl(this._self, this._then);

  final _LocalizedExerciseContent _self;
  final $Res Function(_LocalizedExerciseContent) _then;

/// Create a copy of LocalizedExerciseContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = freezed,Object? shortCue = freezed,}) {
  return _then(_LocalizedExerciseContent(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,shortCue: freezed == shortCue ? _self.shortCue : shortCue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ExerciseClassification {

 String get category; Set<String> get bodyAreas; Set<String> get equipment; Set<String> get positions; Set<String> get goals; Set<String> get contexts;
/// Create a copy of ExerciseClassification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseClassificationCopyWith<ExerciseClassification> get copyWith => _$ExerciseClassificationCopyWithImpl<ExerciseClassification>(this as ExerciseClassification, _$identity);

  /// Serializes this ExerciseClassification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseClassification&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.bodyAreas, bodyAreas)&&const DeepCollectionEquality().equals(other.equipment, equipment)&&const DeepCollectionEquality().equals(other.positions, positions)&&const DeepCollectionEquality().equals(other.goals, goals)&&const DeepCollectionEquality().equals(other.contexts, contexts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(bodyAreas),const DeepCollectionEquality().hash(equipment),const DeepCollectionEquality().hash(positions),const DeepCollectionEquality().hash(goals),const DeepCollectionEquality().hash(contexts));

@override
String toString() {
  return 'ExerciseClassification(category: $category, bodyAreas: $bodyAreas, equipment: $equipment, positions: $positions, goals: $goals, contexts: $contexts)';
}


}

/// @nodoc
abstract mixin class $ExerciseClassificationCopyWith<$Res>  {
  factory $ExerciseClassificationCopyWith(ExerciseClassification value, $Res Function(ExerciseClassification) _then) = _$ExerciseClassificationCopyWithImpl;
@useResult
$Res call({
 String category, Set<String> bodyAreas, Set<String> equipment, Set<String> positions, Set<String> goals, Set<String> contexts
});




}
/// @nodoc
class _$ExerciseClassificationCopyWithImpl<$Res>
    implements $ExerciseClassificationCopyWith<$Res> {
  _$ExerciseClassificationCopyWithImpl(this._self, this._then);

  final ExerciseClassification _self;
  final $Res Function(ExerciseClassification) _then;

/// Create a copy of ExerciseClassification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? bodyAreas = null,Object? equipment = null,Object? positions = null,Object? goals = null,Object? contexts = null,}) {
  return _then(ExerciseClassification(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,bodyAreas: null == bodyAreas ? _self.bodyAreas : bodyAreas // ignore: cast_nullable_to_non_nullable
as Set<String>,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as Set<String>,positions: null == positions ? _self.positions : positions // ignore: cast_nullable_to_non_nullable
as Set<String>,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as Set<String>,contexts: null == contexts ? _self.contexts : contexts // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseClassification].
extension ExerciseClassificationPatterns on ExerciseClassification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseClassification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseClassification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseClassification value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseClassification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseClassification value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseClassification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String category,  Set<String> bodyAreas,  Set<String> equipment,  Set<String> positions,  Set<String> goals,  Set<String> contexts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseClassification() when $default != null:
return $default(_that.category,_that.bodyAreas,_that.equipment,_that.positions,_that.goals,_that.contexts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String category,  Set<String> bodyAreas,  Set<String> equipment,  Set<String> positions,  Set<String> goals,  Set<String> contexts)  $default,) {final _that = this;
switch (_that) {
case _ExerciseClassification():
return $default(_that.category,_that.bodyAreas,_that.equipment,_that.positions,_that.goals,_that.contexts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String category,  Set<String> bodyAreas,  Set<String> equipment,  Set<String> positions,  Set<String> goals,  Set<String> contexts)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseClassification() when $default != null:
return $default(_that.category,_that.bodyAreas,_that.equipment,_that.positions,_that.goals,_that.contexts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseClassification implements ExerciseClassification {
  const _ExerciseClassification({required this.category, required  Set<String> bodyAreas,  Set<String> equipment = const <String>{}, required  Set<String> positions, required  Set<String> goals, required  Set<String> contexts}): _bodyAreas = bodyAreas,_equipment = equipment,_positions = positions,_goals = goals,_contexts = contexts;
  factory _ExerciseClassification.fromJson(Map<String, dynamic> json) => _$ExerciseClassificationFromJson(json);

@override final  String category;
 final  Set<String> _bodyAreas;
@override Set<String> get bodyAreas {
  if (_bodyAreas is EqualUnmodifiableSetView) return _bodyAreas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_bodyAreas);
}

 final  Set<String> _equipment;
@override@JsonKey() Set<String> get equipment {
  if (_equipment is EqualUnmodifiableSetView) return _equipment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_equipment);
}

 final  Set<String> _positions;
@override Set<String> get positions {
  if (_positions is EqualUnmodifiableSetView) return _positions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_positions);
}

 final  Set<String> _goals;
@override Set<String> get goals {
  if (_goals is EqualUnmodifiableSetView) return _goals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_goals);
}

 final  Set<String> _contexts;
@override Set<String> get contexts {
  if (_contexts is EqualUnmodifiableSetView) return _contexts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_contexts);
}


/// Create a copy of ExerciseClassification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseClassificationCopyWith<_ExerciseClassification> get copyWith => __$ExerciseClassificationCopyWithImpl<_ExerciseClassification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseClassificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseClassification&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._bodyAreas, _bodyAreas)&&const DeepCollectionEquality().equals(other._equipment, _equipment)&&const DeepCollectionEquality().equals(other._positions, _positions)&&const DeepCollectionEquality().equals(other._goals, _goals)&&const DeepCollectionEquality().equals(other._contexts, _contexts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(_bodyAreas),const DeepCollectionEquality().hash(_equipment),const DeepCollectionEquality().hash(_positions),const DeepCollectionEquality().hash(_goals),const DeepCollectionEquality().hash(_contexts));

@override
String toString() {
  return 'ExerciseClassification(category: $category, bodyAreas: $bodyAreas, equipment: $equipment, positions: $positions, goals: $goals, contexts: $contexts)';
}


}

/// @nodoc
abstract mixin class _$ExerciseClassificationCopyWith<$Res> implements $ExerciseClassificationCopyWith<$Res> {
  factory _$ExerciseClassificationCopyWith(_ExerciseClassification value, $Res Function(_ExerciseClassification) _then) = __$ExerciseClassificationCopyWithImpl;
@override @useResult
$Res call({
 String category, Set<String> bodyAreas, Set<String> equipment, Set<String> positions, Set<String> goals, Set<String> contexts
});




}
/// @nodoc
class __$ExerciseClassificationCopyWithImpl<$Res>
    implements _$ExerciseClassificationCopyWith<$Res> {
  __$ExerciseClassificationCopyWithImpl(this._self, this._then);

  final _ExerciseClassification _self;
  final $Res Function(_ExerciseClassification) _then;

/// Create a copy of ExerciseClassification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? bodyAreas = null,Object? equipment = null,Object? positions = null,Object? goals = null,Object? contexts = null,}) {
  return _then(_ExerciseClassification(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,bodyAreas: null == bodyAreas ? _self._bodyAreas : bodyAreas // ignore: cast_nullable_to_non_nullable
as Set<String>,equipment: null == equipment ? _self._equipment : equipment // ignore: cast_nullable_to_non_nullable
as Set<String>,positions: null == positions ? _self._positions : positions // ignore: cast_nullable_to_non_nullable
as Set<String>,goals: null == goals ? _self._goals : goals // ignore: cast_nullable_to_non_nullable
as Set<String>,contexts: null == contexts ? _self._contexts : contexts // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}


/// @nodoc
mixin _$ProviderExerciseMapping {

 String get providerKey; String get sourceExerciseId;
/// Create a copy of ProviderExerciseMapping
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderExerciseMappingCopyWith<ProviderExerciseMapping> get copyWith => _$ProviderExerciseMappingCopyWithImpl<ProviderExerciseMapping>(this as ProviderExerciseMapping, _$identity);

  /// Serializes this ProviderExerciseMapping to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderExerciseMapping&&(identical(other.providerKey, providerKey) || other.providerKey == providerKey)&&(identical(other.sourceExerciseId, sourceExerciseId) || other.sourceExerciseId == sourceExerciseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerKey,sourceExerciseId);

@override
String toString() {
  return 'ProviderExerciseMapping(providerKey: $providerKey, sourceExerciseId: $sourceExerciseId)';
}


}

/// @nodoc
abstract mixin class $ProviderExerciseMappingCopyWith<$Res>  {
  factory $ProviderExerciseMappingCopyWith(ProviderExerciseMapping value, $Res Function(ProviderExerciseMapping) _then) = _$ProviderExerciseMappingCopyWithImpl;
@useResult
$Res call({
 String providerKey, String sourceExerciseId
});




}
/// @nodoc
class _$ProviderExerciseMappingCopyWithImpl<$Res>
    implements $ProviderExerciseMappingCopyWith<$Res> {
  _$ProviderExerciseMappingCopyWithImpl(this._self, this._then);

  final ProviderExerciseMapping _self;
  final $Res Function(ProviderExerciseMapping) _then;

/// Create a copy of ProviderExerciseMapping
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? providerKey = null,Object? sourceExerciseId = null,}) {
  return _then(ProviderExerciseMapping(
providerKey: null == providerKey ? _self.providerKey : providerKey // ignore: cast_nullable_to_non_nullable
as String,sourceExerciseId: null == sourceExerciseId ? _self.sourceExerciseId : sourceExerciseId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderExerciseMapping].
extension ProviderExerciseMappingPatterns on ProviderExerciseMapping {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderExerciseMapping value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderExerciseMapping() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderExerciseMapping value)  $default,){
final _that = this;
switch (_that) {
case _ProviderExerciseMapping():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderExerciseMapping value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderExerciseMapping() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String providerKey,  String sourceExerciseId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderExerciseMapping() when $default != null:
return $default(_that.providerKey,_that.sourceExerciseId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String providerKey,  String sourceExerciseId)  $default,) {final _that = this;
switch (_that) {
case _ProviderExerciseMapping():
return $default(_that.providerKey,_that.sourceExerciseId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String providerKey,  String sourceExerciseId)?  $default,) {final _that = this;
switch (_that) {
case _ProviderExerciseMapping() when $default != null:
return $default(_that.providerKey,_that.sourceExerciseId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderExerciseMapping implements ProviderExerciseMapping {
  const _ProviderExerciseMapping({required this.providerKey, required this.sourceExerciseId});
  factory _ProviderExerciseMapping.fromJson(Map<String, dynamic> json) => _$ProviderExerciseMappingFromJson(json);

@override final  String providerKey;
@override final  String sourceExerciseId;

/// Create a copy of ProviderExerciseMapping
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderExerciseMappingCopyWith<_ProviderExerciseMapping> get copyWith => __$ProviderExerciseMappingCopyWithImpl<_ProviderExerciseMapping>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderExerciseMappingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderExerciseMapping&&(identical(other.providerKey, providerKey) || other.providerKey == providerKey)&&(identical(other.sourceExerciseId, sourceExerciseId) || other.sourceExerciseId == sourceExerciseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerKey,sourceExerciseId);

@override
String toString() {
  return 'ProviderExerciseMapping(providerKey: $providerKey, sourceExerciseId: $sourceExerciseId)';
}


}

/// @nodoc
abstract mixin class _$ProviderExerciseMappingCopyWith<$Res> implements $ProviderExerciseMappingCopyWith<$Res> {
  factory _$ProviderExerciseMappingCopyWith(_ProviderExerciseMapping value, $Res Function(_ProviderExerciseMapping) _then) = __$ProviderExerciseMappingCopyWithImpl;
@override @useResult
$Res call({
 String providerKey, String sourceExerciseId
});




}
/// @nodoc
class __$ProviderExerciseMappingCopyWithImpl<$Res>
    implements _$ProviderExerciseMappingCopyWith<$Res> {
  __$ProviderExerciseMappingCopyWithImpl(this._self, this._then);

  final _ProviderExerciseMapping _self;
  final $Res Function(_ProviderExerciseMapping) _then;

/// Create a copy of ProviderExerciseMapping
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providerKey = null,Object? sourceExerciseId = null,}) {
  return _then(_ProviderExerciseMapping(
providerKey: null == providerKey ? _self.providerKey : providerKey // ignore: cast_nullable_to_non_nullable
as String,sourceExerciseId: null == sourceExerciseId ? _self.sourceExerciseId : sourceExerciseId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MediaAsset {

 String get id; String get exerciseId; MediaType get type; String get mimeType; String get deliveryFileName; String get checksumSha256; ContentStatus get status; bool get isPreferred; String? get providerKey; String? get sourceExerciseId; String? get sourceFileName; String? get variant; int? get width; int? get height; int? get durationMs;
/// Create a copy of MediaAsset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaAssetCopyWith<MediaAsset> get copyWith => _$MediaAssetCopyWithImpl<MediaAsset>(this as MediaAsset, _$identity);

  /// Serializes this MediaAsset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.type, type) || other.type == type)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.deliveryFileName, deliveryFileName) || other.deliveryFileName == deliveryFileName)&&(identical(other.checksumSha256, checksumSha256) || other.checksumSha256 == checksumSha256)&&(identical(other.status, status) || other.status == status)&&(identical(other.isPreferred, isPreferred) || other.isPreferred == isPreferred)&&(identical(other.providerKey, providerKey) || other.providerKey == providerKey)&&(identical(other.sourceExerciseId, sourceExerciseId) || other.sourceExerciseId == sourceExerciseId)&&(identical(other.sourceFileName, sourceFileName) || other.sourceFileName == sourceFileName)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,type,mimeType,deliveryFileName,checksumSha256,status,isPreferred,providerKey,sourceExerciseId,sourceFileName,variant,width,height,durationMs);

@override
String toString() {
  return 'MediaAsset(id: $id, exerciseId: $exerciseId, type: $type, mimeType: $mimeType, deliveryFileName: $deliveryFileName, checksumSha256: $checksumSha256, status: $status, isPreferred: $isPreferred, providerKey: $providerKey, sourceExerciseId: $sourceExerciseId, sourceFileName: $sourceFileName, variant: $variant, width: $width, height: $height, durationMs: $durationMs)';
}


}

/// @nodoc
abstract mixin class $MediaAssetCopyWith<$Res>  {
  factory $MediaAssetCopyWith(MediaAsset value, $Res Function(MediaAsset) _then) = _$MediaAssetCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, MediaType type, String mimeType, String deliveryFileName, String checksumSha256, ContentStatus status, bool isPreferred, String? providerKey, String? sourceExerciseId, String? sourceFileName, String? variant, int? width, int? height, int? durationMs
});




}
/// @nodoc
class _$MediaAssetCopyWithImpl<$Res>
    implements $MediaAssetCopyWith<$Res> {
  _$MediaAssetCopyWithImpl(this._self, this._then);

  final MediaAsset _self;
  final $Res Function(MediaAsset) _then;

/// Create a copy of MediaAsset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? type = null,Object? mimeType = null,Object? deliveryFileName = null,Object? checksumSha256 = null,Object? status = null,Object? isPreferred = null,Object? providerKey = freezed,Object? sourceExerciseId = freezed,Object? sourceFileName = freezed,Object? variant = freezed,Object? width = freezed,Object? height = freezed,Object? durationMs = freezed,}) {
  return _then(MediaAsset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MediaType,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,deliveryFileName: null == deliveryFileName ? _self.deliveryFileName : deliveryFileName // ignore: cast_nullable_to_non_nullable
as String,checksumSha256: null == checksumSha256 ? _self.checksumSha256 : checksumSha256 // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,isPreferred: null == isPreferred ? _self.isPreferred : isPreferred // ignore: cast_nullable_to_non_nullable
as bool,providerKey: freezed == providerKey ? _self.providerKey : providerKey // ignore: cast_nullable_to_non_nullable
as String?,sourceExerciseId: freezed == sourceExerciseId ? _self.sourceExerciseId : sourceExerciseId // ignore: cast_nullable_to_non_nullable
as String?,sourceFileName: freezed == sourceFileName ? _self.sourceFileName : sourceFileName // ignore: cast_nullable_to_non_nullable
as String?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaAsset].
extension MediaAssetPatterns on MediaAsset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaAsset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaAsset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaAsset value)  $default,){
final _that = this;
switch (_that) {
case _MediaAsset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaAsset value)?  $default,){
final _that = this;
switch (_that) {
case _MediaAsset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  MediaType type,  String mimeType,  String deliveryFileName,  String checksumSha256,  ContentStatus status,  bool isPreferred,  String? providerKey,  String? sourceExerciseId,  String? sourceFileName,  String? variant,  int? width,  int? height,  int? durationMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaAsset() when $default != null:
return $default(_that.id,_that.exerciseId,_that.type,_that.mimeType,_that.deliveryFileName,_that.checksumSha256,_that.status,_that.isPreferred,_that.providerKey,_that.sourceExerciseId,_that.sourceFileName,_that.variant,_that.width,_that.height,_that.durationMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  MediaType type,  String mimeType,  String deliveryFileName,  String checksumSha256,  ContentStatus status,  bool isPreferred,  String? providerKey,  String? sourceExerciseId,  String? sourceFileName,  String? variant,  int? width,  int? height,  int? durationMs)  $default,) {final _that = this;
switch (_that) {
case _MediaAsset():
return $default(_that.id,_that.exerciseId,_that.type,_that.mimeType,_that.deliveryFileName,_that.checksumSha256,_that.status,_that.isPreferred,_that.providerKey,_that.sourceExerciseId,_that.sourceFileName,_that.variant,_that.width,_that.height,_that.durationMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  MediaType type,  String mimeType,  String deliveryFileName,  String checksumSha256,  ContentStatus status,  bool isPreferred,  String? providerKey,  String? sourceExerciseId,  String? sourceFileName,  String? variant,  int? width,  int? height,  int? durationMs)?  $default,) {final _that = this;
switch (_that) {
case _MediaAsset() when $default != null:
return $default(_that.id,_that.exerciseId,_that.type,_that.mimeType,_that.deliveryFileName,_that.checksumSha256,_that.status,_that.isPreferred,_that.providerKey,_that.sourceExerciseId,_that.sourceFileName,_that.variant,_that.width,_that.height,_that.durationMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaAsset implements MediaAsset {
  const _MediaAsset({required this.id, required this.exerciseId, required this.type, required this.mimeType, required this.deliveryFileName, required this.checksumSha256, required this.status, this.isPreferred = false, this.providerKey, this.sourceExerciseId, this.sourceFileName, this.variant, this.width, this.height, this.durationMs});
  factory _MediaAsset.fromJson(Map<String, dynamic> json) => _$MediaAssetFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  MediaType type;
@override final  String mimeType;
@override final  String deliveryFileName;
@override final  String checksumSha256;
@override final  ContentStatus status;
@override@JsonKey() final  bool isPreferred;
@override final  String? providerKey;
@override final  String? sourceExerciseId;
@override final  String? sourceFileName;
@override final  String? variant;
@override final  int? width;
@override final  int? height;
@override final  int? durationMs;

/// Create a copy of MediaAsset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaAssetCopyWith<_MediaAsset> get copyWith => __$MediaAssetCopyWithImpl<_MediaAsset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaAssetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.type, type) || other.type == type)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.deliveryFileName, deliveryFileName) || other.deliveryFileName == deliveryFileName)&&(identical(other.checksumSha256, checksumSha256) || other.checksumSha256 == checksumSha256)&&(identical(other.status, status) || other.status == status)&&(identical(other.isPreferred, isPreferred) || other.isPreferred == isPreferred)&&(identical(other.providerKey, providerKey) || other.providerKey == providerKey)&&(identical(other.sourceExerciseId, sourceExerciseId) || other.sourceExerciseId == sourceExerciseId)&&(identical(other.sourceFileName, sourceFileName) || other.sourceFileName == sourceFileName)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,type,mimeType,deliveryFileName,checksumSha256,status,isPreferred,providerKey,sourceExerciseId,sourceFileName,variant,width,height,durationMs);

@override
String toString() {
  return 'MediaAsset(id: $id, exerciseId: $exerciseId, type: $type, mimeType: $mimeType, deliveryFileName: $deliveryFileName, checksumSha256: $checksumSha256, status: $status, isPreferred: $isPreferred, providerKey: $providerKey, sourceExerciseId: $sourceExerciseId, sourceFileName: $sourceFileName, variant: $variant, width: $width, height: $height, durationMs: $durationMs)';
}


}

/// @nodoc
abstract mixin class _$MediaAssetCopyWith<$Res> implements $MediaAssetCopyWith<$Res> {
  factory _$MediaAssetCopyWith(_MediaAsset value, $Res Function(_MediaAsset) _then) = __$MediaAssetCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, MediaType type, String mimeType, String deliveryFileName, String checksumSha256, ContentStatus status, bool isPreferred, String? providerKey, String? sourceExerciseId, String? sourceFileName, String? variant, int? width, int? height, int? durationMs
});




}
/// @nodoc
class __$MediaAssetCopyWithImpl<$Res>
    implements _$MediaAssetCopyWith<$Res> {
  __$MediaAssetCopyWithImpl(this._self, this._then);

  final _MediaAsset _self;
  final $Res Function(_MediaAsset) _then;

/// Create a copy of MediaAsset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? type = null,Object? mimeType = null,Object? deliveryFileName = null,Object? checksumSha256 = null,Object? status = null,Object? isPreferred = null,Object? providerKey = freezed,Object? sourceExerciseId = freezed,Object? sourceFileName = freezed,Object? variant = freezed,Object? width = freezed,Object? height = freezed,Object? durationMs = freezed,}) {
  return _then(_MediaAsset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MediaType,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,deliveryFileName: null == deliveryFileName ? _self.deliveryFileName : deliveryFileName // ignore: cast_nullable_to_non_nullable
as String,checksumSha256: null == checksumSha256 ? _self.checksumSha256 : checksumSha256 // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,isPreferred: null == isPreferred ? _self.isPreferred : isPreferred // ignore: cast_nullable_to_non_nullable
as bool,providerKey: freezed == providerKey ? _self.providerKey : providerKey // ignore: cast_nullable_to_non_nullable
as String?,sourceExerciseId: freezed == sourceExerciseId ? _self.sourceExerciseId : sourceExerciseId // ignore: cast_nullable_to_non_nullable
as String?,sourceFileName: freezed == sourceFileName ? _self.sourceFileName : sourceFileName // ignore: cast_nullable_to_non_nullable
as String?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$Routine {

 String get id; ContentStatus get status; AccessTier get accessTier; DifficultyLevel get difficulty; int get estimatedDurationSeconds; int get version; Map<String, LocalizedRoutineContent> get translations; RoutineClassification get classification; List<RoutineStep> get steps;
/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineCopyWith<Routine> get copyWith => _$RoutineCopyWithImpl<Routine>(this as Routine, _$identity);

  /// Serializes this Routine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Routine&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.accessTier, accessTier) || other.accessTier == accessTier)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedDurationSeconds, estimatedDurationSeconds) || other.estimatedDurationSeconds == estimatedDurationSeconds)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.translations, translations)&&(identical(other.classification, classification) || other.classification == classification)&&const DeepCollectionEquality().equals(other.steps, steps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,accessTier,difficulty,estimatedDurationSeconds,version,const DeepCollectionEquality().hash(translations),classification,const DeepCollectionEquality().hash(steps));

@override
String toString() {
  return 'Routine(id: $id, status: $status, accessTier: $accessTier, difficulty: $difficulty, estimatedDurationSeconds: $estimatedDurationSeconds, version: $version, translations: $translations, classification: $classification, steps: $steps)';
}


}

/// @nodoc
abstract mixin class $RoutineCopyWith<$Res>  {
  factory $RoutineCopyWith(Routine value, $Res Function(Routine) _then) = _$RoutineCopyWithImpl;
@useResult
$Res call({
 String id, ContentStatus status, AccessTier accessTier, DifficultyLevel difficulty, int estimatedDurationSeconds, int version, Map<String, LocalizedRoutineContent> translations, RoutineClassification classification, List<RoutineStep> steps
});


$RoutineClassificationCopyWith<$Res> get classification;

}
/// @nodoc
class _$RoutineCopyWithImpl<$Res>
    implements $RoutineCopyWith<$Res> {
  _$RoutineCopyWithImpl(this._self, this._then);

  final Routine _self;
  final $Res Function(Routine) _then;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? accessTier = null,Object? difficulty = null,Object? estimatedDurationSeconds = null,Object? version = null,Object? translations = null,Object? classification = null,Object? steps = null,}) {
  return _then(Routine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,accessTier: null == accessTier ? _self.accessTier : accessTier // ignore: cast_nullable_to_non_nullable
as AccessTier,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as DifficultyLevel,estimatedDurationSeconds: null == estimatedDurationSeconds ? _self.estimatedDurationSeconds : estimatedDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as Map<String, LocalizedRoutineContent>,classification: null == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as RoutineClassification,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<RoutineStep>,
  ));
}
/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutineClassificationCopyWith<$Res> get classification {
  
  return $RoutineClassificationCopyWith<$Res>(_self.classification, (value) {
    return _then(_self.copyWith(classification: value));
  });
}
}


/// Adds pattern-matching-related methods to [Routine].
extension RoutinePatterns on Routine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Routine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Routine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Routine value)  $default,){
final _that = this;
switch (_that) {
case _Routine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Routine value)?  $default,){
final _that = this;
switch (_that) {
case _Routine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ContentStatus status,  AccessTier accessTier,  DifficultyLevel difficulty,  int estimatedDurationSeconds,  int version,  Map<String, LocalizedRoutineContent> translations,  RoutineClassification classification,  List<RoutineStep> steps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Routine() when $default != null:
return $default(_that.id,_that.status,_that.accessTier,_that.difficulty,_that.estimatedDurationSeconds,_that.version,_that.translations,_that.classification,_that.steps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ContentStatus status,  AccessTier accessTier,  DifficultyLevel difficulty,  int estimatedDurationSeconds,  int version,  Map<String, LocalizedRoutineContent> translations,  RoutineClassification classification,  List<RoutineStep> steps)  $default,) {final _that = this;
switch (_that) {
case _Routine():
return $default(_that.id,_that.status,_that.accessTier,_that.difficulty,_that.estimatedDurationSeconds,_that.version,_that.translations,_that.classification,_that.steps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ContentStatus status,  AccessTier accessTier,  DifficultyLevel difficulty,  int estimatedDurationSeconds,  int version,  Map<String, LocalizedRoutineContent> translations,  RoutineClassification classification,  List<RoutineStep> steps)?  $default,) {final _that = this;
switch (_that) {
case _Routine() when $default != null:
return $default(_that.id,_that.status,_that.accessTier,_that.difficulty,_that.estimatedDurationSeconds,_that.version,_that.translations,_that.classification,_that.steps);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Routine implements Routine {
  const _Routine({required this.id, required this.status, required this.accessTier, required this.difficulty, required this.estimatedDurationSeconds, required this.version, required  Map<String, LocalizedRoutineContent> translations, required this.classification, required  List<RoutineStep> steps}): _translations = translations,_steps = steps;
  factory _Routine.fromJson(Map<String, dynamic> json) => _$RoutineFromJson(json);

@override final  String id;
@override final  ContentStatus status;
@override final  AccessTier accessTier;
@override final  DifficultyLevel difficulty;
@override final  int estimatedDurationSeconds;
@override final  int version;
 final  Map<String, LocalizedRoutineContent> _translations;
@override Map<String, LocalizedRoutineContent> get translations {
  if (_translations is EqualUnmodifiableMapView) return _translations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_translations);
}

@override final  RoutineClassification classification;
 final  List<RoutineStep> _steps;
@override List<RoutineStep> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}


/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineCopyWith<_Routine> get copyWith => __$RoutineCopyWithImpl<_Routine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Routine&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.accessTier, accessTier) || other.accessTier == accessTier)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedDurationSeconds, estimatedDurationSeconds) || other.estimatedDurationSeconds == estimatedDurationSeconds)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._translations, _translations)&&(identical(other.classification, classification) || other.classification == classification)&&const DeepCollectionEquality().equals(other._steps, _steps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,accessTier,difficulty,estimatedDurationSeconds,version,const DeepCollectionEquality().hash(_translations),classification,const DeepCollectionEquality().hash(_steps));

@override
String toString() {
  return 'Routine(id: $id, status: $status, accessTier: $accessTier, difficulty: $difficulty, estimatedDurationSeconds: $estimatedDurationSeconds, version: $version, translations: $translations, classification: $classification, steps: $steps)';
}


}

/// @nodoc
abstract mixin class _$RoutineCopyWith<$Res> implements $RoutineCopyWith<$Res> {
  factory _$RoutineCopyWith(_Routine value, $Res Function(_Routine) _then) = __$RoutineCopyWithImpl;
@override @useResult
$Res call({
 String id, ContentStatus status, AccessTier accessTier, DifficultyLevel difficulty, int estimatedDurationSeconds, int version, Map<String, LocalizedRoutineContent> translations, RoutineClassification classification, List<RoutineStep> steps
});


@override $RoutineClassificationCopyWith<$Res> get classification;

}
/// @nodoc
class __$RoutineCopyWithImpl<$Res>
    implements _$RoutineCopyWith<$Res> {
  __$RoutineCopyWithImpl(this._self, this._then);

  final _Routine _self;
  final $Res Function(_Routine) _then;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? accessTier = null,Object? difficulty = null,Object? estimatedDurationSeconds = null,Object? version = null,Object? translations = null,Object? classification = null,Object? steps = null,}) {
  return _then(_Routine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContentStatus,accessTier: null == accessTier ? _self.accessTier : accessTier // ignore: cast_nullable_to_non_nullable
as AccessTier,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as DifficultyLevel,estimatedDurationSeconds: null == estimatedDurationSeconds ? _self.estimatedDurationSeconds : estimatedDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as Map<String, LocalizedRoutineContent>,classification: null == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as RoutineClassification,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<RoutineStep>,
  ));
}

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutineClassificationCopyWith<$Res> get classification {
  
  return $RoutineClassificationCopyWith<$Res>(_self.classification, (value) {
    return _then(_self.copyWith(classification: value));
  });
}
}


/// @nodoc
mixin _$LocalizedRoutineContent {

 String get name; String get summary;
/// Create a copy of LocalizedRoutineContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalizedRoutineContentCopyWith<LocalizedRoutineContent> get copyWith => _$LocalizedRoutineContentCopyWithImpl<LocalizedRoutineContent>(this as LocalizedRoutineContent, _$identity);

  /// Serializes this LocalizedRoutineContent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalizedRoutineContent&&(identical(other.name, name) || other.name == name)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,summary);

@override
String toString() {
  return 'LocalizedRoutineContent(name: $name, summary: $summary)';
}


}

/// @nodoc
abstract mixin class $LocalizedRoutineContentCopyWith<$Res>  {
  factory $LocalizedRoutineContentCopyWith(LocalizedRoutineContent value, $Res Function(LocalizedRoutineContent) _then) = _$LocalizedRoutineContentCopyWithImpl;
@useResult
$Res call({
 String name, String summary
});




}
/// @nodoc
class _$LocalizedRoutineContentCopyWithImpl<$Res>
    implements $LocalizedRoutineContentCopyWith<$Res> {
  _$LocalizedRoutineContentCopyWithImpl(this._self, this._then);

  final LocalizedRoutineContent _self;
  final $Res Function(LocalizedRoutineContent) _then;

/// Create a copy of LocalizedRoutineContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? summary = null,}) {
  return _then(LocalizedRoutineContent(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalizedRoutineContent].
extension LocalizedRoutineContentPatterns on LocalizedRoutineContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalizedRoutineContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalizedRoutineContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalizedRoutineContent value)  $default,){
final _that = this;
switch (_that) {
case _LocalizedRoutineContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalizedRoutineContent value)?  $default,){
final _that = this;
switch (_that) {
case _LocalizedRoutineContent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String summary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalizedRoutineContent() when $default != null:
return $default(_that.name,_that.summary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String summary)  $default,) {final _that = this;
switch (_that) {
case _LocalizedRoutineContent():
return $default(_that.name,_that.summary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String summary)?  $default,) {final _that = this;
switch (_that) {
case _LocalizedRoutineContent() when $default != null:
return $default(_that.name,_that.summary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalizedRoutineContent implements LocalizedRoutineContent {
  const _LocalizedRoutineContent({required this.name, required this.summary});
  factory _LocalizedRoutineContent.fromJson(Map<String, dynamic> json) => _$LocalizedRoutineContentFromJson(json);

@override final  String name;
@override final  String summary;

/// Create a copy of LocalizedRoutineContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalizedRoutineContentCopyWith<_LocalizedRoutineContent> get copyWith => __$LocalizedRoutineContentCopyWithImpl<_LocalizedRoutineContent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalizedRoutineContentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalizedRoutineContent&&(identical(other.name, name) || other.name == name)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,summary);

@override
String toString() {
  return 'LocalizedRoutineContent(name: $name, summary: $summary)';
}


}

/// @nodoc
abstract mixin class _$LocalizedRoutineContentCopyWith<$Res> implements $LocalizedRoutineContentCopyWith<$Res> {
  factory _$LocalizedRoutineContentCopyWith(_LocalizedRoutineContent value, $Res Function(_LocalizedRoutineContent) _then) = __$LocalizedRoutineContentCopyWithImpl;
@override @useResult
$Res call({
 String name, String summary
});




}
/// @nodoc
class __$LocalizedRoutineContentCopyWithImpl<$Res>
    implements _$LocalizedRoutineContentCopyWith<$Res> {
  __$LocalizedRoutineContentCopyWithImpl(this._self, this._then);

  final _LocalizedRoutineContent _self;
  final $Res Function(_LocalizedRoutineContent) _then;

/// Create a copy of LocalizedRoutineContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? summary = null,}) {
  return _then(_LocalizedRoutineContent(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RoutineClassification {

 Set<String> get bodyAreas; Set<String> get goals; Set<String> get positions; Set<String> get equipment; Set<String> get contexts;
/// Create a copy of RoutineClassification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineClassificationCopyWith<RoutineClassification> get copyWith => _$RoutineClassificationCopyWithImpl<RoutineClassification>(this as RoutineClassification, _$identity);

  /// Serializes this RoutineClassification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineClassification&&const DeepCollectionEquality().equals(other.bodyAreas, bodyAreas)&&const DeepCollectionEquality().equals(other.goals, goals)&&const DeepCollectionEquality().equals(other.positions, positions)&&const DeepCollectionEquality().equals(other.equipment, equipment)&&const DeepCollectionEquality().equals(other.contexts, contexts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bodyAreas),const DeepCollectionEquality().hash(goals),const DeepCollectionEquality().hash(positions),const DeepCollectionEquality().hash(equipment),const DeepCollectionEquality().hash(contexts));

@override
String toString() {
  return 'RoutineClassification(bodyAreas: $bodyAreas, goals: $goals, positions: $positions, equipment: $equipment, contexts: $contexts)';
}


}

/// @nodoc
abstract mixin class $RoutineClassificationCopyWith<$Res>  {
  factory $RoutineClassificationCopyWith(RoutineClassification value, $Res Function(RoutineClassification) _then) = _$RoutineClassificationCopyWithImpl;
@useResult
$Res call({
 Set<String> bodyAreas, Set<String> goals, Set<String> positions, Set<String> equipment, Set<String> contexts
});




}
/// @nodoc
class _$RoutineClassificationCopyWithImpl<$Res>
    implements $RoutineClassificationCopyWith<$Res> {
  _$RoutineClassificationCopyWithImpl(this._self, this._then);

  final RoutineClassification _self;
  final $Res Function(RoutineClassification) _then;

/// Create a copy of RoutineClassification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bodyAreas = null,Object? goals = null,Object? positions = null,Object? equipment = null,Object? contexts = null,}) {
  return _then(RoutineClassification(
bodyAreas: null == bodyAreas ? _self.bodyAreas : bodyAreas // ignore: cast_nullable_to_non_nullable
as Set<String>,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as Set<String>,positions: null == positions ? _self.positions : positions // ignore: cast_nullable_to_non_nullable
as Set<String>,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as Set<String>,contexts: null == contexts ? _self.contexts : contexts // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineClassification].
extension RoutineClassificationPatterns on RoutineClassification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineClassification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineClassification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineClassification value)  $default,){
final _that = this;
switch (_that) {
case _RoutineClassification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineClassification value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineClassification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<String> bodyAreas,  Set<String> goals,  Set<String> positions,  Set<String> equipment,  Set<String> contexts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineClassification() when $default != null:
return $default(_that.bodyAreas,_that.goals,_that.positions,_that.equipment,_that.contexts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<String> bodyAreas,  Set<String> goals,  Set<String> positions,  Set<String> equipment,  Set<String> contexts)  $default,) {final _that = this;
switch (_that) {
case _RoutineClassification():
return $default(_that.bodyAreas,_that.goals,_that.positions,_that.equipment,_that.contexts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<String> bodyAreas,  Set<String> goals,  Set<String> positions,  Set<String> equipment,  Set<String> contexts)?  $default,) {final _that = this;
switch (_that) {
case _RoutineClassification() when $default != null:
return $default(_that.bodyAreas,_that.goals,_that.positions,_that.equipment,_that.contexts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineClassification implements RoutineClassification {
  const _RoutineClassification({required  Set<String> bodyAreas, required  Set<String> goals, required  Set<String> positions,  Set<String> equipment = const <String>{},  Set<String> contexts = const <String>{}}): _bodyAreas = bodyAreas,_goals = goals,_positions = positions,_equipment = equipment,_contexts = contexts;
  factory _RoutineClassification.fromJson(Map<String, dynamic> json) => _$RoutineClassificationFromJson(json);

 final  Set<String> _bodyAreas;
@override Set<String> get bodyAreas {
  if (_bodyAreas is EqualUnmodifiableSetView) return _bodyAreas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_bodyAreas);
}

 final  Set<String> _goals;
@override Set<String> get goals {
  if (_goals is EqualUnmodifiableSetView) return _goals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_goals);
}

 final  Set<String> _positions;
@override Set<String> get positions {
  if (_positions is EqualUnmodifiableSetView) return _positions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_positions);
}

 final  Set<String> _equipment;
@override@JsonKey() Set<String> get equipment {
  if (_equipment is EqualUnmodifiableSetView) return _equipment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_equipment);
}

 final  Set<String> _contexts;
@override@JsonKey() Set<String> get contexts {
  if (_contexts is EqualUnmodifiableSetView) return _contexts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_contexts);
}


/// Create a copy of RoutineClassification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineClassificationCopyWith<_RoutineClassification> get copyWith => __$RoutineClassificationCopyWithImpl<_RoutineClassification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineClassificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineClassification&&const DeepCollectionEquality().equals(other._bodyAreas, _bodyAreas)&&const DeepCollectionEquality().equals(other._goals, _goals)&&const DeepCollectionEquality().equals(other._positions, _positions)&&const DeepCollectionEquality().equals(other._equipment, _equipment)&&const DeepCollectionEquality().equals(other._contexts, _contexts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bodyAreas),const DeepCollectionEquality().hash(_goals),const DeepCollectionEquality().hash(_positions),const DeepCollectionEquality().hash(_equipment),const DeepCollectionEquality().hash(_contexts));

@override
String toString() {
  return 'RoutineClassification(bodyAreas: $bodyAreas, goals: $goals, positions: $positions, equipment: $equipment, contexts: $contexts)';
}


}

/// @nodoc
abstract mixin class _$RoutineClassificationCopyWith<$Res> implements $RoutineClassificationCopyWith<$Res> {
  factory _$RoutineClassificationCopyWith(_RoutineClassification value, $Res Function(_RoutineClassification) _then) = __$RoutineClassificationCopyWithImpl;
@override @useResult
$Res call({
 Set<String> bodyAreas, Set<String> goals, Set<String> positions, Set<String> equipment, Set<String> contexts
});




}
/// @nodoc
class __$RoutineClassificationCopyWithImpl<$Res>
    implements _$RoutineClassificationCopyWith<$Res> {
  __$RoutineClassificationCopyWithImpl(this._self, this._then);

  final _RoutineClassification _self;
  final $Res Function(_RoutineClassification) _then;

/// Create a copy of RoutineClassification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bodyAreas = null,Object? goals = null,Object? positions = null,Object? equipment = null,Object? contexts = null,}) {
  return _then(_RoutineClassification(
bodyAreas: null == bodyAreas ? _self._bodyAreas : bodyAreas // ignore: cast_nullable_to_non_nullable
as Set<String>,goals: null == goals ? _self._goals : goals // ignore: cast_nullable_to_non_nullable
as Set<String>,positions: null == positions ? _self._positions : positions // ignore: cast_nullable_to_non_nullable
as Set<String>,equipment: null == equipment ? _self._equipment : equipment // ignore: cast_nullable_to_non_nullable
as Set<String>,contexts: null == contexts ? _self._contexts : contexts // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}


/// @nodoc
mixin _$RoutineStep {

 String get id; String get exerciseId; int get position; int? get durationSeconds; int? get repetitionCount; int get restAfterSeconds; bool get isOptional; String? get sideMode;
/// Create a copy of RoutineStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineStepCopyWith<RoutineStep> get copyWith => _$RoutineStepCopyWithImpl<RoutineStep>(this as RoutineStep, _$identity);

  /// Serializes this RoutineStep to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineStep&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.position, position) || other.position == position)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.repetitionCount, repetitionCount) || other.repetitionCount == repetitionCount)&&(identical(other.restAfterSeconds, restAfterSeconds) || other.restAfterSeconds == restAfterSeconds)&&(identical(other.isOptional, isOptional) || other.isOptional == isOptional)&&(identical(other.sideMode, sideMode) || other.sideMode == sideMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,position,durationSeconds,repetitionCount,restAfterSeconds,isOptional,sideMode);

@override
String toString() {
  return 'RoutineStep(id: $id, exerciseId: $exerciseId, position: $position, durationSeconds: $durationSeconds, repetitionCount: $repetitionCount, restAfterSeconds: $restAfterSeconds, isOptional: $isOptional, sideMode: $sideMode)';
}


}

/// @nodoc
abstract mixin class $RoutineStepCopyWith<$Res>  {
  factory $RoutineStepCopyWith(RoutineStep value, $Res Function(RoutineStep) _then) = _$RoutineStepCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, int position, int? durationSeconds, int? repetitionCount, int restAfterSeconds, bool isOptional, String? sideMode
});




}
/// @nodoc
class _$RoutineStepCopyWithImpl<$Res>
    implements $RoutineStepCopyWith<$Res> {
  _$RoutineStepCopyWithImpl(this._self, this._then);

  final RoutineStep _self;
  final $Res Function(RoutineStep) _then;

/// Create a copy of RoutineStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? position = null,Object? durationSeconds = freezed,Object? repetitionCount = freezed,Object? restAfterSeconds = null,Object? isOptional = null,Object? sideMode = freezed,}) {
  return _then(RoutineStep(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,repetitionCount: freezed == repetitionCount ? _self.repetitionCount : repetitionCount // ignore: cast_nullable_to_non_nullable
as int?,restAfterSeconds: null == restAfterSeconds ? _self.restAfterSeconds : restAfterSeconds // ignore: cast_nullable_to_non_nullable
as int,isOptional: null == isOptional ? _self.isOptional : isOptional // ignore: cast_nullable_to_non_nullable
as bool,sideMode: freezed == sideMode ? _self.sideMode : sideMode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineStep].
extension RoutineStepPatterns on RoutineStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineStep value)  $default,){
final _that = this;
switch (_that) {
case _RoutineStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineStep value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int position,  int? durationSeconds,  int? repetitionCount,  int restAfterSeconds,  bool isOptional,  String? sideMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineStep() when $default != null:
return $default(_that.id,_that.exerciseId,_that.position,_that.durationSeconds,_that.repetitionCount,_that.restAfterSeconds,_that.isOptional,_that.sideMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int position,  int? durationSeconds,  int? repetitionCount,  int restAfterSeconds,  bool isOptional,  String? sideMode)  $default,) {final _that = this;
switch (_that) {
case _RoutineStep():
return $default(_that.id,_that.exerciseId,_that.position,_that.durationSeconds,_that.repetitionCount,_that.restAfterSeconds,_that.isOptional,_that.sideMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  int position,  int? durationSeconds,  int? repetitionCount,  int restAfterSeconds,  bool isOptional,  String? sideMode)?  $default,) {final _that = this;
switch (_that) {
case _RoutineStep() when $default != null:
return $default(_that.id,_that.exerciseId,_that.position,_that.durationSeconds,_that.repetitionCount,_that.restAfterSeconds,_that.isOptional,_that.sideMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineStep implements RoutineStep {
  const _RoutineStep({required this.id, required this.exerciseId, required this.position, this.durationSeconds, this.repetitionCount, this.restAfterSeconds = 0, this.isOptional = false, this.sideMode});
  factory _RoutineStep.fromJson(Map<String, dynamic> json) => _$RoutineStepFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  int position;
@override final  int? durationSeconds;
@override final  int? repetitionCount;
@override@JsonKey() final  int restAfterSeconds;
@override@JsonKey() final  bool isOptional;
@override final  String? sideMode;

/// Create a copy of RoutineStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineStepCopyWith<_RoutineStep> get copyWith => __$RoutineStepCopyWithImpl<_RoutineStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineStep&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.position, position) || other.position == position)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.repetitionCount, repetitionCount) || other.repetitionCount == repetitionCount)&&(identical(other.restAfterSeconds, restAfterSeconds) || other.restAfterSeconds == restAfterSeconds)&&(identical(other.isOptional, isOptional) || other.isOptional == isOptional)&&(identical(other.sideMode, sideMode) || other.sideMode == sideMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,position,durationSeconds,repetitionCount,restAfterSeconds,isOptional,sideMode);

@override
String toString() {
  return 'RoutineStep(id: $id, exerciseId: $exerciseId, position: $position, durationSeconds: $durationSeconds, repetitionCount: $repetitionCount, restAfterSeconds: $restAfterSeconds, isOptional: $isOptional, sideMode: $sideMode)';
}


}

/// @nodoc
abstract mixin class _$RoutineStepCopyWith<$Res> implements $RoutineStepCopyWith<$Res> {
  factory _$RoutineStepCopyWith(_RoutineStep value, $Res Function(_RoutineStep) _then) = __$RoutineStepCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, int position, int? durationSeconds, int? repetitionCount, int restAfterSeconds, bool isOptional, String? sideMode
});




}
/// @nodoc
class __$RoutineStepCopyWithImpl<$Res>
    implements _$RoutineStepCopyWith<$Res> {
  __$RoutineStepCopyWithImpl(this._self, this._then);

  final _RoutineStep _self;
  final $Res Function(_RoutineStep) _then;

/// Create a copy of RoutineStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? position = null,Object? durationSeconds = freezed,Object? repetitionCount = freezed,Object? restAfterSeconds = null,Object? isOptional = null,Object? sideMode = freezed,}) {
  return _then(_RoutineStep(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,repetitionCount: freezed == repetitionCount ? _self.repetitionCount : repetitionCount // ignore: cast_nullable_to_non_nullable
as int?,restAfterSeconds: null == restAfterSeconds ? _self.restAfterSeconds : restAfterSeconds // ignore: cast_nullable_to_non_nullable
as int,isOptional: null == isOptional ? _self.isOptional : isOptional // ignore: cast_nullable_to_non_nullable
as bool,sideMode: freezed == sideMode ? _self.sideMode : sideMode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
