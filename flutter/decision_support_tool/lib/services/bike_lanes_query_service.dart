import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:decision_support_tool/services/geocoding_service.dart';
import 'package:decision_support_tool/services/geo_utils.dart';

class BikeLanesQueryResult {
  final int count;
  final String matchedAddress;
  final double lon;
  final double lat;
  final String answer;
  final int bikeLaneLayerId;
  final int sharedUsePathLayerId;

  BikeLanesQueryResult({
    required this.count,
    required this.matchedAddress,
    required this.lon,
    required this.lat,
    required this.answer,
    required this.bikeLaneLayerId,
    required this.sharedUsePathLayerId,
  });
}

/// Counts bike lanes + shared use paths within a quarter-mile radius of an
/// address using a local dataset instead of two live ArcGIS FeatureServer
/// queries.
///
/// Local dataset: assets/data/clark_county_bike_lanes.json — every line
/// from RTC's "HUB" FeatureServer layers 9 (bike lanes) and 10 (shared use
/// paths), tagged by kind (see data_processing/Q11_bike_lanes/README.md).
/// The total is the sum of both counts, matching the live service.
class BikeLanesQueryService {
  static const String _assetPath = 'assets/data/clark_county_bike_lanes.json';
  static const double _bufferMiles = 0.25; // 1/4 mile radius

  static const int _bikeLaneLayerId = 9;
  static const int _sharedUsePathLayerId = 10;

  static Map<String, List<List<List<double>>>>? _cachedPathsByKind;

  static Future<BikeLanesQueryResult> countBikeLanesNearAddress(
    String address,
  ) async {
    final geocode = await GeocodingService.geocodeAddress(address);
    final pathsByKind = await _loadPathsByKind();

    int bikeLaneCount = 0;
    for (final path in pathsByKind['bike_lane'] ?? const []) {
      if (GeoUtils.distanceMilesToPolyline(geocode.lon, geocode.lat, path) <=
          _bufferMiles) {
        bikeLaneCount++;
      }
    }

    int sharedUsePathCount = 0;
    for (final path in pathsByKind['shared_use_path'] ?? const []) {
      if (GeoUtils.distanceMilesToPolyline(geocode.lon, geocode.lat, path) <=
          _bufferMiles) {
        sharedUsePathCount++;
      }
    }

    final totalCount = bikeLaneCount + sharedUsePathCount;
    final answer = totalCount == 0 ? '0' : '1 or more';

    return BikeLanesQueryResult(
      count: totalCount,
      matchedAddress: geocode.matchedAddress,
      lon: geocode.lon,
      lat: geocode.lat,
      answer: answer,
      bikeLaneLayerId: _bikeLaneLayerId,
      sharedUsePathLayerId: _sharedUsePathLayerId,
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
