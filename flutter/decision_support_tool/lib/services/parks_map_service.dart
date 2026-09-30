import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:decision_support_tool/services/geo_utils.dart';

class ParksMapData {
  final double lon;
  final double lat;
  final String matchedAddress;
  final List<Map<String, dynamic>> parkFeatures;
  final int layerId;

  ParksMapData({
    required this.lon,
    required this.lat,
    required this.matchedAddress,
    required this.parkFeatures,
    required this.layerId,
  });
}

/// Builds the map overlay for the parks result dialog from the same local
/// dataset ParksQueryService counts against, instead of a live ArcGIS
/// query. See data_processing/Q9_public_parks/README.md.
class ParksMapService {
  static const String _assetPath = 'assets/data/clark_county_parks.json';
  static const double _bufferMiles = 0.5;

  static List<Map<String, dynamic>>? _cachedFeatures;

  /// Get map data for displaying parks. [layerId] is the "best" layer
  /// ParksQueryService picked for this address; only that layer's parks
  /// within the buffer are drawn, matching the previous live behavior.
  static Future<ParksMapData> getMapData({
    required double lon,
    required double lat,
    required String matchedAddress,
    required int layerId,
  }) async {
    final features = await _loadFeatures();

    final result = <Map<String, dynamic>>[];
    for (final f in features) {
      if (f['layerId'] != layerId) continue;
      final ring = f['ring'] as List<List<double>>;
      if (GeoUtils.distanceMilesToPolygon(lon, lat, ring) > _bufferMiles) {
        continue;
      }
      result.add({
        'geometry': {
          'rings': [ring],
        },
        'attributes': {'NAME': f['name']},
      });
    }

    return ParksMapData(
      lon: lon,
      lat: lat,
      matchedAddress: matchedAddress,
      parkFeatures: result,
      layerId: layerId,
    );
  }

  static Future<List<Map<String, dynamic>>> _loadFeatures() async {
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
        'layerId': (f['layerId'] as num).toInt(),
        'name': f['name'],
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
