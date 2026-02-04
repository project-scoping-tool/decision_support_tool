import 'package:decision_support_tool/data/assessments_repository.dart';
import 'package:decision_support_tool/data/form_data_models.dart';
import 'package:decision_support_tool/ui/assessment_view_model.dart';
import 'package:decision_support_tool/ui/recommendation_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/testing_helpers.dart';
import '../../testing/testing_mocks.dart';
import '../../testing/testing_values.dart';

void main() {
  late AssessmentsRepository repository;
  late AssessmentViewModel assessmentsViewModel;
  late RecommendationsViewModel viewModel;

  // Arrange
  setUp(() {
    repository = MockAssessmentsRepository(
      staticDataToBeLoaded: testStaticData1,
    );
    assessmentsViewModel = MockAssessmentsViewModel();

    viewModel = RecommendationsViewModel(
      assessmentsRepository: repository,
      assessmentsViewModel: assessmentsViewModel,
    );
  });

  test(
    'QuestionSectionViewModel selectedRecommendationIndices updates',
    () async {
      // Act
      await repository.loadStaticData();
      repository.formData = FormData.empty().copyWith(
        assessmentInfoId: 'ai1',
        selectedRecommendationIndices: [
          [null, null, null],
          [null, null, null],
        ],
      );

      final indicesA = [
        for (final list in repository.formData!.selectedRecommendationIndices)
          [...list],
      ];
      viewModel.selectRecommmendation(0, 0, 0);
      viewModel.selectRecommmendation(0, 1, 1);
      viewModel.selectRecommmendation(0, 2, 2);
      viewModel.selectRecommmendation(1, 0, 2);
      viewModel.selectRecommmendation(1, 1, 1);
      viewModel.selectRecommmendation(1, 2, 0);
      final indicesB = [
        for (final list in repository.formData!.selectedRecommendationIndices)
          [...list],
      ];
      viewModel.selectRecommmendation(0, 0, 2);
      viewModel.selectRecommmendation(0, 1, 2);
      viewModel.selectRecommmendation(0, 2, 2);
      viewModel.selectRecommmendation(1, 0, null);
      viewModel.selectRecommmendation(1, 1, null);
      viewModel.selectRecommmendation(1, 2, null);
      final indicesC = [
        for (final list in repository.formData!.selectedRecommendationIndices)
          [...list],
      ];

      // Assert
      expectEqual(indicesA, [
        [null, null, null],
        [null, null, null],
      ]);
      expectEqual(indicesB, [
        [0, 1, 2],
        [2, 1, 0],
      ]);
      expectEqual(indicesC, [
        [2, 2, 2],
        [null, null, null],
      ]);
    },
  );

  test('QuestionSectionViewModel justifications updates', () async {
    // Act
    await repository.loadStaticData();
    repository.formData = FormData.empty().copyWith(
      assessmentInfoId: 'ai1',
      justifications: ['', ''],
    );

    final justificationsA = [...repository.formData!.justifications];
    viewModel.setJustification(0, 'j1');
    viewModel.setJustification(1, 'j2');
    final justificationsB = [...repository.formData!.justifications];
    viewModel.setJustification(0, 'j3');
    viewModel.setJustification(1, 'j4');
    final justificationsC = [...repository.formData!.justifications];

    // Assert
    expectEqual(justificationsA, ['', '']);
    expectEqual(justificationsB, ['j1', 'j2']);
    expectEqual(justificationsC, ['j3', 'j4']);
  });
}
