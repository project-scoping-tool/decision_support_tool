// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'form_data_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FormData {

/// AssessmentInfo ID, null if not chosen yet.
 String? get assessmentInfoId;/// AssessmentInfo ID, null if not chosen yet.
 set assessmentInfoId(String? value);/// Indices of the selected answers corresponding to each question.
///
/// Each inner list represents an individual section, in which each
/// element is an index corresponding to the selected answer, otherwise a
/// null if no answer is selected yet.
///
/// For example, `selectedAnswerIndices[0][2]` is the answer index
/// corresponding to the third question in the first section.
 List<List<int?>> get selectedAnswerIndices;/// Indices of the selected answers corresponding to each question.
///
/// Each inner list represents an individual section, in which each
/// element is an index corresponding to the selected answer, otherwise a
/// null if no answer is selected yet.
///
/// For example, `selectedAnswerIndices[0][2]` is the answer index
/// corresponding to the third question in the first section.
 set selectedAnswerIndices(List<List<int?>> value);/// Indices of the selected recommendation option corresponding to each
/// option set in each of the recommendation categories.
///
/// Each inner list represents an individual category, in which each
/// element is an index of the selected option in the corresponding
/// option set, otherwise null if no option is selected yet.
///
/// For example, `selectedRecommendationIndices[1][3]` is the option index
/// corresponding to the fourth option set in the second recommendation
/// category.
 List<List<int?>> get selectedRecommendationIndices;/// Indices of the selected recommendation option corresponding to each
/// option set in each of the recommendation categories.
///
/// Each inner list represents an individual category, in which each
/// element is an index of the selected option in the corresponding
/// option set, otherwise null if no option is selected yet.
///
/// For example, `selectedRecommendationIndices[1][3]` is the option index
/// corresponding to the fourth option set in the second recommendation
/// category.
 set selectedRecommendationIndices(List<List<int?>> value);/// User-inputted text for the justifications for the selected
/// recommendations in each category.
///
/// For example, `justifications[2]` is the justification text
/// corresponding to the third recommendation category.
 List<String> get justifications;/// User-inputted text for the justifications for the selected
/// recommendations in each category.
///
/// For example, `justifications[2]` is the justification text
/// corresponding to the third recommendation category.
 set justifications(List<String> value);
/// Create a copy of FormData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FormDataCopyWith<FormData> get copyWith => _$FormDataCopyWithImpl<FormData>(this as FormData, _$identity);

  /// Serializes this FormData to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  return 'FormData(assessmentInfoId: $assessmentInfoId, selectedAnswerIndices: $selectedAnswerIndices, selectedRecommendationIndices: $selectedRecommendationIndices, justifications: $justifications)';
}


}

/// @nodoc
abstract mixin class $FormDataCopyWith<$Res>  {
  factory $FormDataCopyWith(FormData value, $Res Function(FormData) _then) = _$FormDataCopyWithImpl;
@useResult
$Res call({
 String? assessmentInfoId, List<List<int?>> selectedAnswerIndices, List<List<int?>> selectedRecommendationIndices, List<String> justifications
});




}
/// @nodoc
class _$FormDataCopyWithImpl<$Res>
    implements $FormDataCopyWith<$Res> {
  _$FormDataCopyWithImpl(this._self, this._then);

  final FormData _self;
  final $Res Function(FormData) _then;

/// Create a copy of FormData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? assessmentInfoId = freezed,Object? selectedAnswerIndices = null,Object? selectedRecommendationIndices = null,Object? justifications = null,}) {
  return _then(_self.copyWith(
assessmentInfoId: freezed == assessmentInfoId ? _self.assessmentInfoId : assessmentInfoId // ignore: cast_nullable_to_non_nullable
as String?,selectedAnswerIndices: null == selectedAnswerIndices ? _self.selectedAnswerIndices : selectedAnswerIndices // ignore: cast_nullable_to_non_nullable
as List<List<int?>>,selectedRecommendationIndices: null == selectedRecommendationIndices ? _self.selectedRecommendationIndices : selectedRecommendationIndices // ignore: cast_nullable_to_non_nullable
as List<List<int?>>,justifications: null == justifications ? _self.justifications : justifications // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [FormData].
extension FormDataPatterns on FormData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FormData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FormData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FormData value)  $default,){
final _that = this;
switch (_that) {
case _FormData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FormData value)?  $default,){
final _that = this;
switch (_that) {
case _FormData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? assessmentInfoId,  List<List<int?>> selectedAnswerIndices,  List<List<int?>> selectedRecommendationIndices,  List<String> justifications)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FormData() when $default != null:
return $default(_that.assessmentInfoId,_that.selectedAnswerIndices,_that.selectedRecommendationIndices,_that.justifications);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? assessmentInfoId,  List<List<int?>> selectedAnswerIndices,  List<List<int?>> selectedRecommendationIndices,  List<String> justifications)  $default,) {final _that = this;
switch (_that) {
case _FormData():
return $default(_that.assessmentInfoId,_that.selectedAnswerIndices,_that.selectedRecommendationIndices,_that.justifications);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? assessmentInfoId,  List<List<int?>> selectedAnswerIndices,  List<List<int?>> selectedRecommendationIndices,  List<String> justifications)?  $default,) {final _that = this;
switch (_that) {
case _FormData() when $default != null:
return $default(_that.assessmentInfoId,_that.selectedAnswerIndices,_that.selectedRecommendationIndices,_that.justifications);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FormData implements FormData {
   _FormData({required this.assessmentInfoId, required this.selectedAnswerIndices, required this.selectedRecommendationIndices, required this.justifications});
  factory _FormData.fromJson(Map<String, dynamic> json) => _$FormDataFromJson(json);

/// AssessmentInfo ID, null if not chosen yet.
@override  String? assessmentInfoId;
/// Indices of the selected answers corresponding to each question.
///
/// Each inner list represents an individual section, in which each
/// element is an index corresponding to the selected answer, otherwise a
/// null if no answer is selected yet.
///
/// For example, `selectedAnswerIndices[0][2]` is the answer index
/// corresponding to the third question in the first section.
@override  List<List<int?>> selectedAnswerIndices;
/// Indices of the selected recommendation option corresponding to each
/// option set in each of the recommendation categories.
///
/// Each inner list represents an individual category, in which each
/// element is an index of the selected option in the corresponding
/// option set, otherwise null if no option is selected yet.
///
/// For example, `selectedRecommendationIndices[1][3]` is the option index
/// corresponding to the fourth option set in the second recommendation
/// category.
@override  List<List<int?>> selectedRecommendationIndices;
/// User-inputted text for the justifications for the selected
/// recommendations in each category.
///
/// For example, `justifications[2]` is the justification text
/// corresponding to the third recommendation category.
@override  List<String> justifications;

/// Create a copy of FormData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FormDataCopyWith<_FormData> get copyWith => __$FormDataCopyWithImpl<_FormData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FormDataToJson(this, );
}



@override
String toString() {
  return 'FormData(assessmentInfoId: $assessmentInfoId, selectedAnswerIndices: $selectedAnswerIndices, selectedRecommendationIndices: $selectedRecommendationIndices, justifications: $justifications)';
}


}

/// @nodoc
abstract mixin class _$FormDataCopyWith<$Res> implements $FormDataCopyWith<$Res> {
  factory _$FormDataCopyWith(_FormData value, $Res Function(_FormData) _then) = __$FormDataCopyWithImpl;
@override @useResult
$Res call({
 String? assessmentInfoId, List<List<int?>> selectedAnswerIndices, List<List<int?>> selectedRecommendationIndices, List<String> justifications
});




}
/// @nodoc
class __$FormDataCopyWithImpl<$Res>
    implements _$FormDataCopyWith<$Res> {
  __$FormDataCopyWithImpl(this._self, this._then);

  final _FormData _self;
  final $Res Function(_FormData) _then;

/// Create a copy of FormData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? assessmentInfoId = freezed,Object? selectedAnswerIndices = null,Object? selectedRecommendationIndices = null,Object? justifications = null,}) {
  return _then(_FormData(
assessmentInfoId: freezed == assessmentInfoId ? _self.assessmentInfoId : assessmentInfoId // ignore: cast_nullable_to_non_nullable
as String?,selectedAnswerIndices: null == selectedAnswerIndices ? _self.selectedAnswerIndices : selectedAnswerIndices // ignore: cast_nullable_to_non_nullable
as List<List<int?>>,selectedRecommendationIndices: null == selectedRecommendationIndices ? _self.selectedRecommendationIndices : selectedRecommendationIndices // ignore: cast_nullable_to_non_nullable
as List<List<int?>>,justifications: null == justifications ? _self.justifications : justifications // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
