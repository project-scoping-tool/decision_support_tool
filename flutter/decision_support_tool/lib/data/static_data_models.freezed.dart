// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'static_data_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StaticData {

 List<(String, AssessmentInfo)> get assessmentInfoPairsSorted;/// Maps IDs to AssessmentInfo objects.
 Map<String, AssessmentInfo> get assessmentInfoMap;/// Maps IDs to QuestionInfo objects.
 Map<String, QuestionInfo> get questionInfoMap;/// Maps IDs to RecommendationsInfo objects.
 Map<String, RecommendationsInfo> get recommendationsInfoMap;
/// Create a copy of StaticData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaticDataCopyWith<StaticData> get copyWith => _$StaticDataCopyWithImpl<StaticData>(this as StaticData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaticData&&const DeepCollectionEquality().equals(other.assessmentInfoPairsSorted, assessmentInfoPairsSorted)&&const DeepCollectionEquality().equals(other.assessmentInfoMap, assessmentInfoMap)&&const DeepCollectionEquality().equals(other.questionInfoMap, questionInfoMap)&&const DeepCollectionEquality().equals(other.recommendationsInfoMap, recommendationsInfoMap));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(assessmentInfoPairsSorted),const DeepCollectionEquality().hash(assessmentInfoMap),const DeepCollectionEquality().hash(questionInfoMap),const DeepCollectionEquality().hash(recommendationsInfoMap));

@override
String toString() {
  return 'StaticData(assessmentInfoPairsSorted: $assessmentInfoPairsSorted, assessmentInfoMap: $assessmentInfoMap, questionInfoMap: $questionInfoMap, recommendationsInfoMap: $recommendationsInfoMap)';
}


}

/// @nodoc
abstract mixin class $StaticDataCopyWith<$Res>  {
  factory $StaticDataCopyWith(StaticData value, $Res Function(StaticData) _then) = _$StaticDataCopyWithImpl;
@useResult
$Res call({
 Map<String, AssessmentInfo> assessmentInfoMap, Map<String, QuestionInfo> questionInfoMap, Map<String, RecommendationsInfo> recommendationsInfoMap
});




}
/// @nodoc
class _$StaticDataCopyWithImpl<$Res>
    implements $StaticDataCopyWith<$Res> {
  _$StaticDataCopyWithImpl(this._self, this._then);

  final StaticData _self;
  final $Res Function(StaticData) _then;

/// Create a copy of StaticData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? assessmentInfoMap = null,Object? questionInfoMap = null,Object? recommendationsInfoMap = null,}) {
  return _then(_self.copyWith(
assessmentInfoMap: null == assessmentInfoMap ? _self.assessmentInfoMap : assessmentInfoMap // ignore: cast_nullable_to_non_nullable
as Map<String, AssessmentInfo>,questionInfoMap: null == questionInfoMap ? _self.questionInfoMap : questionInfoMap // ignore: cast_nullable_to_non_nullable
as Map<String, QuestionInfo>,recommendationsInfoMap: null == recommendationsInfoMap ? _self.recommendationsInfoMap : recommendationsInfoMap // ignore: cast_nullable_to_non_nullable
as Map<String, RecommendationsInfo>,
  ));
}

}


/// Adds pattern-matching-related methods to [StaticData].
extension StaticDataPatterns on StaticData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaticData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaticData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaticData value)  $default,){
final _that = this;
switch (_that) {
case _StaticData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaticData value)?  $default,){
final _that = this;
switch (_that) {
case _StaticData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, AssessmentInfo> assessmentInfoMap,  Map<String, QuestionInfo> questionInfoMap,  Map<String, RecommendationsInfo> recommendationsInfoMap)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaticData() when $default != null:
return $default(_that.assessmentInfoMap,_that.questionInfoMap,_that.recommendationsInfoMap);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, AssessmentInfo> assessmentInfoMap,  Map<String, QuestionInfo> questionInfoMap,  Map<String, RecommendationsInfo> recommendationsInfoMap)  $default,) {final _that = this;
switch (_that) {
case _StaticData():
return $default(_that.assessmentInfoMap,_that.questionInfoMap,_that.recommendationsInfoMap);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, AssessmentInfo> assessmentInfoMap,  Map<String, QuestionInfo> questionInfoMap,  Map<String, RecommendationsInfo> recommendationsInfoMap)?  $default,) {final _that = this;
switch (_that) {
case _StaticData() when $default != null:
return $default(_that.assessmentInfoMap,_that.questionInfoMap,_that.recommendationsInfoMap);case _:
  return null;

}
}

}

/// @nodoc


class _StaticData extends StaticData {
   _StaticData({required final  Map<String, AssessmentInfo> assessmentInfoMap, required final  Map<String, QuestionInfo> questionInfoMap, required final  Map<String, RecommendationsInfo> recommendationsInfoMap}): _assessmentInfoMap = assessmentInfoMap,_questionInfoMap = questionInfoMap,_recommendationsInfoMap = recommendationsInfoMap,super._();
  

/// Maps IDs to AssessmentInfo objects.
 final  Map<String, AssessmentInfo> _assessmentInfoMap;
/// Maps IDs to AssessmentInfo objects.
@override Map<String, AssessmentInfo> get assessmentInfoMap {
  if (_assessmentInfoMap is EqualUnmodifiableMapView) return _assessmentInfoMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_assessmentInfoMap);
}

/// Maps IDs to QuestionInfo objects.
 final  Map<String, QuestionInfo> _questionInfoMap;
/// Maps IDs to QuestionInfo objects.
@override Map<String, QuestionInfo> get questionInfoMap {
  if (_questionInfoMap is EqualUnmodifiableMapView) return _questionInfoMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_questionInfoMap);
}

/// Maps IDs to RecommendationsInfo objects.
 final  Map<String, RecommendationsInfo> _recommendationsInfoMap;
/// Maps IDs to RecommendationsInfo objects.
@override Map<String, RecommendationsInfo> get recommendationsInfoMap {
  if (_recommendationsInfoMap is EqualUnmodifiableMapView) return _recommendationsInfoMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_recommendationsInfoMap);
}


/// Create a copy of StaticData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaticDataCopyWith<_StaticData> get copyWith => __$StaticDataCopyWithImpl<_StaticData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaticData&&const DeepCollectionEquality().equals(other._assessmentInfoMap, _assessmentInfoMap)&&const DeepCollectionEquality().equals(other._questionInfoMap, _questionInfoMap)&&const DeepCollectionEquality().equals(other._recommendationsInfoMap, _recommendationsInfoMap));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_assessmentInfoMap),const DeepCollectionEquality().hash(_questionInfoMap),const DeepCollectionEquality().hash(_recommendationsInfoMap));

@override
String toString() {
  return 'StaticData(assessmentInfoMap: $assessmentInfoMap, questionInfoMap: $questionInfoMap, recommendationsInfoMap: $recommendationsInfoMap)';
}


}

/// @nodoc
abstract mixin class _$StaticDataCopyWith<$Res> implements $StaticDataCopyWith<$Res> {
  factory _$StaticDataCopyWith(_StaticData value, $Res Function(_StaticData) _then) = __$StaticDataCopyWithImpl;
@override @useResult
$Res call({
 Map<String, AssessmentInfo> assessmentInfoMap, Map<String, QuestionInfo> questionInfoMap, Map<String, RecommendationsInfo> recommendationsInfoMap
});




}
/// @nodoc
class __$StaticDataCopyWithImpl<$Res>
    implements _$StaticDataCopyWith<$Res> {
  __$StaticDataCopyWithImpl(this._self, this._then);

  final _StaticData _self;
  final $Res Function(_StaticData) _then;

/// Create a copy of StaticData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? assessmentInfoMap = null,Object? questionInfoMap = null,Object? recommendationsInfoMap = null,}) {
  return _then(_StaticData(
assessmentInfoMap: null == assessmentInfoMap ? _self._assessmentInfoMap : assessmentInfoMap // ignore: cast_nullable_to_non_nullable
as Map<String, AssessmentInfo>,questionInfoMap: null == questionInfoMap ? _self._questionInfoMap : questionInfoMap // ignore: cast_nullable_to_non_nullable
as Map<String, QuestionInfo>,recommendationsInfoMap: null == recommendationsInfoMap ? _self._recommendationsInfoMap : recommendationsInfoMap // ignore: cast_nullable_to_non_nullable
as Map<String, RecommendationsInfo>,
  ));
}


}


/// @nodoc
mixin _$AssessmentInfo {

/// Name of the state of the jurisdiction (e.g. 'Nevada').
 String get state;/// Name of the jurisdiction (e.g. 'Las Vegas').
 String get jurisdiction;/// Contains the IDs of the questions assessment.
///
/// Each inner list represents an individual section, in which each
/// element is an ID of a `QuestionInfo` object.
///
/// For example, `questionInfoIds[0][2]` is the ID of the 3rd question in
/// the first section.
 List<List<String>> get questionInfoIds;/// ID of the RecommendationsInfo object to use for this assessment.
 String get recommendationsInfoId;/// Project address for the assessment
/// Project address for querying location-based data (e.g., parks).
/// Can be null if not yet set by the user.
 String? get projectAddress;
/// Create a copy of AssessmentInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssessmentInfoCopyWith<AssessmentInfo> get copyWith => _$AssessmentInfoCopyWithImpl<AssessmentInfo>(this as AssessmentInfo, _$identity);

  /// Serializes this AssessmentInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssessmentInfo&&(identical(other.state, state) || other.state == state)&&(identical(other.jurisdiction, jurisdiction) || other.jurisdiction == jurisdiction)&&const DeepCollectionEquality().equals(other.questionInfoIds, questionInfoIds)&&(identical(other.recommendationsInfoId, recommendationsInfoId) || other.recommendationsInfoId == recommendationsInfoId)&&(identical(other.projectAddress, projectAddress) || other.projectAddress == projectAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,jurisdiction,const DeepCollectionEquality().hash(questionInfoIds),recommendationsInfoId,projectAddress);

@override
String toString() {
  return 'AssessmentInfo(state: $state, jurisdiction: $jurisdiction, questionInfoIds: $questionInfoIds, recommendationsInfoId: $recommendationsInfoId, projectAddress: $projectAddress)';
}


}

/// @nodoc
abstract mixin class $AssessmentInfoCopyWith<$Res>  {
  factory $AssessmentInfoCopyWith(AssessmentInfo value, $Res Function(AssessmentInfo) _then) = _$AssessmentInfoCopyWithImpl;
@useResult
$Res call({
 String state, String jurisdiction, List<List<String>> questionInfoIds, String recommendationsInfoId, String? projectAddress
});




}
/// @nodoc
class _$AssessmentInfoCopyWithImpl<$Res>
    implements $AssessmentInfoCopyWith<$Res> {
  _$AssessmentInfoCopyWithImpl(this._self, this._then);

  final AssessmentInfo _self;
  final $Res Function(AssessmentInfo) _then;

/// Create a copy of AssessmentInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? state = null,Object? jurisdiction = null,Object? questionInfoIds = null,Object? recommendationsInfoId = null,Object? projectAddress = freezed,}) {
  return _then(_self.copyWith(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,jurisdiction: null == jurisdiction ? _self.jurisdiction : jurisdiction // ignore: cast_nullable_to_non_nullable
as String,questionInfoIds: null == questionInfoIds ? _self.questionInfoIds : questionInfoIds // ignore: cast_nullable_to_non_nullable
as List<List<String>>,recommendationsInfoId: null == recommendationsInfoId ? _self.recommendationsInfoId : recommendationsInfoId // ignore: cast_nullable_to_non_nullable
as String,projectAddress: freezed == projectAddress ? _self.projectAddress : projectAddress // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssessmentInfo].
extension AssessmentInfoPatterns on AssessmentInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssessmentInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssessmentInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssessmentInfo value)  $default,){
final _that = this;
switch (_that) {
case _AssessmentInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssessmentInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AssessmentInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String state,  String jurisdiction,  List<List<String>> questionInfoIds,  String recommendationsInfoId,  String? projectAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssessmentInfo() when $default != null:
return $default(_that.state,_that.jurisdiction,_that.questionInfoIds,_that.recommendationsInfoId,_that.projectAddress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String state,  String jurisdiction,  List<List<String>> questionInfoIds,  String recommendationsInfoId,  String? projectAddress)  $default,) {final _that = this;
switch (_that) {
case _AssessmentInfo():
return $default(_that.state,_that.jurisdiction,_that.questionInfoIds,_that.recommendationsInfoId,_that.projectAddress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String state,  String jurisdiction,  List<List<String>> questionInfoIds,  String recommendationsInfoId,  String? projectAddress)?  $default,) {final _that = this;
switch (_that) {
case _AssessmentInfo() when $default != null:
return $default(_that.state,_that.jurisdiction,_that.questionInfoIds,_that.recommendationsInfoId,_that.projectAddress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssessmentInfo extends AssessmentInfo {
   _AssessmentInfo({required this.state, required this.jurisdiction, required final  List<List<String>> questionInfoIds, required this.recommendationsInfoId, this.projectAddress}): _questionInfoIds = questionInfoIds,super._();
  factory _AssessmentInfo.fromJson(Map<String, dynamic> json) => _$AssessmentInfoFromJson(json);

/// Name of the state of the jurisdiction (e.g. 'Nevada').
@override final  String state;
/// Name of the jurisdiction (e.g. 'Las Vegas').
@override final  String jurisdiction;
/// Contains the IDs of the questions assessment.
///
/// Each inner list represents an individual section, in which each
/// element is an ID of a `QuestionInfo` object.
///
/// For example, `questionInfoIds[0][2]` is the ID of the 3rd question in
/// the first section.
 final  List<List<String>> _questionInfoIds;
/// Contains the IDs of the questions assessment.
///
/// Each inner list represents an individual section, in which each
/// element is an ID of a `QuestionInfo` object.
///
/// For example, `questionInfoIds[0][2]` is the ID of the 3rd question in
/// the first section.
@override List<List<String>> get questionInfoIds {
  if (_questionInfoIds is EqualUnmodifiableListView) return _questionInfoIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questionInfoIds);
}

/// ID of the RecommendationsInfo object to use for this assessment.
@override final  String recommendationsInfoId;
/// Project address for the assessment
/// Project address for querying location-based data (e.g., parks).
/// Can be null if not yet set by the user.
@override final  String? projectAddress;

/// Create a copy of AssessmentInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssessmentInfoCopyWith<_AssessmentInfo> get copyWith => __$AssessmentInfoCopyWithImpl<_AssessmentInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssessmentInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssessmentInfo&&(identical(other.state, state) || other.state == state)&&(identical(other.jurisdiction, jurisdiction) || other.jurisdiction == jurisdiction)&&const DeepCollectionEquality().equals(other._questionInfoIds, _questionInfoIds)&&(identical(other.recommendationsInfoId, recommendationsInfoId) || other.recommendationsInfoId == recommendationsInfoId)&&(identical(other.projectAddress, projectAddress) || other.projectAddress == projectAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,jurisdiction,const DeepCollectionEquality().hash(_questionInfoIds),recommendationsInfoId,projectAddress);

@override
String toString() {
  return 'AssessmentInfo(state: $state, jurisdiction: $jurisdiction, questionInfoIds: $questionInfoIds, recommendationsInfoId: $recommendationsInfoId, projectAddress: $projectAddress)';
}


}

/// @nodoc
abstract mixin class _$AssessmentInfoCopyWith<$Res> implements $AssessmentInfoCopyWith<$Res> {
  factory _$AssessmentInfoCopyWith(_AssessmentInfo value, $Res Function(_AssessmentInfo) _then) = __$AssessmentInfoCopyWithImpl;
@override @useResult
$Res call({
 String state, String jurisdiction, List<List<String>> questionInfoIds, String recommendationsInfoId, String? projectAddress
});




}
/// @nodoc
class __$AssessmentInfoCopyWithImpl<$Res>
    implements _$AssessmentInfoCopyWith<$Res> {
  __$AssessmentInfoCopyWithImpl(this._self, this._then);

  final _AssessmentInfo _self;
  final $Res Function(_AssessmentInfo) _then;

/// Create a copy of AssessmentInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? state = null,Object? jurisdiction = null,Object? questionInfoIds = null,Object? recommendationsInfoId = null,Object? projectAddress = freezed,}) {
  return _then(_AssessmentInfo(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,jurisdiction: null == jurisdiction ? _self.jurisdiction : jurisdiction // ignore: cast_nullable_to_non_nullable
as String,questionInfoIds: null == questionInfoIds ? _self._questionInfoIds : questionInfoIds // ignore: cast_nullable_to_non_nullable
as List<List<String>>,recommendationsInfoId: null == recommendationsInfoId ? _self.recommendationsInfoId : recommendationsInfoId // ignore: cast_nullable_to_non_nullable
as String,projectAddress: freezed == projectAddress ? _self.projectAddress : projectAddress // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$QuestionInfo {

/// Main question text content.
 String get questionText;/// Subtitle text.
 String get useUrl;/// URL of the link at the end of the subtitle text.
 String get url;/// List of answers for the user to choose. Answers should be sorted from
/// lowest number of points to highest number of points.
 List<Answer> get answers;/// Header text above the answer buttons.
 String get answerLeadingHeader;/// Display text for the domain that the question falls under.
 String get domain;/// Markdown-formatted text of the instructions to follow.
 String get instructionsMarkdown;/// Google Drive file ID of the instructions video. (only the ID, not the
/// full link)
 String get videoId;/// Additional subtitle text, used for additional notes.
 String get hint;/// Whether the auto-fill button should be shown for this question.
/// Defaults to false if not specified in the TOML file.
 bool get autoFillEnabled;
/// Create a copy of QuestionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionInfoCopyWith<QuestionInfo> get copyWith => _$QuestionInfoCopyWithImpl<QuestionInfo>(this as QuestionInfo, _$identity);

  /// Serializes this QuestionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuestionInfo&&(identical(other.questionText, questionText) || other.questionText == questionText)&&(identical(other.useUrl, useUrl) || other.useUrl == useUrl)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.answers, answers)&&(identical(other.answerLeadingHeader, answerLeadingHeader) || other.answerLeadingHeader == answerLeadingHeader)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.instructionsMarkdown, instructionsMarkdown) || other.instructionsMarkdown == instructionsMarkdown)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.autoFillEnabled, autoFillEnabled) || other.autoFillEnabled == autoFillEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionText,useUrl,url,const DeepCollectionEquality().hash(answers),answerLeadingHeader,domain,instructionsMarkdown,videoId,hint,autoFillEnabled);

@override
String toString() {
  return 'QuestionInfo(questionText: $questionText, useUrl: $useUrl, url: $url, answers: $answers, answerLeadingHeader: $answerLeadingHeader, domain: $domain, instructionsMarkdown: $instructionsMarkdown, videoId: $videoId, hint: $hint, autoFillEnabled: $autoFillEnabled)';
}


}

/// @nodoc
abstract mixin class $QuestionInfoCopyWith<$Res>  {
  factory $QuestionInfoCopyWith(QuestionInfo value, $Res Function(QuestionInfo) _then) = _$QuestionInfoCopyWithImpl;
@useResult
$Res call({
 String questionText, String useUrl, String url, List<Answer> answers, String answerLeadingHeader, String domain, String instructionsMarkdown, String videoId, String hint, bool autoFillEnabled
});




}
/// @nodoc
class _$QuestionInfoCopyWithImpl<$Res>
    implements $QuestionInfoCopyWith<$Res> {
  _$QuestionInfoCopyWithImpl(this._self, this._then);

  final QuestionInfo _self;
  final $Res Function(QuestionInfo) _then;

/// Create a copy of QuestionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? questionText = null,Object? useUrl = null,Object? url = null,Object? answers = null,Object? answerLeadingHeader = null,Object? domain = null,Object? instructionsMarkdown = null,Object? videoId = null,Object? hint = null,Object? autoFillEnabled = null,}) {
  return _then(_self.copyWith(
questionText: null == questionText ? _self.questionText : questionText // ignore: cast_nullable_to_non_nullable
as String,useUrl: null == useUrl ? _self.useUrl : useUrl // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as List<Answer>,answerLeadingHeader: null == answerLeadingHeader ? _self.answerLeadingHeader : answerLeadingHeader // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,instructionsMarkdown: null == instructionsMarkdown ? _self.instructionsMarkdown : instructionsMarkdown // ignore: cast_nullable_to_non_nullable
as String,videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,hint: null == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String,autoFillEnabled: null == autoFillEnabled ? _self.autoFillEnabled : autoFillEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [QuestionInfo].
extension QuestionInfoPatterns on QuestionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuestionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuestionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuestionInfo value)  $default,){
final _that = this;
switch (_that) {
case _QuestionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuestionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _QuestionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String questionText,  String useUrl,  String url,  List<Answer> answers,  String answerLeadingHeader,  String domain,  String instructionsMarkdown,  String videoId,  String hint,  bool autoFillEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuestionInfo() when $default != null:
return $default(_that.questionText,_that.useUrl,_that.url,_that.answers,_that.answerLeadingHeader,_that.domain,_that.instructionsMarkdown,_that.videoId,_that.hint,_that.autoFillEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String questionText,  String useUrl,  String url,  List<Answer> answers,  String answerLeadingHeader,  String domain,  String instructionsMarkdown,  String videoId,  String hint,  bool autoFillEnabled)  $default,) {final _that = this;
switch (_that) {
case _QuestionInfo():
return $default(_that.questionText,_that.useUrl,_that.url,_that.answers,_that.answerLeadingHeader,_that.domain,_that.instructionsMarkdown,_that.videoId,_that.hint,_that.autoFillEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String questionText,  String useUrl,  String url,  List<Answer> answers,  String answerLeadingHeader,  String domain,  String instructionsMarkdown,  String videoId,  String hint,  bool autoFillEnabled)?  $default,) {final _that = this;
switch (_that) {
case _QuestionInfo() when $default != null:
return $default(_that.questionText,_that.useUrl,_that.url,_that.answers,_that.answerLeadingHeader,_that.domain,_that.instructionsMarkdown,_that.videoId,_that.hint,_that.autoFillEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuestionInfo implements QuestionInfo {
   _QuestionInfo({required this.questionText, required this.useUrl, required this.url, required final  List<Answer> answers, required this.answerLeadingHeader, required this.domain, required this.instructionsMarkdown, required this.videoId, required this.hint, this.autoFillEnabled = false}): assert(answers.length >= 1, 'points must not be empty'),assert(answers.isSorted((a, b) => a.points.compareTo(b.points)), 'answers must be sorted from lowest to highest points'),_answers = answers;
  factory _QuestionInfo.fromJson(Map<String, dynamic> json) => _$QuestionInfoFromJson(json);

/// Main question text content.
@override final  String questionText;
/// Subtitle text.
@override final  String useUrl;
/// URL of the link at the end of the subtitle text.
@override final  String url;
/// List of answers for the user to choose. Answers should be sorted from
/// lowest number of points to highest number of points.
 final  List<Answer> _answers;
/// List of answers for the user to choose. Answers should be sorted from
/// lowest number of points to highest number of points.
@override List<Answer> get answers {
  if (_answers is EqualUnmodifiableListView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_answers);
}

/// Header text above the answer buttons.
@override final  String answerLeadingHeader;
/// Display text for the domain that the question falls under.
@override final  String domain;
/// Markdown-formatted text of the instructions to follow.
@override final  String instructionsMarkdown;
/// Google Drive file ID of the instructions video. (only the ID, not the
/// full link)
@override final  String videoId;
/// Additional subtitle text, used for additional notes.
@override final  String hint;
/// Whether the auto-fill button should be shown for this question.
/// Defaults to false if not specified in the TOML file.
@override@JsonKey() final  bool autoFillEnabled;

/// Create a copy of QuestionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestionInfoCopyWith<_QuestionInfo> get copyWith => __$QuestionInfoCopyWithImpl<_QuestionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuestionInfo&&(identical(other.questionText, questionText) || other.questionText == questionText)&&(identical(other.useUrl, useUrl) || other.useUrl == useUrl)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._answers, _answers)&&(identical(other.answerLeadingHeader, answerLeadingHeader) || other.answerLeadingHeader == answerLeadingHeader)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.instructionsMarkdown, instructionsMarkdown) || other.instructionsMarkdown == instructionsMarkdown)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.autoFillEnabled, autoFillEnabled) || other.autoFillEnabled == autoFillEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionText,useUrl,url,const DeepCollectionEquality().hash(_answers),answerLeadingHeader,domain,instructionsMarkdown,videoId,hint,autoFillEnabled);

@override
String toString() {
  return 'QuestionInfo(questionText: $questionText, useUrl: $useUrl, url: $url, answers: $answers, answerLeadingHeader: $answerLeadingHeader, domain: $domain, instructionsMarkdown: $instructionsMarkdown, videoId: $videoId, hint: $hint, autoFillEnabled: $autoFillEnabled)';
}


}

/// @nodoc
abstract mixin class _$QuestionInfoCopyWith<$Res> implements $QuestionInfoCopyWith<$Res> {
  factory _$QuestionInfoCopyWith(_QuestionInfo value, $Res Function(_QuestionInfo) _then) = __$QuestionInfoCopyWithImpl;
@override @useResult
$Res call({
 String questionText, String useUrl, String url, List<Answer> answers, String answerLeadingHeader, String domain, String instructionsMarkdown, String videoId, String hint, bool autoFillEnabled
});




}
/// @nodoc
class __$QuestionInfoCopyWithImpl<$Res>
    implements _$QuestionInfoCopyWith<$Res> {
  __$QuestionInfoCopyWithImpl(this._self, this._then);

  final _QuestionInfo _self;
  final $Res Function(_QuestionInfo) _then;

/// Create a copy of QuestionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? questionText = null,Object? useUrl = null,Object? url = null,Object? answers = null,Object? answerLeadingHeader = null,Object? domain = null,Object? instructionsMarkdown = null,Object? videoId = null,Object? hint = null,Object? autoFillEnabled = null,}) {
  return _then(_QuestionInfo(
questionText: null == questionText ? _self.questionText : questionText // ignore: cast_nullable_to_non_nullable
as String,useUrl: null == useUrl ? _self.useUrl : useUrl // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as List<Answer>,answerLeadingHeader: null == answerLeadingHeader ? _self.answerLeadingHeader : answerLeadingHeader // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,instructionsMarkdown: null == instructionsMarkdown ? _self.instructionsMarkdown : instructionsMarkdown // ignore: cast_nullable_to_non_nullable
as String,videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,hint: null == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String,autoFillEnabled: null == autoFillEnabled ? _self.autoFillEnabled : autoFillEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Answer {

/// Answer text content.
 String get text;/// Number of points the answer is worth.
 double get points;
/// Create a copy of Answer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnswerCopyWith<Answer> get copyWith => _$AnswerCopyWithImpl<Answer>(this as Answer, _$identity);

  /// Serializes this Answer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Answer&&(identical(other.text, text) || other.text == text)&&(identical(other.points, points) || other.points == points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,points);

@override
String toString() {
  return 'Answer(text: $text, points: $points)';
}


}

/// @nodoc
abstract mixin class $AnswerCopyWith<$Res>  {
  factory $AnswerCopyWith(Answer value, $Res Function(Answer) _then) = _$AnswerCopyWithImpl;
@useResult
$Res call({
 String text, double points
});




}
/// @nodoc
class _$AnswerCopyWithImpl<$Res>
    implements $AnswerCopyWith<$Res> {
  _$AnswerCopyWithImpl(this._self, this._then);

  final Answer _self;
  final $Res Function(Answer) _then;

/// Create a copy of Answer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? points = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Answer].
extension AnswerPatterns on Answer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Answer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Answer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Answer value)  $default,){
final _that = this;
switch (_that) {
case _Answer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Answer value)?  $default,){
final _that = this;
switch (_that) {
case _Answer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  double points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Answer() when $default != null:
return $default(_that.text,_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  double points)  $default,) {final _that = this;
switch (_that) {
case _Answer():
return $default(_that.text,_that.points);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  double points)?  $default,) {final _that = this;
switch (_that) {
case _Answer() when $default != null:
return $default(_that.text,_that.points);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Answer implements Answer {
  const _Answer({required this.text, required this.points});
  factory _Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);

/// Answer text content.
@override final  String text;
/// Number of points the answer is worth.
@override final  double points;

/// Create a copy of Answer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnswerCopyWith<_Answer> get copyWith => __$AnswerCopyWithImpl<_Answer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnswerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Answer&&(identical(other.text, text) || other.text == text)&&(identical(other.points, points) || other.points == points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,points);

@override
String toString() {
  return 'Answer(text: $text, points: $points)';
}


}

/// @nodoc
abstract mixin class _$AnswerCopyWith<$Res> implements $AnswerCopyWith<$Res> {
  factory _$AnswerCopyWith(_Answer value, $Res Function(_Answer) _then) = __$AnswerCopyWithImpl;
@override @useResult
$Res call({
 String text, double points
});




}
/// @nodoc
class __$AnswerCopyWithImpl<$Res>
    implements _$AnswerCopyWith<$Res> {
  __$AnswerCopyWithImpl(this._self, this._then);

  final _Answer _self;
  final $Res Function(_Answer) _then;

/// Create a copy of Answer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? points = null,}) {
  return _then(_Answer(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$RecommendationsInfo {

/// List of recommendation categories.
 List<RecommendationCategory> get s3_categories;
/// Create a copy of RecommendationsInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationsInfoCopyWith<RecommendationsInfo> get copyWith => _$RecommendationsInfoCopyWithImpl<RecommendationsInfo>(this as RecommendationsInfo, _$identity);

  /// Serializes this RecommendationsInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationsInfo&&const DeepCollectionEquality().equals(other.s3_categories, s3_categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(s3_categories));

@override
String toString() {
  return 'RecommendationsInfo(s3_categories: $s3_categories)';
}


}

/// @nodoc
abstract mixin class $RecommendationsInfoCopyWith<$Res>  {
  factory $RecommendationsInfoCopyWith(RecommendationsInfo value, $Res Function(RecommendationsInfo) _then) = _$RecommendationsInfoCopyWithImpl;
@useResult
$Res call({
 List<RecommendationCategory> s3_categories
});




}
/// @nodoc
class _$RecommendationsInfoCopyWithImpl<$Res>
    implements $RecommendationsInfoCopyWith<$Res> {
  _$RecommendationsInfoCopyWithImpl(this._self, this._then);

  final RecommendationsInfo _self;
  final $Res Function(RecommendationsInfo) _then;

/// Create a copy of RecommendationsInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? s3_categories = null,}) {
  return _then(_self.copyWith(
s3_categories: null == s3_categories ? _self.s3_categories : s3_categories // ignore: cast_nullable_to_non_nullable
as List<RecommendationCategory>,
  ));
}

}


/// Adds pattern-matching-related methods to [RecommendationsInfo].
extension RecommendationsInfoPatterns on RecommendationsInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationsInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationsInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationsInfo value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationsInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationsInfo value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationsInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RecommendationCategory> s3_categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationsInfo() when $default != null:
return $default(_that.s3_categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RecommendationCategory> s3_categories)  $default,) {final _that = this;
switch (_that) {
case _RecommendationsInfo():
return $default(_that.s3_categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RecommendationCategory> s3_categories)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationsInfo() when $default != null:
return $default(_that.s3_categories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecommendationsInfo implements RecommendationsInfo {
  const _RecommendationsInfo({required final  List<RecommendationCategory> s3_categories}): _s3_categories = s3_categories;
  factory _RecommendationsInfo.fromJson(Map<String, dynamic> json) => _$RecommendationsInfoFromJson(json);

/// List of recommendation categories.
 final  List<RecommendationCategory> _s3_categories;
/// List of recommendation categories.
@override List<RecommendationCategory> get s3_categories {
  if (_s3_categories is EqualUnmodifiableListView) return _s3_categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_s3_categories);
}


/// Create a copy of RecommendationsInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationsInfoCopyWith<_RecommendationsInfo> get copyWith => __$RecommendationsInfoCopyWithImpl<_RecommendationsInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendationsInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationsInfo&&const DeepCollectionEquality().equals(other._s3_categories, _s3_categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_s3_categories));

@override
String toString() {
  return 'RecommendationsInfo(s3_categories: $s3_categories)';
}


}

/// @nodoc
abstract mixin class _$RecommendationsInfoCopyWith<$Res> implements $RecommendationsInfoCopyWith<$Res> {
  factory _$RecommendationsInfoCopyWith(_RecommendationsInfo value, $Res Function(_RecommendationsInfo) _then) = __$RecommendationsInfoCopyWithImpl;
@override @useResult
$Res call({
 List<RecommendationCategory> s3_categories
});




}
/// @nodoc
class __$RecommendationsInfoCopyWithImpl<$Res>
    implements _$RecommendationsInfoCopyWith<$Res> {
  __$RecommendationsInfoCopyWithImpl(this._self, this._then);

  final _RecommendationsInfo _self;
  final $Res Function(_RecommendationsInfo) _then;

/// Create a copy of RecommendationsInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? s3_categories = null,}) {
  return _then(_RecommendationsInfo(
s3_categories: null == s3_categories ? _self._s3_categories : s3_categories // ignore: cast_nullable_to_non_nullable
as List<RecommendationCategory>,
  ));
}


}


/// @nodoc
mixin _$RecommendationCategory {

 int get optionGroupCount; List<({String? good, String? better, String? best})> get optionGroups;/// Title of this category.
 String get categoryTitle;/// Contains answers for Good Health choices.
 List<String> get goodHealth;/// Contains answers for Better Health choices.
 List<String> get betterHealth;/// Contains answers for Best Health choices.
 List<String> get bestHealth;
/// Create a copy of RecommendationCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationCategoryCopyWith<RecommendationCategory> get copyWith => _$RecommendationCategoryCopyWithImpl<RecommendationCategory>(this as RecommendationCategory, _$identity);

  /// Serializes this RecommendationCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationCategory&&(identical(other.optionGroupCount, optionGroupCount) || other.optionGroupCount == optionGroupCount)&&const DeepCollectionEquality().equals(other.optionGroups, optionGroups)&&(identical(other.categoryTitle, categoryTitle) || other.categoryTitle == categoryTitle)&&const DeepCollectionEquality().equals(other.goodHealth, goodHealth)&&const DeepCollectionEquality().equals(other.betterHealth, betterHealth)&&const DeepCollectionEquality().equals(other.bestHealth, bestHealth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,optionGroupCount,const DeepCollectionEquality().hash(optionGroups),categoryTitle,const DeepCollectionEquality().hash(goodHealth),const DeepCollectionEquality().hash(betterHealth),const DeepCollectionEquality().hash(bestHealth));

@override
String toString() {
  return 'RecommendationCategory(optionGroupCount: $optionGroupCount, optionGroups: $optionGroups, categoryTitle: $categoryTitle, goodHealth: $goodHealth, betterHealth: $betterHealth, bestHealth: $bestHealth)';
}


}

/// @nodoc
abstract mixin class $RecommendationCategoryCopyWith<$Res>  {
  factory $RecommendationCategoryCopyWith(RecommendationCategory value, $Res Function(RecommendationCategory) _then) = _$RecommendationCategoryCopyWithImpl;
@useResult
$Res call({
 String categoryTitle, List<String> goodHealth, List<String> betterHealth, List<String> bestHealth
});




}
/// @nodoc
class _$RecommendationCategoryCopyWithImpl<$Res>
    implements $RecommendationCategoryCopyWith<$Res> {
  _$RecommendationCategoryCopyWithImpl(this._self, this._then);

  final RecommendationCategory _self;
  final $Res Function(RecommendationCategory) _then;

/// Create a copy of RecommendationCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryTitle = null,Object? goodHealth = null,Object? betterHealth = null,Object? bestHealth = null,}) {
  return _then(_self.copyWith(
categoryTitle: null == categoryTitle ? _self.categoryTitle : categoryTitle // ignore: cast_nullable_to_non_nullable
as String,goodHealth: null == goodHealth ? _self.goodHealth : goodHealth // ignore: cast_nullable_to_non_nullable
as List<String>,betterHealth: null == betterHealth ? _self.betterHealth : betterHealth // ignore: cast_nullable_to_non_nullable
as List<String>,bestHealth: null == bestHealth ? _self.bestHealth : bestHealth // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RecommendationCategory].
extension RecommendationCategoryPatterns on RecommendationCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationCategory value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationCategory value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryTitle,  List<String> goodHealth,  List<String> betterHealth,  List<String> bestHealth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationCategory() when $default != null:
return $default(_that.categoryTitle,_that.goodHealth,_that.betterHealth,_that.bestHealth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryTitle,  List<String> goodHealth,  List<String> betterHealth,  List<String> bestHealth)  $default,) {final _that = this;
switch (_that) {
case _RecommendationCategory():
return $default(_that.categoryTitle,_that.goodHealth,_that.betterHealth,_that.bestHealth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryTitle,  List<String> goodHealth,  List<String> betterHealth,  List<String> bestHealth)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationCategory() when $default != null:
return $default(_that.categoryTitle,_that.goodHealth,_that.betterHealth,_that.bestHealth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecommendationCategory extends RecommendationCategory {
   _RecommendationCategory({required this.categoryTitle, required final  List<String> goodHealth, required final  List<String> betterHealth, required final  List<String> bestHealth}): _goodHealth = goodHealth,_betterHealth = betterHealth,_bestHealth = bestHealth,super._();
  factory _RecommendationCategory.fromJson(Map<String, dynamic> json) => _$RecommendationCategoryFromJson(json);

/// Title of this category.
@override final  String categoryTitle;
/// Contains answers for Good Health choices.
 final  List<String> _goodHealth;
/// Contains answers for Good Health choices.
@override List<String> get goodHealth {
  if (_goodHealth is EqualUnmodifiableListView) return _goodHealth;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_goodHealth);
}

/// Contains answers for Better Health choices.
 final  List<String> _betterHealth;
/// Contains answers for Better Health choices.
@override List<String> get betterHealth {
  if (_betterHealth is EqualUnmodifiableListView) return _betterHealth;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_betterHealth);
}

/// Contains answers for Best Health choices.
 final  List<String> _bestHealth;
/// Contains answers for Best Health choices.
@override List<String> get bestHealth {
  if (_bestHealth is EqualUnmodifiableListView) return _bestHealth;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bestHealth);
}


/// Create a copy of RecommendationCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationCategoryCopyWith<_RecommendationCategory> get copyWith => __$RecommendationCategoryCopyWithImpl<_RecommendationCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendationCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationCategory&&(identical(other.categoryTitle, categoryTitle) || other.categoryTitle == categoryTitle)&&const DeepCollectionEquality().equals(other._goodHealth, _goodHealth)&&const DeepCollectionEquality().equals(other._betterHealth, _betterHealth)&&const DeepCollectionEquality().equals(other._bestHealth, _bestHealth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryTitle,const DeepCollectionEquality().hash(_goodHealth),const DeepCollectionEquality().hash(_betterHealth),const DeepCollectionEquality().hash(_bestHealth));

@override
String toString() {
  return 'RecommendationCategory(categoryTitle: $categoryTitle, goodHealth: $goodHealth, betterHealth: $betterHealth, bestHealth: $bestHealth)';
}


}

/// @nodoc
abstract mixin class _$RecommendationCategoryCopyWith<$Res> implements $RecommendationCategoryCopyWith<$Res> {
  factory _$RecommendationCategoryCopyWith(_RecommendationCategory value, $Res Function(_RecommendationCategory) _then) = __$RecommendationCategoryCopyWithImpl;
@override @useResult
$Res call({
 String categoryTitle, List<String> goodHealth, List<String> betterHealth, List<String> bestHealth
});




}
/// @nodoc
class __$RecommendationCategoryCopyWithImpl<$Res>
    implements _$RecommendationCategoryCopyWith<$Res> {
  __$RecommendationCategoryCopyWithImpl(this._self, this._then);

  final _RecommendationCategory _self;
  final $Res Function(_RecommendationCategory) _then;

/// Create a copy of RecommendationCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryTitle = null,Object? goodHealth = null,Object? betterHealth = null,Object? bestHealth = null,}) {
  return _then(_RecommendationCategory(
categoryTitle: null == categoryTitle ? _self.categoryTitle : categoryTitle // ignore: cast_nullable_to_non_nullable
as String,goodHealth: null == goodHealth ? _self._goodHealth : goodHealth // ignore: cast_nullable_to_non_nullable
as List<String>,betterHealth: null == betterHealth ? _self._betterHealth : betterHealth // ignore: cast_nullable_to_non_nullable
as List<String>,bestHealth: null == bestHealth ? _self._bestHealth : bestHealth // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
