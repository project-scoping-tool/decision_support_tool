import 'dart:collection';

import 'package:decision_support_tool/data/assessments_repository.dart';
import 'package:decision_support_tool/data/form_data_models.dart';
import 'package:decision_support_tool/data/static_data_models.dart';
import 'package:decision_support_tool/ui/assessment_view_model.dart';
import 'package:decision_support_tool/ui/function_value_notifier.dart';
import 'package:flutter/foundation.dart';

/// View model for a question section page.
///
/// The lifetime of this view model starts when the user starts an assessment
/// and ends if the user decides to switch jursidictions, in which case, this
/// instance should be discarded. Thus, the methods and fields of this class
/// assume that the jurisdiction will not be changed.
class QuestionSectionViewModel {
  /// Creates an new instance.
  QuestionSectionViewModel({
    required AssessmentsRepository assessmentsRepository,
    required AssessmentViewModel assessmentsViewModel,
    required this.sectionIndex,
  }) : _assessmentsRepository = assessmentsRepository,
       _assessmentsViewModel = assessmentsViewModel;

  /// Single source of truth for assessment data (static data and form data).
  final AssessmentsRepository _assessmentsRepository;

  /// Assessments view model (the parent of this view model).
  final AssessmentViewModel _assessmentsViewModel;

  /// Index of the section this view model corresponds to.
  final int sectionIndex;

  /// FormData object
  late final StaticData _staticData = _assessmentsRepository.staticData!;

  /// FormData object
  late final FormData _formData = _assessmentsRepository.formData!;

  /// AssessmentInfo object to use.
  late final AssessmentInfo assessmentInfo =
      _staticData.assessmentInfoMap[_formData.assessmentInfoId!]!;

  /// List of QuestionInfo objects to use.
  late final List<QuestionInfo> questionInfos = assessmentInfo.getQuestionInfos(
    _staticData.questionInfoMap,
  )[sectionIndex];

  /// List of the indices of selected answers.
  late final List<ValueListenable<int?>> selectedAnswerIndices =
      UnmodifiableListView(_selectedAnswerIndices);
  late final List<FunctionNotifier<int?>> _selectedAnswerIndices = [
    for (var i = 0; i < questionInfos.length; i++)
      FunctionNotifier(
        () => _formData.selectedAnswerIndices[sectionIndex][i],
        (newValue) =>
            _formData.selectedAnswerIndices[sectionIndex][i] = newValue,
      ),
  ];

  /// Notified whenever any answer is changed for this section.
  late final Listenable anyAnswerChanged = Listenable.merge(
    selectedAnswerIndices,
  );

  /// Gets the points sum of this section.
  double get pointsSum {
    double sum = 0.0;
    for (final (questionIndex, selectedAnswerIndex)
        in _selectedAnswerIndices.indexed) {
      final selectedAnswerIndexValue = selectedAnswerIndex.value;
      if (selectedAnswerIndexValue != null) {
        sum += questionInfos[questionIndex]
            .answers[selectedAnswerIndexValue]
            .points;
      }
    }
    return sum;
  }

  /// List of the booleans representing if a instructions section should be
  /// expanded or not.
  late final List<ValueListenable<bool>> expandedBools = UnmodifiableListView(
    _expandedBools,
  );
  late final List<ValueNotifier<bool>> _expandedBools = [
    for (var i = 0; i < questionInfos.length; i++) ValueNotifier(false),
  ];

  /// True if all questions have been answered.
  bool get isAllQuestionsAnswered =>
      _selectedAnswerIndices.every((n) => n.value != null);

  /// True if this is the last question section.
  late final bool isLastQuestionSection =
      sectionIndex == assessmentInfo.questionInfoIds.length - 1;

  /// True to show the recommendation dialog box; false otherwise.
  final ValueNotifier<bool> isShowingRecommendationDialog = ValueNotifier(
    false,
  );

  /// Track whether parks data is being fetched
  final ValueNotifier<bool> isFetchingParksData = ValueNotifier(false);

  /// ValueNotifier for project address to trigger UI updates
  late final ValueNotifier<String> projectAddress = ValueNotifier(
    assessmentInfo.projectAddress ?? '',
  );

  /// Called to dispose any resources of this view model.
  void dispose() {
    for (final notifier in _expandedBools) notifier.dispose();
    for (final notifier in _selectedAnswerIndices) notifier.dispose();
    isFetchingParksData.dispose(); // Dispose parks fetching notifier
    projectAddress.dispose(); // Dispose project address notifier
  }

  /// Select an answer
  void selectAnswer(int questionIndex, int? selectedAnswerIndex) {
    _selectedAnswerIndices[questionIndex].value = selectedAnswerIndex;
  }

  /// Expand/collapse instructions
  void expandInstructions(int questionIndex, bool expanded) {
    _expandedBools[questionIndex].value = expanded;
  }

  /// Goes to the previous page
  void goToPreviousPage() {
    _assessmentsViewModel.goToPreviousPage();
  }

  /// Goes to the next page.
  void goToNextPage() {
    _assessmentsViewModel.goToNextPage();
  }

  /// Gets the infrastructure recommendation code and text
  ({int recommendedCode, String recommendedText})
  getInfrastructureRecommendation() =>
      _assessmentsViewModel.getInfrastructureRecommendation();

  /// Set the fetching parks data state
  void setFetchingParksData(bool fetching) {
    isFetchingParksData.value = fetching;
  }

  /// Set the project address
  void setProjectAddress(String address) {
    projectAddress.value = address;
    // Note: You may want to persist this to your repository/database
    // For now, we're just updating the in-memory value
  }
}
