import 'package:decision_support_tool/data/assessments_repository.dart';
import 'package:decision_support_tool/data/local_data_service.dart';
import 'package:decision_support_tool/data/static_data_models.dart';
import 'package:decision_support_tool/data/form_data_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/testing_helpers.dart';
import '../../testing/testing_values.dart';
import '../../testing/testing_mocks.dart';

/// Main entry point function.
void main() {
  late LocalDataService service;
  late AssessmentsRepository repository;

  setUp(() {
    service = MockLocalDataService();
    repository = AssessmentsRepositoryLocal(localDataService: service);
  });

  test('AssessmentsRepository static data', () async {
    // Act
    final staticDataBeforeLoad = repository.staticData;
    await repository.loadStaticData();
    final staticDataAfterLoad = repository.staticData;

    // Assert
    expectEqual<StaticData?>(staticDataBeforeLoad, null);
    expectEqual<StaticData?>(staticDataAfterLoad, testStaticData1);
  });

  test('AssessmentsRepository form data modifiability', () async {
    // Act
    final formData1 = repository.formData;
    repository.formData = FormData.empty();
    final formData2 = repository.formData!.copyWith();
    repository.formData!.assessmentInfoId = 'modified-id';
    final formData3 = repository.formData!.copyWith();

    // Assert
    expectEqual<FormData?>(formData1, null);
    expectEqual(formData2.assessmentInfoId, null);
    expectEqual(formData3.assessmentInfoId, 'modified-id');
  });
}
