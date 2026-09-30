import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:decision_support_tool/services/geo_utils.dart';

class BusStopsMapData {
  final double lon;
  final double lat;
  final String matchedAddress;
  final List<Map<String, dynamic>> busStopFeatures;
  final int layerId;

  BusStopsMapData({
    required this.lon,
    required this.lat,
    required this.matchedAddress,
    required this.busStopFeatures,
    required this.layerId,
  });
}

/// Builds the map overlay for the bus stops result dialog from the same
/// local dataset BusStopsQueryService counts against, instead of a live
/// ArcGIS query. See data_processing/Q10_bus_stops/README.md.
class BusStopsMapService {
  static const String _assetPath = 'assets/data/clark_county_bus_stops.json';
  static const double _bufferMiles = 0.25;

  static List<Map<String, dynamic>>? _cachedFeatures;

  static Future<BusStopsMapData> getMapData({
    required double lon,
    required double lat,
    required String matchedAddress,
    required int layerId,
  }) async {
    final stops = await _loadStops();

    final result = <Map<String, dynamic>>[];
    for (final s in stops) {
      final slon = s['lon'] as double;
      final slat = s['lat'] as double;
      if (GeoUtils.distanceMilesHaversine(lon, lat, slon, slat) >
          _bufferMiles) {
        continue;
      }
      result.add({
        'geometry': {'x': slon, 'y': slat},
        'attributes': {'NAME': s['name']},
      });
    }

    return BusStopsMapData(
      lon: lon,
      lat: lat,
      matchedAddress: matchedAddress,
      busStopFeatures: result,
      layerId: layerId,
    );
  }

  static Future<List<Map<String, dynamic>>> _loadStops() async {
    if (_cachedFeatures != null) return _cachedFeatures!;
    final jsonString = await rootBundle.loadString(_assetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final features = (data['features'] as List).cast<Map<String, dynamic>>();
    final stops = features
        .map(
          (f) => {
            'lon': (f['lon'] as num).toDouble(),
            'lat': (f['lat'] as num).toDouble(),
            'name': f['name'],
          },
        )
        .toList();
    _cachedFeatures = stops;
    return stops;
  }

  static void clearCache() {
    _cachedFeatures = null;
  }
}
