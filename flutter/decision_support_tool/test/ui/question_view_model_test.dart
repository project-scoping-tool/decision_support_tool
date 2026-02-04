import 'package:decision_support_tool/data/assessments_repository.dart';
import 'package:decision_support_tool/data/form_data_models.dart';
import 'package:decision_support_tool/ui/assessment_view_model.dart';
import 'package:decision_support_tool/ui/question_section_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/testing_helpers.dart';
import '../../testing/testing_mocks.dart';
import '../../testing/testing_values.dart';

void main() {
  late AssessmentsRepository repository;
  late AssessmentViewModel assessmentsViewModel;
  late QuestionSectionViewModel viewModel0;
  late QuestionSectionViewModel viewModel1;

  // Arrange
  setUp(() {
    repository = MockAssessmentsRepository(
      staticDataToBeLoaded: testStaticData1,
    );

    assessmentsViewModel = MockAssessmentsViewModel();
    viewModel0 = QuestionSectionViewModel(
      assessmentsViewModel: assessmentsViewModel,
      assessmentsRepository: repository,
      sectionIndex: 0,
    );
    viewModel1 = QuestionSectionViewModel(
      assessmentsViewModel: assessmentsViewModel,
      assessmentsRepository: repository,
      sectionIndex: 1,
    );
  });

  test('QuestionSectionViewModel info objects and notifier lists', () async {
    // Act
    await repository.loadStaticData();
    repository.formData = FormData.empty().copyWith(assessmentInfoId: 'ai1');

    final assessmentInfo0 = viewModel0.assessmentInfo;
    final assessmentInfo1 = viewModel1.assessmentInfo;
    final questionInfos0 = viewModel0.questionInfos;
    final questionInfos1 = viewModel1.questionInfos;
    final selectedAnswerIndices0 = viewModel0.selectedAnswerIndices;
    final selectedAnswerIndices1 = viewModel1.selectedAnswerIndices;
    final expandedBools0 = viewModel0.expandedBools;
    final expandedBools1 = viewModel1.expandedBools;

    // Assert
    expectEqual(assessmentInfo0, testStaticData1.assessmentInfoMap['ai1']!);
    expectEqual(assessmentInfo1, testStaticData1.assessmentInfoMap['ai1']!);
    expectEqual(questionInfos0, [
      testStaticData1.questionInfoMap['qi1']!,
      testStaticData1.questionInfoMap['qi2']!,
      testStaticData1.questionInfoMap['qi3']!,
    ]);
    expectEqual(questionInfos1, [
      testStaticData1.questionInfoMap['qi1']!,
      testStaticData1.questionInfoMap['qi2']!,
    ]);
    expectEqual(selectedAnswerIndices0.length, 3);
    expectEqual(expandedBools0.length, 3);
    expectEqual(selectedAnswerIndices1.length, 2);
    expectEqual(expandedBools1.length, 2);
  });

  test('QuestionSectionViewModel notifier updates', () async {
    // Act
    await repository.loadStaticData();
    repository.formData = FormData.empty().copyWith(assessmentInfoId: 'ai1');

    final assessmentInfo0 = viewModel0.assessmentInfo;
    final assessmentInfo1 = viewModel1.assessmentInfo;
    final questionInfos0 = viewModel0.questionInfos;
    final questionInfos1 = viewModel1.questionInfos;
    final selectedAnswerIndices0 = viewModel0.selectedAnswerIndices;
    final selectedAnswerIndices1 = viewModel1.selectedAnswerIndices;
    final expandedBools0 = viewModel0.expandedBools;
    final expandedBools1 = viewModel1.expandedBools;

    // Assert
    expectEqual(assessmentInfo0, testStaticData1.assessmentInfoMap['ai1']!);
    expectEqual(assessmentInfo1, testStaticData1.assessmentInfoMap['ai1']!);
    expectEqual(questionInfos0, [
      testStaticData1.questionInfoMap['qi1']!,
      testStaticData1.questionInfoMap['qi2']!,
      testStaticData1.questionInfoMap['qi3']!,
    ]);
    expectEqual(questionInfos1, [
      testStaticData1.questionInfoMap['qi1']!,
      testStaticData1.questionInfoMap['qi2']!,
    ]);
    expectEqual(selectedAnswerIndices0.length, 3);
    expectEqual(expandedBools0.length, 3);
    expectEqual(selectedAnswerIndices1.length, 2);
    expectEqual(expandedBools1.length, 2);
  });

  test('QuestionSectionViewModel selectedAnswerIndices updates', () async {
    // Act
    await repository.loadStaticData();
    repository.formData = FormData.empty().copyWith(
      assessmentInfoId: 'ai1',
      selectedAnswerIndices: [
        [null, null, null],
        [null, null],
      ],
    );

    final indices0a = [...repository.formData!.selectedAnswerIndices[0]];
    final indices1a = [...repository.formData!.selectedAnswerIndices[1]];
    viewModel0.selectAnswer(0, 0);
    viewModel0.selectAnswer(1, 1);
    viewModel0.selectAnswer(2, 2);
    viewModel1.selectAnswer(0, 3);
    viewModel1.selectAnswer(1, 4);
    final indices0b = [...repository.formData!.selectedAnswerIndices[0]];
    final indices1b = [...repository.formData!.selectedAnswerIndices[1]];
    viewModel0.selectAnswer(0, 5);
    viewModel0.selectAnswer(1, 6);
    viewModel0.selectAnswer(2, 7);
    viewModel1.selectAnswer(0, 8);
    viewModel1.selectAnswer(1, null);
    final indices0c = [...repository.formData!.selectedAnswerIndices[0]];
    final indices1c = [...repository.formData!.selectedAnswerIndices[1]];

    // Assert
    expectEqual(indices0a, [null, null, null]);
    expectEqual(indices1a, [null, null]);
    expectEqual(indices0b, [0, 1, 2]);
    expectEqual(indices1b, [3, 4]);
    expectEqual(indices0c, [5, 6, 7]);
    expectEqual(indices1c, [8, null]);
  });
}
