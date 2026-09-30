import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:decision_support_tool/services/geo_utils.dart';

class BikeLanesMapData {
  final double lon;
  final double lat;
  final String matchedAddress;
  final List<Map<String, dynamic>> bikeLaneFeatures;
  final List<Map<String, dynamic>> sharedUsePathFeatures;
  final int bikeLaneLayerId;
  final int sharedUsePathLayerId;

  BikeLanesMapData({
    required this.lon,
    required this.lat,
    required this.matchedAddress,
    required this.bikeLaneFeatures,
    required this.sharedUsePathFeatures,
    required this.bikeLaneLayerId,
    required this.sharedUsePathLayerId,
  });
}

/// Builds the map overlay for the bike lanes result dialog from the same
/// local dataset BikeLanesQueryService counts against, instead of two live
/// ArcGIS queries. See data_processing/Q11_bike_lanes/README.md.
class BikeLanesMapService {
  static const String _assetPath = 'assets/data/clark_county_bike_lanes.json';
  static const double _bufferMiles = 0.25;

  static Map<String, List<List<List<double>>>>? _cachedPathsByKind;

  static Future<BikeLanesMapData> getMapData({
    required double lon,
    required double lat,
    required String matchedAddress,
    required int bikeLaneLayerId,
    required int sharedUsePathLayerId,
  }) async {
    final byKind = await _loadPathsByKind();

    final bikeLaneFeatures = <Map<String, dynamic>>[];
    for (final path in byKind['bike_lane'] ?? const []) {
      if (GeoUtils.distanceMilesToPolyline(lon, lat, path) <= _bufferMiles) {
        bikeLaneFeatures.add({
          'geometry': {
            'paths': [path],
          },
          'attributes': {},
        });
      }
    }

    final sharedUsePathFeatures = <Map<String, dynamic>>[];
    for (final path in byKind['shared_use_path'] ?? const []) {
      if (GeoUtils.distanceMilesToPolyline(lon, lat, path) <= _bufferMiles) {
        sharedUsePathFeatures.add({
          'geometry': {
            'paths': [path],
          },
          'attributes': {},
        });
      }
    }

    return BikeLanesMapData(
      lon: lon,
      lat: lat,
      matchedAddress: matchedAddress,
      bikeLaneFeatures: bikeLaneFeatures,
      sharedUsePathFeatures: sharedUsePathFeatures,
      bikeLaneLayerId: bikeLaneLayerId,
      sharedUsePathLayerId: sharedUsePathLayerId,
    );
  }

  static Future<Map<String, List<List<List<double>>>>>
  _loadPathsByKind() async {
    if (_cachedPathsByKind != null) return _cachedPathsByKind!;
    final jsonString = await rootBundle.loadString(_assetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final features = (data['features'] as List).cast<Map<String, dynamic>>();

    final byKind = <String, List<List<List<double>>>>{};
    for (final f in features) {
      final kind = f['kind'] as String;
      final rawPaths = f['paths'] as List;
      for (final rawPath in rawPaths) {
        final path = (rawPath as List)
            .map<List<double>>(
              (p) => [(p[0] as num).toDouble(), (p[1] as num).toDouble()],
            )
            .toList();
        byKind.putIfAbsent(kind, () => []).add(path);
      }
    }
    _cachedPathsByKind = byKind;
    return byKind;
  }

  static void clearCache() {
    _cachedPathsByKind = null;
  }
}
