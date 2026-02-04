import 'package:decision_support_tool/data/local_data_service.dart';
import 'package:decision_support_tool/data/static_data_models.dart';
import 'package:decision_support_tool/data/form_data_models.dart';

/// Repository containing static data for all assessments and current form
/// data.
abstract class AssessmentsRepository {
  /// Static data for all the assessments, null if not loaded yet.
  StaticData? get staticData;
  /// Form data inputted by the user, null if not loaded yet.
  FormData? formData;
  /// Loads static data from some storage.
  Future<void> loadStaticData();
  /// Loads form data from some storage.
  Future<void> loadFormData();
  /// Saves form data to some storage.
  Future<void> saveFormData();
}

/// Assessments repository that loads and stores data in local storage.
class AssessmentsRepositoryLocal implements AssessmentsRepository {
  /// Creates a new instance with the given service.
  AssessmentsRepositoryLocal({required LocalDataService localDataService}) : _localDataService = localDataService;

  /// Service to load data from local storage.
  final LocalDataService _localDataService;

  /// Static data for all the assessments, null if not loaded yet.
  StaticData? get staticData => _staticData;
  StaticData? _staticData;

  /// Form data inputted by the user, null if not loaded yet.
  FormData? formData;

  /// Load static data from local storage.
  Future<void> loadStaticData() async {
    _staticData = await _localDataService.loadStaticData();
  }

  /// Load form data from local storage.
  Future<void> loadFormData() {
    // TODO: Implement save/load functionality
    throw UnimplementedError();
  }

  /// Save form data to local storage.
  Future<void> saveFormData() {
    // TODO: Implement save/load functionality
    throw UnimplementedError();
  }
}
