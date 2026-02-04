import 'dart:collection';
import 'package:decision_support_tool/data/assessments_repository.dart';
import 'package:decision_support_tool/data/form_data_models.dart';
import 'package:decision_support_tool/data/static_data_models.dart';
import 'package:decision_support_tool/ui/assessment_view_model.dart';
import 'package:decision_support_tool/ui/function_value_notifier.dart';
import 'package:flutter/foundation.dart';

class RecommendationsViewModel {
  /// Creates an new instance.
  RecommendationsViewModel({
    required AssessmentsRepository assessmentsRepository,
    required AssessmentViewModel assessmentsViewModel,
  }) : _assessmentsRepository = assessmentsRepository,
       _assessmentsViewModel = assessmentsViewModel {
    // DON'T evaluate infrastructureRecommendation here - it will be evaluated lazily

    // Log the state when RecommendationsViewModel is created
    print('=== RECOMMENDATIONS VIEW MODEL CONSTRUCTOR ===');
    print('Step 1 Points: ${assessmentsViewModel.step1Points}');
    print('Step 2 Points: ${assessmentsViewModel.step2Points}');
    print('NOTE: Recommendation will be evaluated when first accessed');
    print('===============================================');

    // Determine highlight when recommendation is first accessed
    // This is now done in the infrastructureRecommendation getter
  }

  /// Single source of truth for assessment data (static data and form data).
  final AssessmentsRepository _assessmentsRepository;

  /// Parent view model (the assessments view model).
  final AssessmentViewModel _assessmentsViewModel;

  /// Go back to the previous page
  void goToPreviousPage() {
    _assessmentsViewModel.goToPreviousPage();
  }

  /// FormData object
  late final StaticData _staticData = _assessmentsRepository.staticData!;

  /// FormData object
  late final FormData _formData = _assessmentsRepository.formData!;

  /// AssessmentInfo object to use.
  late final AssessmentInfo assessmentInfo =
      _staticData.assessmentInfoMap[_formData.assessmentInfoId!]!;

  /// RecommendationsInfo object to use.
  late final RecommendationsInfo recommendationsInfo =
      _staticData.recommendationsInfoMap[assessmentInfo.recommendationsInfoId]!;

  /// List of the indices of selected answers.
  late final List<List<ValueListenable<int?>>> selectedRecommendationIndices =
      UnmodifiableListView([
        for (final list in _selectedRecommendationIndices)
          UnmodifiableListView(list),
      ]);

  late final List<List<FunctionNotifier<int?>>> _selectedRecommendationIndices =
      [
        for (final (i, category) in recommendationsInfo.s3_categories.indexed)
          [
            for (var j = 0; j < category.optionGroupCount; j++)
              FunctionNotifier(
                () => _formData.selectedRecommendationIndices[i][j],
                (newValue) =>
                    _formData.selectedRecommendationIndices[i][j] = newValue,
              ),
          ],
      ];

  /// List of justification strings
  late final List<ValueListenable<String>> justifications =
      UnmodifiableListView(_justifications);

  late final List<FunctionNotifier<String>> _justifications = [
    for (var i = 0; i < recommendationsInfo.s3_categories.length; i++)
      FunctionNotifier(
        () => _formData.justifications[i],
        (newValue) => _formData.justifications[i] = newValue,
      ),
  ];

  /// Step 1 label - lazily evaluated
  late final String step1Label = _pointsToLabelStep1(
    _assessmentsViewModel.step1Points,
  );

  /// Step 2 label - lazily evaluated
  late final String step2Label = _pointsToLabelStep2(
    _assessmentsViewModel.step2Points,
  );

  /// Infrastructure recommendation - lazily evaluated when first accessed
  late final ({int recommendedCode, String recommendedText})
  infrastructureRecommendation = _getRecommendation();

  /// True to highlight good column
  bool isHighlightingGoodColumn = false;

  /// True to highlight better column
  bool isHighlightingBetterColumn = false;

  /// True to highlight best column
  bool isHighlightingBestColumn = false;

  /// Private method to get and cache the recommendation
  ({int recommendedCode, String recommendedText}) _getRecommendation() {
    print('=== EVALUATING RECOMMENDATION (lazy late final) ===');
    final recommendation = _assessmentsViewModel
        .getInfrastructureRecommendation();

    print('Recommendation Code: ${recommendation.recommendedCode}');
    print('Recommendation Text: ${recommendation.recommendedText}');

    // Determine highlight based on recommendation
    //   0: Minimal (none)
    //   1: Good
    //   2: Better
    //   3: Best
    //   4: >= Good
    //   5: >= Better
    switch (recommendation.recommendedCode) {
      case 1:
        isHighlightingGoodColumn = true;
        break;
      case 2:
        isHighlightingBetterColumn = true;
        break;
      case 3:
        isHighlightingBestColumn = true;
        break;
      case 4:
        isHighlightingGoodColumn = true;
        isHighlightingBetterColumn = true;
        isHighlightingBestColumn = true;
        break;
      case 5:
        isHighlightingBetterColumn = true;
        isHighlightingBestColumn = true;
        break;
    }

    print('Highlighting Good Column: $isHighlightingGoodColumn');
    print('Highlighting Better Column: $isHighlightingBetterColumn');
    print('Highlighting Best Column: $isHighlightingBestColumn');
    print('====================================================');

    return recommendation;
  }

  /// Step 1 points to label function
  static String _pointsToLabelStep1(double points) {
    if (points <= 17) {
      return 'Low Need';
    } else if (points <= 32) {
      return 'Medium Need';
    } else {
      return 'High Need';
    }
  }

  /// Step 2 points to label label
  static String _pointsToLabelStep2(double points) {
    if (points <= 17) {
      return 'Below Average';
    } else if (points <= 32) {
      return 'Average';
    } else {
      return 'Above Average';
    }
  }

  /// Select recommendation
  void selectRecommmendation(
    int categoryIndex,
    int optionSetIndex,
    int? selectedIndex,
  ) {
    _selectedRecommendationIndices[categoryIndex][optionSetIndex].value =
        selectedIndex;
  }

  /// Set justification string
  void setJustification(int categoryIndex, String justification) {
    _justifications[categoryIndex].value = justification;
  }

  /// Called to dispose any resources of this view model.
  void dispose() {
    for (final list in _selectedRecommendationIndices) {
      for (final notifier in list) notifier.dispose();
    }
  }
}
