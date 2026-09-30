import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:decision_support_tool/services/geocoding_service.dart';
import 'package:decision_support_tool/services/geo_utils.dart';

class SchoolsQueryResult {
  final int count;
  final String matchedAddress;
  final double lon;
  final double lat;
  final String answer;
  final int layerId;

  SchoolsQueryResult({
    required this.count,
    required this.matchedAddress,
    required this.lon,
    required this.lat,
    required this.answer,
    required this.layerId,
  });
}

/// Counts CCSD campuses within a half-mile radius of an address using a
/// local dataset instead of a live ArcGIS FeatureServer query.
///
/// Local dataset: assets/data/clark_county_schools.json — the "CCSD
/// Campuses" layer only (polygon campus footprints). That's the same
/// single layer the previous live implementation always ended up querying
/// (SchoolsQueryService._pickBestSchoolLayer() picked the first layer whose
/// name contained "campus", which is always "CCSD Campuses" in this
/// FeatureServer's layer order) — see data_processing/Q8/README.md for how
/// that was traced and confirmed.
class SchoolsQueryService {
  static const String _assetPath = 'assets/data/clark_county_schools.json';
  static const double _bufferMiles = 0.5; // 1/2 mile radius

  /// ArcGIS layer id of "CCSD Campuses" in the source FeatureServer — kept
  /// only for the result dialog's "Data from ... layer $layerId" text.
  static const int _layerId = 1;

  static List<List<List<double>>>? _cachedRings;

  static Future<SchoolsQueryResult> countSchoolsNearAddress(
    String address,
  ) async {
    final geocode = await GeocodingService.geocodeAddress(address);
    final rings = await _loadCampusRings();

    int count = 0;
    for (final ring in rings) {
      if (GeoUtils.distanceMilesToPolygon(geocode.lon, geocode.lat, ring) <=
          _bufferMiles) {
        count++;
      }
    }

    String answer;
    if (count == 0) {
      answer = '0';
    } else if (count == 1) {
      answer = '1';
    } else {
      answer = '>1';
    }

    return SchoolsQueryResult(
      count: count,
      matchedAddress: geocode.matchedAddress,
      lon: geocode.lon,
      lat: geocode.lat,
      answer: answer,
      layerId: _layerId,
    );
  }

  /// Loads and caches just the outer ring of every campus polygon.
  static Future<List<List<List<double>>>> _loadCampusRings() async {
    if (_cachedRings != null) {
      return _cachedRings!;
    }
    final jsonString = await rootBundle.loadString(_assetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final features = (data['features'] as List).cast<Map<String, dynamic>>();

    final rings = <List<List<double>>>[];
    for (final f in features) {
      final rawRings = f['rings'] as List?;
      if (rawRings == null || rawRings.isEmpty) continue;
      final outer = (rawRings[0] as List)
          .map<List<double>>(
            (p) => [(p[0] as num).toDouble(), (p[1] as num).toDouble()],
          )
          .toList();
      rings.add(outer);
    }
    _cachedRings = rings;
    return rings;
  }

  static void clearCache() {
    _cachedRings = null;
  }
}
