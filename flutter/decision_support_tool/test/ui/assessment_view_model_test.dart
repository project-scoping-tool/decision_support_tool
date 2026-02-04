import 'package:decision_support_tool/data/assessments_repository.dart';
import 'package:decision_support_tool/ui/assessment_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/testing_helpers.dart';
import '../../testing/testing_mocks.dart';
import '../../testing/testing_values.dart';

void main() {
  late AssessmentsRepository repository;
  late AssessmentViewModel viewModel;

  // Arrange
  setUp(() {
    repository = MockAssessmentsRepository(
      staticDataToBeLoaded: testStaticData1,
    );
    viewModel = AssessmentViewModel(assessmentsRepository: repository);
  });

  test('AssessmentViewModel.load()', () async {
    // Act
    final loadedValueBeforeLoad = viewModel.loaded.value;
    await viewModel.load();
    final loadedValueAfterLoad = viewModel.loaded.value;

    // Assert
    expectFalse(loadedValueBeforeLoad);
    expectTrue(loadedValueAfterLoad);
  });

  test('AssessmentViewModel.page', () async {
    // Act
    await viewModel.load();
    final pageValue1 = viewModel.page.value;
    viewModel.goToNextPage();
    final pageValue2 = viewModel.page.value;
    viewModel.goToNextPage();
    final pageValue3 = viewModel.page.value;
    viewModel.goToNextPage();
    final pageValue4 = viewModel.page.value;
    viewModel.goToPreviousPage();
    final pageValue5 = viewModel.page.value;
    viewModel.goToPreviousPage();
    final pageValue6 = viewModel.page.value;
    viewModel.goToPreviousPage();
    final pageValue7 = viewModel.page.value;

    // Assert
    expectEqual(pageValue1, 0);
    expectEqual(pageValue2, 1);
    expectEqual(pageValue3, 2);
    expectEqual(pageValue4, 3);
    expectEqual(pageValue5, 2);
    expectEqual(pageValue6, 1);
    expectEqual(pageValue7, 0);
  });

  test('AssessmentViewModel select jurisdiction', () async {
    // Act
    await viewModel.load();
    final index0 = viewModel.selectedJurisdictionIndex.value;
    viewModel.selectJurisdiction(0);
    final index1 = viewModel.selectedJurisdictionIndex.value;
    viewModel.selectJurisdiction(1);
    final index2 = viewModel.selectedJurisdictionIndex.value;
    viewModel.selectJurisdiction(null);
    final index3 = viewModel.selectedJurisdictionIndex.value;
    // Assert
    expectEqual(index0, null);
    expectEqual(index1, 0);
    expectEqual(index2, 1);
    expectEqual(index3, null);
  });

  test('AssessmentViewModel.startAssessment()', () async {
    // Act
    await viewModel.load();
    final questionSectionViewModels1 = [...viewModel.questionSectionViewModels];
    final recommendationsViewModel1 = viewModel.recommendationsViewModel;

    viewModel.selectJurisdiction(0);
    await viewModel.startAssessment();
    final questionSectionViewModels2 = [...viewModel.questionSectionViewModels];
    final recommendationsViewModel2 = viewModel.recommendationsViewModel;

    viewModel.selectJurisdiction(1);
    await viewModel.startAssessment();
    final questionSectionViewModels3 = [...viewModel.questionSectionViewModels];
    final recommendationsViewModel3 = viewModel.recommendationsViewModel;

    final selectedAnswerIndicesA =
        questionSectionViewModels3[0].selectedAnswerIndices;
    final selectedAnswerIndicesB =
        questionSectionViewModels3[1].selectedAnswerIndices;

    final formData = repository.formData!;

    // Assert
    expectEqual(questionSectionViewModels1.length, 0);
    expectEqual(questionSectionViewModels2.length, 2);
    expectEqual(questionSectionViewModels3.length, 2);
    expectFalse(
      identical(questionSectionViewModels2[0], questionSectionViewModels3[0]),
    );
    expectFalse(
      identical(questionSectionViewModels2[1], questionSectionViewModels3[1]),
    );

    expect(recommendationsViewModel1, isNull);
    expect(recommendationsViewModel2, isNotNull);
    expect(recommendationsViewModel3, isNotNull);
    expectFalse(
      identical(recommendationsViewModel2, recommendationsViewModel3),
    );

    expectTrue(selectedAnswerIndicesA.isNotEmpty);
    expectTrue(selectedAnswerIndicesB.isNotEmpty);

    expectEqual(formData.assessmentInfoId, 'ai2');
    expectEqual(formData.selectedAnswerIndices, [
      [null, null],
      [null, null, null],
    ]);
    expectEqual(formData.selectedRecommendationIndices, [
      [null, null],
      [null, null],
      [null],
    ]);
    expectEqual(formData.justifications, ['', '', '']);
  });
}
