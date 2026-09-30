import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:decision_support_tool/services/geocoding_service.dart';
import 'package:decision_support_tool/services/geo_utils.dart';

class ParksQueryResult {
  final int count;
  final String matchedAddress;
  final double lon;
  final double lat;
  final String answer;
  final int layerId;

  ParksQueryResult({
    required this.count,
    required this.matchedAddress,
    required this.lon,
    required this.lat,
    required this.answer,
    required this.layerId,
  });
}

/// Counts parks within a half-mile radius of an address using a local
/// dataset instead of a live ArcGIS FeatureServer query.
///
/// Local dataset: assets/data/clark_county_parks.json — every polygon from
/// the 6 jurisdiction-specific park layers (Las Vegas, Clark County,
/// Henderson, Mesquite, Boulder City, North Las Vegas Parks) the previous
/// live implementation queried. Like the live `_bestLayerByCount`, this
/// counts each layer separately within the buffer and keeps whichever
/// single layer returned the highest count — not the sum across layers
/// (see data_processing/Q9_public_parks/README.md).
class ParksQueryService {
  static const String _assetPath = 'assets/data/clark_county_parks.json';
  static const double _bufferMiles = 0.5;

  static Map<int, List<List<List<double>>>>? _cachedRingsByLayer;

  static Future<ParksQueryResult> countParksNearAddress(String address) async {
    final geocode = await GeocodingService.geocodeAddress(address);
    final ringsByLayer = await _loadRingsByLayer();

    int bestId = -1;
    int bestCount = -1;
    for (final entry in ringsByLayer.entries) {
      int count = 0;
      for (final ring in entry.value) {
        if (GeoUtils.distanceMilesToPolygon(
              geocode.lon,
              geocode.lat,
              ring,
            ) <=
            _bufferMiles) {
          count++;
        }
      }
      if (count > bestCount) {
        bestCount = count;
        bestId = entry.key;
      }
    }

    if (bestId < 0) {
      throw Exception('Could not query any park layers');
    }

    String answer;
    if (bestCount == 0) {
      answer = '0';
    } else if (bestCount == 1) {
      answer = '1';
    } else {
      answer = '>1';
    }

    return ParksQueryResult(
      count: bestCount,
      matchedAddress: geocode.matchedAddress,
      lon: geocode.lon,
      lat: geocode.lat,
      answer: answer,
      layerId: bestId,
    );
  }

  static Future<Map<int, List<List<List<double>>>>> _loadRingsByLayer() async {
    if (_cachedRingsByLayer != null) return _cachedRingsByLayer!;
    final jsonString = await rootBundle.loadString(_assetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final features = (data['features'] as List).cast<Map<String, dynamic>>();

    final byLayer = <int, List<List<List<double>>>>{};
    for (final f in features) {
      final layerId = (f['layerId'] as num).toInt();
      final rawRings = f['rings'] as List?;
      if (rawRings == null || rawRings.isEmpty) continue;
      final outer = (rawRings[0] as List)
          .map<List<double>>(
            (p) => [(p[0] as num).toDouble(), (p[1] as num).toDouble()],
          )
          .toList();
      byLayer.putIfAbsent(layerId, () => []).add(outer);
    }
    _cachedRingsByLayer = byLayer;
    return byLayer;
  }

  static void clearCache() {
    _cachedRingsByLayer = null;
  }
}
