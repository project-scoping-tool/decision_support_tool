import 'package:decision_support_tool/config.dart';
import 'package:decision_support_tool/data/static_data_models.dart';
import 'package:decision_support_tool/data/form_data_models.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:toml/toml.dart';

/// Service for accessing local data (e.g. assets, local data storage)
class LocalDataService {
  /// Creates a StaticData object by reading from the application's assets from
  /// local storage.
  Future<StaticData> loadStaticData() async {
    final assetList = await _getAssetListFromRootBundle();
    return StaticData(
      assessmentInfoMap: await _getInfoMap(
        assetList,
        Assets.assessmentInfoDir,
        AssessmentInfo.fromJson,
      ),
      questionInfoMap: await _getInfoMap(
        assetList,
        Assets.questionInfoDir,
        QuestionInfo.fromJson,
      ),
      recommendationsInfoMap: await _getInfoMap(
        assetList,
        Assets.recommendationsInfoDir,
        RecommendationsInfo.fromJson,
      ),
    );
  }

  /// Generates a mapping of information object IDs to information objects.
  ///
  /// Parameters:
  ///
  /// * `assetList`: List of asset file paths
  /// * `dir`: Directory to look for files in.
  /// * `fromJson`: Function to convert a JSON mapping into an information
  ///   object.
  Future<Map<String, T>> _getInfoMap<T>(
    List<String> assetList,
    String dir,
    T Function(Map<String, Object?>) fromJson,
  ) async {
    final map = <String, T>{};
    for (final path in _filterPaths(assetList, dir)) {
      final id = p.basenameWithoutExtension(path);
      final json = await _loadToml(path);
      try {
        map[id] = fromJson(json);
      } on AssertionError catch (e) {
        throw AssertionError(
          'AssertionError while loading ${path}: ${e.message}',
        );
      }
    }
    return map;
  }

  /// Filters an iterable of file paths to keep .toml files and paths starting
  /// with a specific prefix.
  Iterable<String> _filterPaths(Iterable<String> paths, String prefix) =>
      paths.where((path) => path.startsWith(prefix) && path.endsWith('.toml'));

  /// Gets the list of assets from the root bundle.
  Future<List<String>> _getAssetListFromRootBundle() async =>
      (await AssetManifest.loadFromAssetBundle(rootBundle)).listAssets();

  /// Loads a toml file and returns a JSON mapping.
  Future<Map<String, Object?>> _loadToml(String path) async =>
      TomlDocument.parse(await rootBundle.loadString(path)).toMap();

  // TODO: Eventually, the getFormData() and setFormData would use the user's
  //     local storage to save and load form data. So, if the user leaves the
  //     application, their data can be reloaded and the user can continue
  //     where they left off.

  /// Loads the form data in the user's local storage; yields null if none is
  /// saved.
  Future<FormData?> loadFormData() {
    throw UnimplementedError();
  }

  /// Saves the given form data in the user's local storage. Throws an error
  /// if unable to.
  Future<void> saveFormData(FormData formData) {
    throw UnimplementedError();
  }
}
