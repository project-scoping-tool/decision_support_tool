import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:collection/collection.dart';

part 'static_data_models.freezed.dart';
part 'static_data_models.g.dart';

/// Immutable dataclass for information about assessment data for all
/// jurisdictions. This data is loaded at the beginning of the app and remains
/// **static** for the rest of the application.
@freezed
abstract class StaticData with _$StaticData {
  StaticData._();

  factory StaticData({
    /// Maps IDs to AssessmentInfo objects.
    required Map<String, AssessmentInfo> assessmentInfoMap,

    /// Maps IDs to QuestionInfo objects.
    required Map<String, QuestionInfo> questionInfoMap,

    /// Maps IDs to RecommendationsInfo objects.
    required Map<String, RecommendationsInfo> recommendationsInfoMap,
  }) = _StaticData;

  /// List of AssessmentInfo objects sorted by ID.
  late final List<(String, AssessmentInfo)> assessmentInfoPairsSorted =
      UnmodifiableListView(
        assessmentInfoMap.entries
            .sorted((a, b) => a.key.compareTo(b.key))
            .map((e) => (e.key, e.value))
            .toList(growable: false),
      );
}

/// Assessment information for a single jurisdiction.
@freezed
abstract class AssessmentInfo with _$AssessmentInfo {
  AssessmentInfo._();

  factory AssessmentInfo({
    /// Name of the state of the jurisdiction (e.g. 'Nevada').
    required String state,

    /// Name of the jurisdiction (e.g. 'Las Vegas').
    required String jurisdiction,

    /// Contains the IDs of the questions assessment.
    ///
    /// Each inner list represents an individual section, in which each
    /// element is an ID of a `QuestionInfo` object.
    ///
    /// For example, `questionInfoIds[0][2]` is the ID of the 3rd question in
    /// the first section.
    required List<List<String>> questionInfoIds,

    /// ID of the RecommendationsInfo object to use for this assessment.
    required String recommendationsInfoId,

    /// Project address for the assessment
    /// Project address for querying location-based data (e.g., parks).
    /// Can be null if not yet set by the user.
    String? projectAddress,
  }) = _AssessmentInfo;

  /// Creates an instance from a JSON mapping.
  factory AssessmentInfo.fromJson(Map<String, Object?> json) =>
      _$AssessmentInfoFromJson(json);

  /// Returns a fixed-size 2D list of QuestionInfo objects corresponding to
  /// the question info IDs in this AssessmentInfo object.
  List<List<QuestionInfo>> getQuestionInfos(
    Map<String, QuestionInfo> questionInfoMap,
  ) => questionInfoIds
      .map(
        (section) =>
            section.map((id) => questionInfoMap[id]!).toList(growable: false),
      )
      .toList(growable: false);
}

/// Information for an individual question.
@freezed
abstract class QuestionInfo with _$QuestionInfo {
  @Assert('answers.length >= 1', 'points must not be empty')
  @Assert(
    'answers.isSorted((a, b) => a.points.compareTo(b.points))',
    'answers must be sorted from lowest to highest points',
  )
  factory QuestionInfo({
    /// Main question text content.
    required String questionText,

    /// Subtitle text.
    required String useUrl,

    /// URL of the link at the end of the subtitle text.
    required String url,

    /// List of answers for the user to choose. Answers should be sorted from
    /// lowest number of points to highest number of points.
    required List<Answer> answers,

    /// Header text above the answer buttons.
    required String answerLeadingHeader,

    /// Display text for the domain that the question falls under.
    required String domain,

    /// Markdown-formatted text of the instructions to follow.
    required String instructionsMarkdown,

    /// Google Drive file ID of the instructions video. (only the ID, not the
    /// full link)
    required String videoId,

    /// Additional subtitle text, used for additional notes.
    required String hint,

    /// Whether the auto-fill button should be shown for this question.
    /// Defaults to false if not specified in the TOML file.
    @Default(false) bool autoFillEnabled,
  }) = _QuestionInfo;

  /// Creates an instance from a JSON mapping.
  factory QuestionInfo.fromJson(Map<String, Object?> json) =>
      _$QuestionInfoFromJson(json);
}

/// Information for a single answer to a question.
@freezed
abstract class Answer with _$Answer {
  const factory Answer({
    /// Answer text content.
    required String text,

    /// Number of points the answer is worth.
    required double points,
  }) = _Answer;

  /// Creates an instance from a JSON mapping.
  factory Answer.fromJson(Map<String, Object?> json) => _$AnswerFromJson(json);
}

/// Information for recommendations; contains multiple categories.
@freezed
abstract class RecommendationsInfo with _$RecommendationsInfo {
  const factory RecommendationsInfo({
    /// List of recommendation categories.
    required List<RecommendationCategory> s3_categories,
  }) = _RecommendationsInfo;

  /// Creates an instance from a JSON mapping.
  factory RecommendationsInfo.fromJson(Map<String, Object?> json) =>
      _$RecommendationsInfoFromJson(json);
}

/// Represents a category of recommendations to choose from.
///
/// Each category has a title and three lists of choices: Good Health, Better
/// Health, and Best Health.
///
/// You can think of these lists as columns in a table. Each row in the table
/// forms an **option group**, of which the user select *one* option from the
/// group. The user selects. Any of the lists may be shorter; its missing
/// elements represents that there is no option for this column.
///
/// For example, if the lists are ['a1', 'b1', 'c1'], ['a2', 'b2', 'c2', 'd3'],
/// ['a3', 'b3'], it would form the table:
///
/// | Option group   | GoodHealth  | BetterHealth | BestHealth  |
/// |----------------|-------------|--------------|-------------|
/// | Option group 0 | 'a1'        | 'a2'         | 'a3'        |
/// | Option group 1 | 'b1'        | 'b2'         | 'b3'        |
/// | Option group 2 | 'c1'        | 'c2'         | (no option) |
/// | Option group 3 | (no option) | 'd2'         | (no option) |
///
/// So, in this example, the user would pick
///
/// * 'a1', 'a2', or 'a3' for row 0;
/// * 'b1', 'b2', or 'b3' for row 1;
/// * 'c1' or 'c2' for row 2; and
/// * 'd2' for row 3;
///
@freezed
abstract class RecommendationCategory with _$RecommendationCategory {
  RecommendationCategory._();

  factory RecommendationCategory({
    /// Title of this category.
    required String categoryTitle,

    /// Contains answers for Good Health choices.
    required List<String> goodHealth,

    /// Contains answers for Better Health choices.
    required List<String> betterHealth,

    /// Contains answers for Best Health choices.
    required List<String> bestHealth,
  }) = _RecommendationCategory;

  /// Creates an instance from a JSON mapping.
  factory RecommendationCategory.fromJson(Map<String, Object?> json) =>
      _$RecommendationCategoryFromJson(json);

  /// Number of option groups this has.
  late final int optionGroupCount = max(
    goodHealth.length,
    max(betterHealth.length, bestHealth.length),
  );

  /// Immutable list of option groups to select a recommendation from.
  late final List<({String? good, String? better, String? best})> optionGroups =
      [
        for (var i = 0; i < optionGroupCount; i++)
          (
            good: (i < goodHealth.length) ? goodHealth[i] : null,
            better: (i < betterHealth.length) ? betterHealth[i] : null,
            best: (i < bestHealth.length) ? bestHealth[i] : null,
          ),
      ];
}
