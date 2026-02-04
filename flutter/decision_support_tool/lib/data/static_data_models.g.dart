// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'static_data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssessmentInfo _$AssessmentInfoFromJson(Map<String, dynamic> json) =>
    _AssessmentInfo(
      state: json['state'] as String,
      jurisdiction: json['jurisdiction'] as String,
      questionInfoIds: (json['questionInfoIds'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
      recommendationsInfoId: json['recommendationsInfoId'] as String,
      projectAddress: json['projectAddress'] as String?,
    );

Map<String, dynamic> _$AssessmentInfoToJson(_AssessmentInfo instance) =>
    <String, dynamic>{
      'state': instance.state,
      'jurisdiction': instance.jurisdiction,
      'questionInfoIds': instance.questionInfoIds,
      'recommendationsInfoId': instance.recommendationsInfoId,
      'projectAddress': instance.projectAddress,
    };

_QuestionInfo _$QuestionInfoFromJson(Map<String, dynamic> json) =>
    _QuestionInfo(
      questionText: json['questionText'] as String,
      useUrl: json['useUrl'] as String,
      url: json['url'] as String,
      answers: (json['answers'] as List<dynamic>)
          .map((e) => Answer.fromJson(e as Map<String, dynamic>))
          .toList(),
      answerLeadingHeader: json['answerLeadingHeader'] as String,
      domain: json['domain'] as String,
      instructionsMarkdown: json['instructionsMarkdown'] as String,
      videoId: json['videoId'] as String,
      hint: json['hint'] as String,
      autoFillEnabled: json['autoFillEnabled'] as bool? ?? false,
    );

Map<String, dynamic> _$QuestionInfoToJson(_QuestionInfo instance) =>
    <String, dynamic>{
      'questionText': instance.questionText,
      'useUrl': instance.useUrl,
      'url': instance.url,
      'answers': instance.answers.map((e) => e.toJson()).toList(),
      'answerLeadingHeader': instance.answerLeadingHeader,
      'domain': instance.domain,
      'instructionsMarkdown': instance.instructionsMarkdown,
      'videoId': instance.videoId,
      'hint': instance.hint,
      'autoFillEnabled': instance.autoFillEnabled,
    };

_Answer _$AnswerFromJson(Map<String, dynamic> json) => _Answer(
  text: json['text'] as String,
  points: (json['points'] as num).toDouble(),
);

Map<String, dynamic> _$AnswerToJson(_Answer instance) => <String, dynamic>{
  'text': instance.text,
  'points': instance.points,
};

_RecommendationsInfo _$RecommendationsInfoFromJson(Map<String, dynamic> json) =>
    _RecommendationsInfo(
      s3_categories: (json['s3_categories'] as List<dynamic>)
          .map(
            (e) => RecommendationCategory.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$RecommendationsInfoToJson(
  _RecommendationsInfo instance,
) => <String, dynamic>{
  's3_categories': instance.s3_categories.map((e) => e.toJson()).toList(),
};

_RecommendationCategory _$RecommendationCategoryFromJson(
  Map<String, dynamic> json,
) => _RecommendationCategory(
  categoryTitle: json['categoryTitle'] as String,
  goodHealth: (json['goodHealth'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  betterHealth: (json['betterHealth'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  bestHealth: (json['bestHealth'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RecommendationCategoryToJson(
  _RecommendationCategory instance,
) => <String, dynamic>{
  'categoryTitle': instance.categoryTitle,
  'goodHealth': instance.goodHealth,
  'betterHealth': instance.betterHealth,
  'bestHealth': instance.bestHealth,
};
