import 'package:freezed_annotation/freezed_annotation.dart';

part 'form_data_models.freezed.dart';
part 'form_data_models.g.dart';

// NOTE: Equality doesn't work that well for FormData between two different
//   instances but containing the same-valued fields. I'm not sure what is
//   causing it.

/// Mutable dataclass for user-inputted form data.
@unfreezed
abstract class FormData with _$FormData {
  factory FormData({
    /// AssessmentInfo ID, null if not chosen yet.
    required String? assessmentInfoId,

    /// Indices of the selected answers corresponding to each question.
    ///
    /// Each inner list represents an individual section, in which each
    /// element is an index corresponding to the selected answer, otherwise a
    /// null if no answer is selected yet.
    ///
    /// For example, `selectedAnswerIndices[0][2]` is the answer index
    /// corresponding to the third question in the first section.
    required List<List<int?>> selectedAnswerIndices,

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
    required List<List<int?>> selectedRecommendationIndices,

    /// User-inputted text for the justifications for the selected
    /// recommendations in each category.
    ///
    /// For example, `justifications[2]` is the justification text
    /// corresponding to the third recommendation category.
    required List<String> justifications,
  }) = _FormData;

  /// Creates an instance from a JSON mapping.
  factory FormData.fromJson(Map<String, Object?> json) =>
      _$FormDataFromJson(json);

  /// Creates an empty FormData instance.
  factory FormData.empty() => FormData(
    assessmentInfoId: null,
    selectedAnswerIndices: [],
    selectedRecommendationIndices: [],
    justifications: [],
  );
}

/// Gets a list of sizes corresponding to each list in a 2D jagged list.
///
/// For example, `shape([['a', 'b', 'c'], [], ['x', 'y']])` returns `[3, 0, 2]`.
List<int> shape<T>(List<List<T>> list2d) => [
  for (final section in list2d) section.length,
];
