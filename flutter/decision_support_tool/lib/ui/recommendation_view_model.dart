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
    // print('=== RECOMMENDATIONS VIEW MODEL CONSTRUCTOR ===');
    // print('Step 1 Points: ${assessmentsViewModel.step1Points}');
    // print('Step 2 Points: ${assessmentsViewModel.step2Points}');
    // print('NOTE: Recommendation will be evaluated when first accessed');
    // print('===============================================');

    // Determine highlight when recommendation is first accessed
    // This is now done in the infrastructureRecommendation getter
  }

  /// Single source of truth for assessment data (static data and form data).
  final AssessmentsRepository _assessmentsRepository;

  /// Parent view model (the assessments view model).
  final AssessmentViewModel _assessmentsViewModel;

  /// Public access to the assessments view model
  AssessmentViewModel get assessmentsViewModel => _assessmentsViewModel;

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

  /// Step 1 label — always reflects the current step1Points, using the same
  /// Low/Medium/High boundaries ([classifyNeedLevel]) the recommendation
  /// itself is computed from.
  String get step1Label =>
      switch (classifyNeedLevel(_assessmentsViewModel.step1Points)) {
        NeedLevel.low => 'Low Need',
        NeedLevel.medium => 'Medium Need',
        NeedLevel.high => 'High Need',
      };

  /// Step 2 label — always reflects the current step2Points, using the same
  /// Below/Average/Above Average boundaries ([classifyInfrastructureLevel])
  /// the recommendation itself is computed from.
  String get step2Label => switch (classifyInfrastructureLevel(
    _assessmentsViewModel.step2Points,
  )) {
    InfrastructureLevel.belowAverage => 'Below Average',
    InfrastructureLevel.average => 'Average',
    InfrastructureLevel.aboveAverage => 'Above Average',
  };

  /// Infrastructure recommendation. Delegates straight to
  /// [AssessmentViewModel.getInfrastructureRecommendation], which caches
  /// and invalidates itself whenever a Step 1/2 answer changes — so this
  /// always reflects the current answers without a second, independent
  /// cache here that could go stale on its own.
  ({int recommendedCode, String recommendedText})
  get infrastructureRecommendation =>
      _assessmentsViewModel.getInfrastructureRecommendation();

  /// Notified whenever any Step 1 or Step 2 answer changes. Used by
  /// [RecommendationsPage] to rebuild when the user edits an earlier
  /// answer and returns to this page, so the displayed recommendation/
  /// labels/highlighting stay in sync with [infrastructureRecommendation].
  late final Listenable answersChanged = Listenable.merge([
    for (final questionSectionViewModel
        in _assessmentsViewModel.questionSectionViewModels)
      questionSectionViewModel.anyAnswerChanged,
  ]);

  // Highlight state — pure functions of infrastructureRecommendation's
  // code, mirroring the code->column mapping:
  //   0: Minimal (none)   1: Good   2: Better   3: Best
  //   4: >= Good (Good+Better+Best)   5: >= Better (Better+Best)
  bool get isHighlightingGoodColumn =>
      const {1, 4}.contains(infrastructureRecommendation.recommendedCode);
  bool get isHighlightingBetterColumn =>
      const {2, 4, 5}.contains(infrastructureRecommendation.recommendedCode);
  bool get isHighlightingBestColumn =>
      const {3, 4, 5}.contains(infrastructureRecommendation.recommendedCode);

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
