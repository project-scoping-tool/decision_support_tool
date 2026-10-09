import 'dart:collection';
import 'package:decision_support_tool/data/assessments_repository.dart';
import 'package:decision_support_tool/data/form_data_models.dart';
import 'package:decision_support_tool/data/static_data_models.dart';
import 'package:decision_support_tool/ui/recommendation_view_model.dart';
import 'package:decision_support_tool/ui/question_section_view_model.dart';
import 'package:flutter/foundation.dart';

/// Step 1 (existing need) classification.
enum NeedLevel { low, medium, high }

/// Step 2 (existing infrastructure) classification.
enum InfrastructureLevel { belowAverage, average, aboveAverage }

/// Single source of truth for the Step 1 Low/Medium/High boundaries.
/// Used both to compute the recommendation ([AssessmentViewModel
/// .getInfrastructureRecommendation]) and to derive the displayed
/// "Existing Need" label ([RecommendationsViewModel.step1Label]), so the
/// two cannot diverge.
NeedLevel classifyNeedLevel(double points) {
  if (points < 18) return NeedLevel.low;
  if (points < 33) return NeedLevel.medium;
  return NeedLevel.high;
}

/// Single source of truth for the Step 2 Below/Average/Above Average
/// boundaries. Used both to compute the recommendation and to derive the
/// displayed "Existing Infrastructure" label.
InfrastructureLevel classifyInfrastructureLevel(double points) {
  if (points < 18) return InfrastructureLevel.belowAverage;
  if (points < 33) return InfrastructureLevel.average;
  return InfrastructureLevel.aboveAverage;
}

/// View model for the entire Assessments page.
class AssessmentViewModel {
  /// Creates a new instance.
  AssessmentViewModel({required AssessmentsRepository assessmentsRepository})
    : _assessmentsRepository = assessmentsRepository {
    _assessmentsRepository.formData = FormData.empty();
  }

  /// Static data containing information about all of the assessments.
  StaticData? get staticData => _assessmentsRepository.staticData;

  /// Single source of truth for assessment data (static data and form data).
  final AssessmentsRepository _assessmentsRepository;

  /// True, if the assessment view has fully loaded its static and form data.
  ValueListenable<bool> get loaded => _loaded;
  final ValueNotifier<bool> _loaded = ValueNotifier(false);

  /// Variable to store the _load() future, null if not called yet.
  Future<void>? _loadFuture;

  /// Represents which page of the application it is on.
  ValueListenable<int> get page => _page;
  final ValueNotifier<int> _page = ValueNotifier(0);

  /// Index of the selected jurisdiction, null if none is selected.
  ValueListenable<int?> get selectedJurisdictionIndex =>
      _selectedJurisdictionIndex;
  final ValueNotifier<int?> _selectedJurisdictionIndex = ValueNotifier(null);

  /// View models of the questionnaire sections, empty if assessment has not
  /// yet started.
  late final List<QuestionSectionViewModel> questionSectionViewModels =
      UnmodifiableListView(_questionSectionViewModels);
  final List<QuestionSectionViewModel> _questionSectionViewModels = [];

  /// View models of the recommendations page, null if assessment has not yet
  /// started.
  RecommendationsViewModel? get recommendationsViewModel =>
      _recommendationsViewModel;
  RecommendationsViewModel? _recommendationsViewModel;

  /// True if the assessment has started.
  ValueListenable<bool> get hasStartedAssessment => _hasStartedAssessment;
  final ValueNotifier<bool> _hasStartedAssessment = ValueNotifier(false);

  /// Total points from step 1
  double get step1Points => _questionSectionViewModels[0].pointsSum;

  /// Total points from step 2
  double get step2Points => _questionSectionViewModels[1].pointsSum;

  // ADDED: Cache for the recommendation to ensure consistency
  ({int recommendedCode, String recommendedText})? _cachedRecommendation;
  double? _cachedStep1Points;
  double? _cachedStep2Points;

  /// Loads static and form data, if it hasn't already.
  Future<void> load() => _loadFuture ??= _load();

  /// Internal method to load static and form data.
  Future<void> _load() async {
    await _assessmentsRepository.loadStaticData();
    _loaded.value = true;
  }

  /// Go to the previous page.
  void goToPreviousPage() {
    _page.value--;
  }

  /// Go to the next page.
  void goToNextPage() {
    _page.value++;
  }

  /// Selects a jurisdiction by index, null if not selected.
  void selectJurisdiction(int? index) {
    _selectedJurisdictionIndex.value = index;
  }

  /// Starts the assessment.
  Future<void> startAssessment() async {
    // Clear cached recommendation when starting new assessment
    _clearRecommendationCache();

    // Dispose and clear current view models.
    if (_questionSectionViewModels.isNotEmpty) {
      for (final viewModel in _questionSectionViewModels) viewModel.dispose();
      _questionSectionViewModels.clear();
    }
    if (_recommendationsViewModel != null) {
      _recommendationsViewModel!.dispose();
      _recommendationsViewModel = null;
    }

    // Populate form data.
    final staticData = _assessmentsRepository.staticData!;
    final formData = _assessmentsRepository.formData!;
    final assessmentInfoId = staticData
        .assessmentInfoPairsSorted[_selectedJurisdictionIndex.value!]
        .$1;
    formData.assessmentInfoId = assessmentInfoId;
    final assessmentInfo = staticData.assessmentInfoMap[assessmentInfoId]!;
    final recommendationsInfo = staticData
        .recommendationsInfoMap[assessmentInfo.recommendationsInfoId]!;

    formData.selectedAnswerIndices.clear();
    for (final section in assessmentInfo.questionInfoIds) {
      formData.selectedAnswerIndices.add(List.filled(section.length, null));
    }

    formData.selectedRecommendationIndices.clear();
    for (final category in recommendationsInfo.s3_categories) {
      formData.selectedRecommendationIndices.add(
        List.filled(category.optionGroupCount, null),
      );
    }

    formData.justifications.clear();
    for (final _ in recommendationsInfo.s3_categories) {
      formData.justifications.add('');
    }

    // Create new view models
    for (var i = 0; i < assessmentInfo.questionInfoIds.length; i++) {
      _questionSectionViewModels.add(
        QuestionSectionViewModel(
          assessmentsViewModel: this,
          assessmentsRepository: _assessmentsRepository,
          sectionIndex: i,
        ),
      );
    }

    _recommendationsViewModel = RecommendationsViewModel(
      assessmentsRepository: _assessmentsRepository,
      assessmentsViewModel: this,
    );

    // Mark that the assessment has started
    _hasStartedAssessment.value = true;
  }

  /// Gets the infrastructure recommendation code and text
  /// MODIFIED: Now uses caching to ensure consistency
  ({int recommendedCode, String recommendedText})
  getInfrastructureRecommendation() {
    // If already cached, return the cached value
    if (_cachedRecommendation != null) {
      print('=== RETURNING CACHED RECOMMENDATION ===');
      print('Cached Step 1 Points: $_cachedStep1Points');
      print('Cached Step 2 Points: $_cachedStep2Points');
      print('Cached Code: ${_cachedRecommendation!.recommendedCode}');
      print('Cached Text: ${_cachedRecommendation!.recommendedText}');
      print('Current Step 1 Points: ${step1Points}');
      print('Current Step 2 Points: ${step2Points}');
      print('========================================');
      return _cachedRecommendation!;
    }

    // Not cached yet - calculate it
    print('=== CALCULATING RECOMMENDATION (FIRST TIME) ===');
    final step1 = step1Points;
    final step2 = step2Points;
    print('Step 1 Points: $step1');
    print('Step 2 Points: $step2');

    // Classification is delegated to classifyNeedLevel()/
    // classifyInfrastructureLevel() (top of this file) — the single source
    // of truth for these boundaries, also used by RecommendationsViewModel
    // for the displayed "Existing Need"/"Existing Infrastructure" labels,
    // so the two can never diverge.
    final needLevel = classifyNeedLevel(step1);
    final infraLevel = classifyInfrastructureLevel(step2);

    final low = needLevel == NeedLevel.low;
    final medium = needLevel == NeedLevel.medium;
    final high = needLevel == NeedLevel.high;
    final belowAve = infraLevel == InfrastructureLevel.belowAverage;
    final average = infraLevel == InfrastructureLevel.average;
    final aboveAve = infraLevel == InfrastructureLevel.aboveAverage;

    print('Step 1 Classification: $needLevel');
    print('Step 2 Classification: $infraLevel');

    int recommendedCode;
    String recommendedText;

    // Determine final score for step 3
    if (low && belowAve) {
      recommendedCode = 5;
      recommendedText = '\u2265 Better';
      print('Recommendation Logic: LOW + BELOW AVERAGE → >= Better (5)');
    } else if (low && average) {
      recommendedCode = 4;
      recommendedText = '\u2265 Good';
      print('Recommendation Logic: LOW + AVERAGE → >= Good (4)');
    } else if (low && aboveAve) {
      recommendedCode = 0;
      recommendedText = 'Minimal potential for benefit';
      print('Recommendation Logic: LOW + ABOVE AVERAGE → Minimal (0)');
    } else if (medium && belowAve) {
      recommendedCode = 3;
      recommendedText = 'Best';
      print('Recommendation Logic: MEDIUM + BELOW AVERAGE → Best (3)');
    } else if (medium && average) {
      recommendedCode = 5;
      recommendedText = '\u2265 Better';
      print('Recommendation Logic: MEDIUM + AVERAGE → >= Better (5)');
    } else if (medium && aboveAve) {
      recommendedCode = 4;
      recommendedText = '\u2265 Good';
      print('Recommendation Logic: MEDIUM + ABOVE AVERAGE → >= Good (4)');
    } else if (high && belowAve) {
      recommendedCode = 3;
      recommendedText = 'Best';
      print('Recommendation Logic: HIGH + BELOW AVERAGE → Best (3)');
    } else if (high && average) {
      recommendedCode = 3;
      recommendedText = 'Best';
      print('Recommendation Logic: HIGH + AVERAGE → Best (3)');
    } else {
      recommendedCode = 3;
      recommendedText = 'Best';
      print('Recommendation Logic: HIGH + ABOVE AVERAGE → Best (3)');
    }

    // Cache the recommendation
    _cachedRecommendation = (
      recommendedCode: recommendedCode,
      recommendedText: recommendedText,
    );
    _cachedStep1Points = step1;
    _cachedStep2Points = step2;

    print('Calculated Code: $recommendedCode');
    print('Calculated Text: $recommendedText');
    print('CACHED for future use');
    print('================================================');

    return _cachedRecommendation!;
  }

  /// Clear the cached recommendation
  /// Call this when user goes back to edit Step 1 or Step 2
  void _clearRecommendationCache() {
    if (_cachedRecommendation != null) {
      print('=== CLEARING RECOMMENDATION CACHE ===');
      print('Was: ${_cachedRecommendation!.recommendedText}');
      print('=====================================');
    }
    _cachedRecommendation = null;
    _cachedStep1Points = null;
    _cachedStep2Points = null;
  }

  /// Public method to clear cache if needed (e.g., when going back to edit)
  void clearRecommendationCache() {
    _clearRecommendationCache();
  }
}
