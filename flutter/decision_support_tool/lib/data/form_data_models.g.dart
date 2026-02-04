// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FormData _$FormDataFromJson(Map<String, dynamic> json) => _FormData(
  assessmentInfoId: json['assessmentInfoId'] as String?,
  selectedAnswerIndices: (json['selectedAnswerIndices'] as List<dynamic>)
      .map(
        (e) => (e as List<dynamic>).map((e) => (e as num?)?.toInt()).toList(),
      )
      .toList(),
  selectedRecommendationIndices:
      (json['selectedRecommendationIndices'] as List<dynamic>)
          .map(
            (e) =>
                (e as List<dynamic>).map((e) => (e as num?)?.toInt()).toList(),
          )
          .toList(),
  justifications: (json['justifications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$FormDataToJson(_FormData instance) => <String, dynamic>{
  'assessmentInfoId': instance.assessmentInfoId,
  'selectedAnswerIndices': instance.selectedAnswerIndices,
  'selectedRecommendationIndices': instance.selectedRecommendationIndices,
  'justifications': instance.justifications,
};
