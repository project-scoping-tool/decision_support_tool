import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:decision_support_tool/services/geo_utils.dart';

class SchoolsMapData {
  final double lon;
  final double lat;
  final String matchedAddress;
  final List<Map<String, dynamic>> schoolFeatures;
  final int layerId;

  SchoolsMapData({
    required this.lon,
    required this.lat,
    required this.matchedAddress,
    required this.schoolFeatures,
    required this.layerId,
  });
}

/// Builds the map overlay for the schools result dialog from the same local
/// dataset SchoolsQueryService counts against, instead of a live ArcGIS
/// query. See data_processing/Q8/README.md.
class SchoolsMapService {
  static const String _assetPath = 'assets/data/clark_county_schools.json';
  static const double _bufferMiles = 0.5;

  static List<Map<String, dynamic>>? _cachedFeatures;

  static Future<SchoolsMapData> getMapData({
    required double lon,
    required double lat,
    required String matchedAddress,
    required int layerId,
  }) async {
    final features = await _loadLocalData();

    final result = <Map<String, dynamic>>[];
    for (final f in features) {
      final ring = f['ring'] as List<List<double>>;
      if (GeoUtils.distanceMilesToPolygon(lon, lat, ring) > _bufferMiles) {
        continue;
      }

      final attrs = {'NAME': f['name']};

      // Boundary polygon.
      result.add({
        'geometry': {
          'rings': [ring],
        },
        'attributes': attrs,
      });
      // Icon marker at centroid, inside the polygon.
      result.add({
        'geometry': {'x': f['lon'], 'y': f['lat']},
        'attributes': attrs,
      });
    }

    return SchoolsMapData(
      lon: lon,
      lat: lat,
      matchedAddress: matchedAddress,
      schoolFeatures: result,
      layerId: layerId,
    );
  }

  static Future<List<Map<String, dynamic>>> _loadLocalData() async {
    if (_cachedFeatures != null) return _cachedFeatures!;
    final jsonString = await rootBundle.loadString(_assetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final rawFeatures = (data['features'] as List).cast<Map<String, dynamic>>();

    final features = <Map<String, dynamic>>[];
    for (final f in rawFeatures) {
      final rawRings = f['rings'] as List?;
      if (rawRings == null || rawRings.isEmpty) continue;
      final ring = (rawRings[0] as List)
          .map<List<double>>(
            (p) => [(p[0] as num).toDouble(), (p[1] as num).toDouble()],
          )
          .toList();
      features.add({
        'name': f['name'],
        'lon': (f['lon'] as num).toDouble(),
        'lat': (f['lat'] as num).toDouble(),
        'ring': ring,
      });
    }
    _cachedFeatures = features;
    return features;
  }

  static void clearCache() {
    _cachedFeatures = null;
  }
}
