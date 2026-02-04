import 'package:decision_support_tool/data/assessments_repository.dart';
import 'package:decision_support_tool/data/local_data_service.dart';
import 'package:decision_support_tool/data/static_data_models.dart';
import 'package:decision_support_tool/data/form_data_models.dart';
import 'package:decision_support_tool/ui/assessment_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testing_values.dart';

/// Mock local data service
class MockLocalDataService implements LocalDataService {
  @override
  Future<StaticData> loadStaticData() async {
    return testStaticData1;
  }

  @override
  Future<FormData?> loadFormData() {
    // TODO: implement mock getFormData
    throw UnimplementedError();
  }

  @override
  Future<void> saveFormData(FormData formData) {
    // TODO: implement mock setFormData
    throw UnimplementedError();
  }
}

/// Mock Assessments Repository
class MockAssessmentsRepository implements AssessmentsRepository {
  MockAssessmentsRepository({required this.staticDataToBeLoaded});

  StaticData? staticDataToBeLoaded;
  StaticData? staticData;
  FormData? formData;

  @override
  Future<void> loadStaticData() async => staticData = staticDataToBeLoaded;

  @override
  Future<void> loadFormData() async {
    throw UnimplementedError();
  }

  @override
  Future<void> saveFormData() async {
    throw UnimplementedError();
  }
}

class MockAssessmentsViewModel extends Fake implements AssessmentViewModel {
  @override
  ({int recommendedCode, String recommendedText})
  getInfrastructureRecommendation() {
    return (recommendedCode: 100, recommendedText: "TEST recommendText");
  }
}
