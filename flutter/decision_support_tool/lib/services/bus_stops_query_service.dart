import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:decision_support_tool/services/geocoding_service.dart';
import 'package:decision_support_tool/services/geo_utils.dart';

class BusStopsQueryResult {
  final int count;
  final String matchedAddress;
  final double lon;
  final double lat;
  final String answer;
  final int layerId;

  BusStopsQueryResult({
    required this.count,
    required this.matchedAddress,
    required this.lon,
    required this.lat,
    required this.answer,
    required this.layerId,
  });
}

/// Counts RTC bus stops within a quarter-mile radius of an address using a
/// local dataset instead of a live ArcGIS FeatureServer query.
///
/// Local dataset: assets/data/clark_county_bus_stops.json — every point
/// from the same RTC "HUB" FeatureServer layer the previous live
/// implementation queried (a single point layer, no sub-layer selection
/// needed — see data_processing/Q10_bus_stops/README.md).
class BusStopsQueryService {
  static const String _assetPath = 'assets/data/clark_county_bus_stops.json';
  static const double _bufferMiles = 0.25; // 1/4 mile radius
  static const int _layerId = 0;

  static List<Map<String, double>>? _cachedStops;

  static Future<BusStopsQueryResult> countBusStopsNearAddress(
    String address,
  ) async {
    final geocode = await GeocodingService.geocodeAddress(address);
    final stops = await _loadStops();

    int count = 0;
    for (final s in stops) {
      if (GeoUtils.distanceMilesHaversine(
            geocode.lon,
            geocode.lat,
            s['lon']!,
            s['lat']!,
          ) <=
          _bufferMiles) {
        count++;
      }
    }

    final answer = count == 0 ? '0' : '1 or more';

    return BusStopsQueryResult(
      count: count,
      matchedAddress: geocode.matchedAddress,
      lon: geocode.lon,
      lat: geocode.lat,
      answer: answer,
      layerId: _layerId,
    );
  }

  static Future<List<Map<String, double>>> _loadStops() async {
    if (_cachedStops != null) return _cachedStops!;
    final jsonString = await rootBundle.loadString(_assetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final features = (data['features'] as List).cast<Map<String, dynamic>>();
    final stops = features
        .map(
          (f) => {
            'lon': (f['lon'] as num).toDouble(),
            'lat': (f['lat'] as num).toDouble(),
          },
        )
        .toList();
    _cachedStops = stops;
    return stops;
  }

  static void clearCache() {
    _cachedStops = null;
  }
}
