import 'package:decision_support_tool/config.dart';
import 'package:decision_support_tool/data/local_data_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../testing/testing_helpers.dart';

/// Get the assets list.
Future<List<String>> _getAssetsList() async =>
    (await AssetManifest.loadFromAssetBundle(rootBundle)).listAssets();

/// Get assets starting with the given prefix
Future<List<String>> _getTomlPaths({required String prefix}) async =>
    (await _getAssetsList())
        .where((path) => path.startsWith(prefix) && path.endsWith('.toml'))
        .toList();

/// Expect that the set of IDs in the map is equal to the set of basenames of
/// the paths.
void _expectIdsEqual(Map<String, Object> map, List<String> paths) {
  final basenames = Set<String>.from(paths.map(p.basenameWithoutExtension));
  final ids = Set<String>.from(map.keys);
  expectEqual<Set<String>>(basenames, ids);
}

/// Main entry point function.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LocalDataService.getStaticData()', () async {
    // Arrange
    final assessmentInfoPaths = await _getTomlPaths(
      prefix: Assets.assessmentInfoDir,
    );
    final questionInfoPaths = await _getTomlPaths(
      prefix: Assets.questionInfoDir,
    );
    final recommendationsInfoPaths = await _getTomlPaths(
      prefix: Assets.recommendationsInfoDir,
    );
    final localDataService = LocalDataService();

    // Act
    final staticData = await localDataService.loadStaticData();

    // Assert

    // * Expect each map is non-empty
    expect(staticData.assessmentInfoMap.length, greaterThan(0));
    expect(staticData.questionInfoMap.length, greaterThan(0));
    expect(staticData.recommendationsInfoMap.length, greaterThan(0));

    // * Expect that the number of entries in map matches the number of
    //   TOML paths in each directory.
    expectEqual<int>(
      staticData.assessmentInfoMap.length,
      assessmentInfoPaths.length,
    );
    expectEqual<int>(
      staticData.questionInfoMap.length,
      questionInfoPaths.length,
    );
    expectEqual<int>(
      staticData.recommendationsInfoMap.length,
      recommendationsInfoPaths.length,
    );

    // * Expect that the IDs (the keys in the maps) matches the basename of the
    //   files.
    _expectIdsEqual(staticData.assessmentInfoMap, assessmentInfoPaths);
    _expectIdsEqual(staticData.questionInfoMap, questionInfoPaths);
    _expectIdsEqual(
      staticData.recommendationsInfoMap,
      recommendationsInfoPaths,
    );
  });
}
